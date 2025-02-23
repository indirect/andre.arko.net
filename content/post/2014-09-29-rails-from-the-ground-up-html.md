---
date: "2014-09-29T00:00:00Z"
title: 'Rails from the ground up: HTML'
---

LasLast time, we learned about [status codes](/2014/07/22/rails-from-the-ground-up-headers--status-codes/), and created an HTTP server that was able to serve a response to a web browser. This time, we're going to change the response body to be _HTML_. HTML stands for "HyperText Markup Language". HTML is written as plain text, but _rendered_ by web browsers.

What each browser renders is theoretically determined by the HTML sent to the browser (and CSS sent to the browser, but we'll talk about that later). In real life, HTML may be rendered slightly differently by different browsers. For now, though, we're going to ignore those minor differences, and focus on getting our HTTP server sending HTML in its responses.

Here's an expanded version of our HTTP server from last time that returns HTML instead of plaintext.

```ruby
require 'socket'
server = TCPServer.new 3000
loop do
  socket = server.accept
  socket.write "HTTP/1.0 200 OK\r\n"
  socket.write "Content-Length: 38\r\n"
  socket.write "\r\n"
  socket.write "<html><body><h1>hi</h1></body></html>\n"
  socket.close
end
```

Go ahead and run that code and then brows to [localhost:3000](http://localhost:3000) in your browser. You'll notice that a couple of things have changed since last time. The word "hi" should be much bigger and bolder than it was in the example from last time. In the code, we've changed the `Content-Length` header to match the length of our new body, and we've changed the body to contain some new words inside the `<>` characters, which are normally referred to as _angle brackets_.

The combination of a word inside angle brackets, some text, and the same word (after a slash `/`) inside angle brackets again is called an HTML _tag_. The initial word is called an _opening tag_, and the final slash plus word is called a _closing tag_. Tags are the way that HTML provides instructions to web browsers. (There are some tags that don't need closing tags, but we'll get to them for later). Our new HTTP response body contains three tags: an `html` tag, a `body` tag, and an `h1` tag.

The `html` tag is required for all HTML documents, and simply serves as the beginning and end of the text that a browser should render. Like HTTP has headers and then a body, HTML can also have optional headers and then a body. We've skipped the `head` tag and HTML headers for now, but we'll come back to them later. The `body` tag tells the browser to render the HTML inside it. Finally, the `h1` tag tells the browser that the text inside it is a header. There are several header tags, starting with `h1` (the biggest) and going  down to `h6` (the smallest, but still bigger than regular text).

HTML contains dozens of tags, and each one tells the web browser to do something different. Tags can be invisible (like `span` tags) or they can be extremely visible (like `h1` tags). Either way, they add what is typically called _semantic meaning_ to the text. Semantic meaning is just a fancy way of saying that the tags add information about what the text means that you wouldn't have if the tags weren't there.

There are a lot of pieces to HTML, and it would take a lot of posts to cover them all. We're focusing on Rails here, but if you're interested in learning more about HTML itself, check out [Mozilla developer documentation](https://developer.mozilla.org/en-US/docs/Web/HTML) as an online reference, or [Head First HTML & CSS](http://www.amazon.com/gp/product/0596159900/?tag=indirect0b-20) as a book to get started with.

If you've been experimenting with the HTTP server code, you've probably noticed that the `Content-Length` header has to exactly match the number of characters in the response body, or web browsers won't show it. Next time, we'll fix that by making our program count the characters for us. We'll also start to return _dynamic content_, which means that the page you see in your browser won't be the same every time.
