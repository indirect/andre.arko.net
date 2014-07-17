---
title: "Rails from the ground up: HTTP"
layout: post
---
Welcome to Rails from the ground up! In this series of posts, I'm going to talk about the many pieces that underlie every Ruby on Rails application. By the end, anyone who has read every post will hopefully understand both how each layer of the Rails stack works, why it's there, and how to implement it themselves.

The entire Ruby on Rails web application framework is designed around accepting requests and generating responses. Those requests follow (or are at least supposed to follow) the rules of the Hyper-Text Transport Protocol. HTTP is used by every web browser and web server, as well as the vast majority of applications on computers, phones, and tablets that communicate with a server.

### Requests

Fortunately, it turns out that HTTP at its simplest is just a few lines of text. Here is a valid HTTP 1.1 request:

<pre><code>GET / HTTP/1.1
    
</code></pre>

`GET` is an _HTTP verb_, and tells the server what the client is trying to do. The single forward slash by itself (`/`) is the _path_, identifying the resource that the client is requesting from the server. The `HTTP/1.1` tells the server that this client knows how to use the HTTP protocol version 1.1. Version 1.1 added some handy things that we'll talk about later, but don't matter for now. The last line is required to be blank as part of the protocol, and indicates that the client is done sending the request.

It's possible to see the plain text of a request using the netcat command-line tool and any web browser. First, open a terminal window and start netcat listening by running `nc -lp 3000`. Then, open a web browser and browse to [http://localhost:3000](http://localhost:3000). Here's an example using Safari 7.

```
$ nc -lp 3000
GET / HTTP/1.1
Host: localhost:3000
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-us
Connection: keep-alive
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.77.4 (KHTML, like Gecko) Version/7.0.5 Safari/537.77.4

```

We'll talk more about the extra lines following the first line (called _request headers_) in the next post in this series. For now, this serves to show that even the newest and fanciest web browsers use easily readable plain-text HTTP.

### Responses

In HTTP, responses are sent back over the same connection. The first lines are _response headers_, and after two newlines comes the _body_. The body contains the stuff that you actually see in your browser.

Using netcat, it's possible to send a response to your web browser just by typing. The absolute minimum that you can send is a line of text, followed by ⌃C to quit netcat and close the connection.

```
$ nc -lp 3000
GET / HTTP/1.1
Host: localhost:3000
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-us
Connection: keep-alive
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.77.4 (KHTML, like Gecko) Version/7.0.5 Safari/537.77.4

hi
^C
```

This is a complete HTTP request and response! In Safari 7, it produces a screen that looks like this:

![Safari window containing "hi"](http://files.arko.net/image/0K0X3y0Y0w2r/Image%202014-07-14%20at%201.10.23%20AM.png)

Now that we've got the basics of HTTP out of the way, everything from here on out will be a piece of cake. Probably.

Next up: HTTP headers.
