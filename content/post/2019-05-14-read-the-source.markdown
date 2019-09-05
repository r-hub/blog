---
title: Read the R source!
date: '2019-05-14'
slug: read-the-source
tags:
  - help
  - CRAN
---

Ever heard the phrase "Read the source, Luke"? It's a play on ["Use the force, Luke" from Star Wars](https://mygeekwisdom.com/2012/04/14/use-the-force-luke/), with no definite _source_ :wink: that we could find^[We erroneously first linked to [a rather recent blog post](https://blog.codinghorror.com/learn-to-read-the-source-luke/) but [Robert Link](https://github.com/rplzzz) corrected us [in a comment](https://github.com/r-hub/blog/issues/27#issuecomment-528011915) that we reproduce here in case the post gets separated from its comments: _""Use the Source, Luke" goes way back before 2012, and probably even before blogs were a thing.  Here's a mention in the New Hacker's Dictionary: http://catb.org/jargon/html/U/UTSL.html.
The earliest version I've been able to find is from August of 1991:  http://www.catb.org/~esr/jargon/oldversions/jarg296.txt, but I suspect it was in use long before then.  "_]; and it underlines how important and useful it can be to read the source code of a tool instead of just its docs. 

In this blog post, we shall explain why and how to read the source code of your R tools, be they base R or packages, and how an R-hub service is part of the reason why this process has gotten easier.

# Why read the source?

In which cases would you want to read the actual code of a function or of a whole package? Here are a few that come to mind:

* You want to know what is going on, because you're not sure of e.g. the variance definition used in that statistical thing you're trying to use.

* You want to build on the function/package for your own goals.

* You're just curious. Good for you, you'll learn a ton. :nerd_face:

* You want to know how to use a given R idiom or function inside your code, so you're trying to find examples in the wild.

# How to read the source of a function/package

Sometimes, finding the source of a function might be as easy as writing its name in the console and voilà! you'll get to read the code. Alas, this won't always work (S3 generics, compiled code...). [Jenny Bryan wrote a detailed how-to for each case](https://github.com/jennybc/access-r-source#accessing-r-source), that [Jim Hester automated as an R package, `lookup`](https://github.com/jimhester/lookup#readme), so all you need to do is to learn how to use `lookup`... as well as read its source, of course! :wink:

Let's explore its basic usage.

```r
library("lookup")
rhub::check_for_cran
```

The snippet above will open the source code of the function, check-cran.R. 
```r
lookup(body)
lookup_browse()
```

This last snippet will first show the body of the `body()` function locally, and then open a browser window pointing at it in the [GitHub mirror of the R source](https://github.com/wch/r-source). 

All in all, `lookup` is a handy package. :ok_hand: How does it work under the hood? We'll let you read its source, but part of the magic is supported by mirrors of R code hosted on GitHub:

* [mirror of R source code](https://github.com/wch/r-source) by Winston Chang,

* [mirror of CRAN packages](https://github.com/cran), provided by R-hub :sunglasses:.

# How to search the source

What if you don't know whose source code you'd like to read, i.e. you'd like to see how `vapply()` is used in the wild? That's another case where the code mirrors mentioned previously can help you! All these mirrors are based on GitHub repos, so to use them, you can

* use [GitHub (advanced) search](https://help.github.com/en/articles/about-searching-on-github)

* use [GitHub search via its V3 API](https://developer.github.com/v3/search/) and [the `gh` package](https://github.com/r-lib/gh), but beware of rate limits.

* use [GitHub archive](https://www.githubarchive.org/) via [Google BigQuery](https://developers.google.com/bigquery/) e.g. with the [`bigrquery` package](https://github.com/r-dbi/bigrquery).

If you only want to search for code usage on CRAN, you can... use `lookup`!

```r
lookup::lookup_usage("vapply")
```

will open https://github.com/search?l=r&q=%22vapply%22+user%3Acran+language%3AR&ref=searchresults&type=Code&utf8=%E2%9C%93, i.e. a GitHub search URL, restricted to R-hub's CRAN source code mirror.

# Conclusion

Reading the R source is useful, and the process of finding it got smoother thanks to the `lookup` package. A piece of the machinery behind it is R-hub's CRAN source code mirror, about which you can find out more in [our docs](https://docs.r-hub.io/#cranatgh). And once you're browsing our docs, stay a while and have a look at our other free services helping R package development!
