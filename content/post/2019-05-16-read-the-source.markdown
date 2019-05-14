---
title: Read the R source!
date: '2019-05-12'
slug: read-the-source
tags:
  - help
  - CRAN
---

Ever heard the phrase "Read the source, Luke"? It's a play on "Use the force, Luke" from Star Wars, and there's no definite source for it, [maybe a blog post by Jeff Atwood](https://blog.codinghorror.com/learn-to-read-the-source-luke/); and it underlines how important and useful it can be to read the source code of a tool instead of just its docs. 

In this blog post, we shall explain why and how to read the source code of your R tools be they base R or packages, and how a R-hub service is part of the reason why this process has gotten easier.

# Why read the source?

In which cases would you want to read the actual code of a function or of a whole package? Here a few that come to mind:

* You want to know what is going on, because you're not sure of e.g. the variance definition used in that statistical thing you're trying to use.

* You want to build on the function/package for your own goals.

* You're just curious. :nerd_face:

* You want to know how to use a given R idiom or function inside your code, so you're trying to find examples in the wild.

# How to read the source of a function/package

Sometimes, finding the source of a function might be as easy as writing its name in the console and voilà! you'll get to read the code. Alas, this won't always work (S3 generics, compiled code...). [Jenny Bryan wrote a detailed how-to for each case](https://github.com/jennybc/access-r-source#accessing-r-source), that [Jim Hester automated as an R package, `lookup`](https://github.com/jimhester/lookup#readme), so all you need to do is to learn how to use `lookup`... as well as read its source, of course! :wink:

# How to search the source

What if you don't know whose source code you'd like to read, i.e. you'd like to see how `sapply()` is used in the wild?
