---
title: "Rails from the ground up: Status Codes & Headers"
layout: post
---
Now that we know what the tiniest possible response looks like, we can talk about what a valid and correct HTTP response looks like. That means explaining *status codes* and *headers*.

To send a fully correct HTTP response, we need to first tell the client our HTTP version and the status code of our response. Status codes tell the client what kind of response is going to be sent.

For the smallest possible response, we only need one status code: `200 OK`. That code means everything is okay on the server, and a response is about to be sent.

Other common status codes include `302 Found`, `404 Not Found`, and various other messages that are useful to send to a browser or other HTTP client. There are [a lot of status codes](http://httpstatus.es), so feel free to read more about all of them if you're interested.

So, the first line of a valid response simply declares the version of HTTP that the server supports and the status code:

```
HTTP/1.0 200 OK
```

The next line (and subsequent lines, until there is a completely blank line) are all headers. Similar to the client headers that we saw in the previous post, response headers consist of a name, a colon and space, and then a value. They contain information about the response that is being sent, but are not considered part of the response itself.

While HTTP version 1.0 technically doesn't require any headers, browsers usually don't work unless you supply at least the `Content-Length` header. It should be set to the number of bytes in the response body.

After all that, we know how to create the smallest possible valid HTTP response.

```
HTTP/1.0 200 OK
Content-Length: 2

hi
```

Armed with this knowledge, it is now easy to write a Ruby server we can navigate to in our browser:

```ruby
require 'socket'
server = TCPServer.new 3000
loop do
  socket = server.accept
  socket.write "HTTP/1.0 200 OK\r\n"
  socket.write "Content-Length: 2\r\n"
  socket.write "\r\n"
  socket.write "hi\n"
  socket.close
end
```

You can run this server on OS X by copying the code to the clipboard and then running `pbpaste | ruby`. That will start a server at [http://localhost:3000](http://localhost:3000) that you can then navigate to in your browser. You should see our message, "hi"!

Other than `Content-Length`, common repsonse headers include:

  - `Content-Type`, for distinguishing between `text/plain`, `text/html`, and `application/json`
  - `Date`, a timestamp telling when the server replied
  - `Connection`, to let the client know whether to `close` or `keep-alive` this connection
  - `Server`, the name of the server software that sent this reply
  - `Set-Cookie`, data for the client to send back to the server so the server knows who you are

All of these headers (and others besides) allow HTTP clients and servers to coordinate requests and responses in more and more complicated ways.

Now that we have code for a working HTTP server, we'll talk about how to serve HTML next.
