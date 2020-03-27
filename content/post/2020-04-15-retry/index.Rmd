---
slug: retry-wheel
title: "Retries in API packages and reinventing the wheel"
authors:
  - Maëlle Salmon
date: "2020-04-15"
tags:
- package development
- http
output: 
  html_document:
    keep_md: true
---

Web APIs can sometimes fail for no particular reason; 
therefore packages accessing them often add some robustness to their code by _retrying_ calling the API a few times if there was an error.
The two high-level R HTTP clients, `httr` and `crul`, offer a ready-made sub-routine for such cases, but some developers like me have rolled their own out of ignorance.  :sweat_smile:
In this post I shall present the retry sub-routines of `httr` and `crul`, and more generally reflect on (not) reinventing the wheel in your R package.  :ferris_wheel:


<!--html_preserve--> {{< figure src = "https://http.cat/408.jpg" width = "400" alt = "An illustration of the 408 HTTP error code (Request Timeout) showing a kitten napping in a food bowl" link = "https://http.cat/408" >}}<!--/html_preserve-->

## Retry in httr and crul

## On not reinventing the wheel

Once I heard about `httr::RETRY()` and the `crul` `retry` method, I was a bit disappointed at having reinvented the wheel. 
Could one avoid doing that too often?

### How to not reinvent the wheel in your code

As an R package developer, how do you know about functions and methods already existing in packages your package depends on, or could depend on, or could draw inspiration from?
Sometimes you might guess your problem is something others encountered but you might not even know the right words to present it ([mocking](/2019/10/29/mocking/) for instance!).

In [a blog post Jeff Atwood states](https://blog.codinghorror.com/dont-reinvent-the-wheel-unless-you-plan-on-learning-more-about-wheels/) _"If anything, "Don't Reinvent The Wheel" should be used as a call to arms for deeply educating yourself about all the existing solutions"_.
General strategies for learning more and more about the R ecosystem include

* reading the whole reference of packages your package depends on, and even its changelog once in a while, because you might as well use all the gems of a package once you've decided to trust it;

* [reading the R source](/2019/05/14/read-the-source/) of packages similar to yours;

* [trying to keep up-to-date using one or several communication channel(s)](https://masalmon.eu/2019/01/25/uptodate/);

* spreading the word about cool features which is more or less what this post does, and what Sharla Gelfand does in her great ["Sharing two #rstats functions, most days." tweets whose content is gathered in a GitHub repository](https://github.com/sharlagelfand/twofunctionsmostdays/);

Of course, "deeply educating yourself" takes time one doesn't necessarily have and which no one should feel guilty about.
Sometimes you'll re-implement something that already exists elsewhere, and it's fine!

Lastly, you might even want to create your own better version, which is obviously neat. :sunglasses:

### How to help users of your package not reinvent the wheel

As the developer of a package, you might help users find useful features by... working on its docs.
A good time investment could be to create a [`pkgdown`](https://pkgdown.r-lib.org/) website with a [well-organized reference index](https://pkgdown.r-lib.org/articles/pkgdown.html#reference-1).

Furthermore, some features could be added to your package if they're often implemented downstream.

## Conclusion

In this post we've presented useful functions implementing retries for API packages in `httr` and `crul`.
We've also discussed ways to not miss such useful shortcuts for one's code, mostly by learning more about existing R packages, whilst acknowledging such exploration takes time.
What's _your_ favorite lesser known package gem?
