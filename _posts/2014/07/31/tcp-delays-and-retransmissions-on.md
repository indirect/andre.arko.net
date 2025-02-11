---
layout: post
title: "TCP delays and retransmissions on Illumos"
microblog: false
guid: http://indirect-test.micro.blog/2014/08/01/tcp-delays-and-retransmissions-on/
post_id: 4971548
date: 2014-07-31T16:00:00-0800
lastmod: 2014-07-31T16:00:00-0800
type: post
url: /2014/07/31/tcp-delays-and-retransmissions-on/
---

The other day, I helped debug an issue on some production Joyent Cloud servers (which use SmartOS, based on Illumos, the open-source successor to Solaris). The solution turned out to be so non-obvious, and the cause pretty interesting, so I thought it was worth writing up.

While checking through the production request logs, I noticed a specific (and very strange) anomaly. During the day, as traffic increased towards the usual daily peak, the amount of time that requests spent waiting to be processed increased dramatically.

The average time spent in queueing per request went up from ~2ms all the way up to ~12ms... with only a 3x increase in traffic at peak times. A quick check of the servers showed they had plenty of CPU available, and many web server workers that weren't busy. So what could be causing requests to spend time waiting around, instead of getting responded to right away?

The problem was tricky to even notice, since it was bad enough to depress the request averages dashboard, but rare enough that it took careful and specific searching to see the slow requests. Making requests against the load balancer machines revealed that roughly 10% of all traffic experienced a delay before it was answered. No matter how long the request took normally, about 9% of traffic would be delayed by 1.1 seconds, and about 1% of traffic would be delayed by 3.4 seconds.

We eventually narrowed it down to the app servers themselves, writing a script to fire off around 10,000 requests as quickly as they could be served by a single set of unicorn server processes. Even when the requests were coming one at a time, and even when they were coming from the same machine as the unicorns were running on, the problem would appear again and again.

We tried the usual UNIX voodoo of checking ulimits, file descriptors, open sockets, and the like, but weren't able to find anything that even looked like it might be the problem. According to the internet, a common culprit for long delays before connections are accepted is having too many sockets in the `TIME_WAIT` state.

The `TIME_WAIT` state (or TIME-WAIT, if you ask [RFC 793][ietf]), is the final state for one side of every TCP/IP connection. After a connection, sockets are held in `TIME_WAIT` for up to 4 minutes. Keeping one side of the TCP connection around after it has been closed sounds a little weird at first, but there are reasons to do it. I'll explain briefly, and for more details I would suggest [this explanation of TCP client and server states][timewait], as well as the RFC.

One reason for `TIME_WAIT` is to be able to catch delayed packets that were sent while the connection was open, but arrive after it is closed. Waiting until the network timeout for any packets still traveling means that the next connection to use the socket won't get confused by stray late packets. This is incredibly unlikely under most circumstances.

The main reason is to close TCP connections fully and cleanly. The final ACK, acknowledging that the connection is closed, needs to be accepted as a valid packet, even though the connection has already been closed by both sides. Without `TIME_WAIT`, that final ACK would be rejected, since it would be part of a connection that no longer exists. That's the upside. The downside is that because sockets in `TIME_WAIT` count as used, opening many connections to a single server can block it from opening new connections until existing `TIME_WAIT`s time out.

Since we knew that was a likely possible source for the problem, we checked for that problem first: `netstat -sP tcp` prints statistics for all TCP connections on the entire system. One of those statistics is `tcpTimKeepaliveDrop`, a counter of the number of times a connection could not be accepted due to too many other connections being alive. We never saw that number increment, and so assumed that the (high) number of connections in the `TIME_WAIT` state just wasn't the problem. Big mistake.

Over the course of an entire day of researching TCP tuning on Solaris, on Illumos, and on SmartOS, we tried adjusting nearly every single TCP stack setting. Some suggestions sounded like they might be related to our problem, others sounded completely unrelated. Eventually, we tried changing every single one we could find, and none of them fixed the problem.

While researching issues, we ran `netstat -sP tcp` over and over, looking for some indicator of what the problem was. Near the end of the day, we noticed one specific counter that incremented every time we saw a delayed response: `tcpRetransSegs`. That counter is incremented anytime a TCP segment is sent more than once.

So, we finally learned something concrete: a TCP segment has to be sent again, even though the client and server are on the same computer. That immediately became the new problem, though, because that shouldn't ever happen! Retransmission is supposed to happen if data gets lost and isn't delivered. It's not supposed to happen when a machine is trying to talk to itself.

Armed with new search terms, we were able to find [a mailing list post from 2011][illumos] that described the exact same 1.1 second and 3.4 second delays that we were witnessing. The post was on the Illumos-Developer mailing list, and described the background for a patch to Illumos supplied by Joyent. The entire post is interesting to read, but I'll summarize what they found.

First, a little necessary background on TCP. It's not terribly obvious, but every network connection using IP (and therefore every TCP/IP connection) happens between a source address and port and a destination address and port. For example, for your computer to display `google.com`, it connects to that address on port 80 for HTTP or port 443 for HTTPS.

But that's just the destination. The source is your computer's IP address, on a port that was randomly chosen when you opened the connection. Chances are good that the port number is in the range 49152–65535, which are are the ports officially set aside for this kind of temporary use by IANA (the Internet Assigned Numbers Authority).

When a single host connects to another single host many, many times (as in the case of our load balancer talking to our app server, for example), it connects from one of those temporary ports to the specific port that the app server is listening on. Thanks to `TIME_WAIT`, the app server keeps listening for packets coming from each temporary port for up to the default `tcp_time_wait_interval` of 60 seconds.

Since the source's temporary port is chosen randomly, with many requests per second it is highly likely that a single temporary port will be used for another connection with the same app server on the same listening port. At that point, the server is supposed to realize a new connection is being opened, and the previous connection is no longer being used.

Normally, every TCP packet includes a _sequence number_ that starts at a random-ish value and then goes up by one each time another packet is sent. When a connection is in `TIME_WAIT`, the server will check this number and notice that it is so much higher than the old connection's sequence number that this must be a new request.

Seems straightforward, but TCP sequence numbers are a single 32-bit value. The default settings on Solaris mean that each new connection starts with a new sequence number that is _much_ higher than the last connection. So much higher, in fact, that after several connections the 32-bit number wraps around and starts again from zero.

Now the surprising part: when a new connection is created with the same source address, source port, destination address, and destination port, and the TCP sequence number has also wrapped around, the request for a new connection is interpreted as if it were a delayed request to create the connection that is now in `TIME_WAIT`.

Under those (very specific) circumstances, the server tries to reset the connection instead of opening a new one. Since the connection it asked for was never opened, the client waits a set amount of time and then tries again. The second time, the connection request succeeds. The amount of time before the client retries is set by the parameters `tcp_rexmit_interval_initial` and `tcp_rexmit_interval_min` added together.

While this set of circumstances sounds extremely complicated and unlikely, we were seeing this exact problem happen in production very frequently. As much as 1% of our traffic (many thousands of requests) was being delayed by 3.4 seconds, even if the actual time needed to deliver the response was only 10 milliseconds.

Based on the Illumos blog post, some [old Solaris tuning advice](http://www.sean.de/Solaris/soltune.html) and some [new Solaris tuning advice](http://www.princeton.edu/~unix/Solaris/troubleshoot/), we were able to find a new TCP configuration that reduces the problem so much we don't notice it anymore. Note, however, that this problem is not "fixable", since all we can do is change settings to make it less and less likely.

**Using these settings is a terrible idea on servers exposed to the internet.** That said, running these commands to change TCP tunable settings fixed this issue for us. You'll need root permissions to run these commands on a Solaris/Illumos host.

```bash
# 1) Reduce smallest_anon_port for more ephemeral ports, which reduces collisions
ndd -set /dev/tcp tcp_smallest_anon_port 8192
# 2) Reduce time_wait_interval so less connections are in TIME_WAIT
ndd -set /dev/tcp tcp_time_wait_interval 5000
# 3) Change strong_iss to 0 so that sequence numbers increment by only a fixed amount
ndd -set /dev/tcp tcp_strong_iss 0
# 4) Change iss_incr to 25000 as per the linkedm post to reduce wrap-around
ndd -set /dev/tcp tcp_iss_incr 25000
# 5) Reduce rexmit_interval_initial, min, and max so that collisions take less time
ndd -set /dev/tcp tcp_rexmit_interval_initial 150
ndd -set /dev/tcp tcp_rexmit_interval_min 25
ndd -set /dev/tcp tcp_rexmit_interval_max 15000
# 6) Reduce ip_abort_interval to 4x the rexmit_interval_initial, as recommended
ndd -set /dev/tcp tcp_ip_abort_interval 60000
```

[bug]: https://www.illumos.org/issues/5011
[ietf]: http://tools.ietf.org/html/rfc793
[illumos]: http://lists.illumos.org/pipermail/developer/2011-April/001958.html
[timewait]: http://www.serverframework.com/asynchronousevents/2011/01/time-wait-and-its-design-implications-for-protocols-and-scalable-servers.html
