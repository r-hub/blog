---
slug: retry-wheel
title: "Retries in API packages and reinventing the wheel"
authors:
  - Maëlle Salmon
date: "2020-04-07"
tags:
- package development
- http
output: 
  html_document:
    keep_md: true
---




Web APIs can sometimes fail for no particular reason; 
therefore packages accessing them often add some robustness to their code by _retrying_ calling the API a few times if there was an error.
The two high-level R HTTP clients, `httr` and `crul`, offer ready-made sub-routines for such cases, but some developers like me have rolled their own out of ignorance.  :sweat_smile:
In this post I shall present the retry sub-routines of `httr` and `crul`, and more generally reflect on (not) reinventing the wheel in your R package.  :ferris_wheel:

> The few figures of this post come from the funny [HTTP Cats website](https://http.cat/) and are hyperlinked.

<!--html_preserve--> {{< figure src = "https://http.cat/408.jpg" width = "400" alt = "An illustration of the 408 HTTP error code (Request Timeout) showing a kitten napping in a food bowl" link = "https://http.cat/408" >}}<!--/html_preserve-->

## Retry in httr and crul

Relying on internet resources might make a package fragile, since the connection or interfaced web API can fail.
Therefore, in packages wrapping APIs, one can find some variation of the following pseudo-code that retries a few times:

```r
maxtry <- 5
try <- 1
resp <- do_an_internet_thing()
while (try <= maxtry && resp$status >= 400) {
  resp <- do_an_internet_thing()
  try <- try + 1
  Sys.sleep(some_waiting_time_increasing_with_try(try))
}

```

A [search](https://github.com/search?q=httr%3A%3Aretry+l%3DR+user%3Acran&type=Code) on the [R-hub's CRAN source code mirror](https://docs.r-hub.io/#cranatgh) e.g. surfaces [such a function in a package](https://github.com/cran/geoknife/blob/36dc2b2a342bc5a6fe776ec1f2780ea4d731ee31/R/geoknifeUtils.R#L37L55).

As underlined in [`httr`'s excellent "Best practices for API packages" vignette](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html), _"it’s extremely important to make sure to do this with some form of exponential backoff: if something’s wrong on the server-side, hammering the server with retries may make things worse, and may lead to you exhausting quota (or hitting other sorts of rate limits)."_

Now, if you need such a pattern in your API package, you could use a shortcut rather than patiently ingesting examples and best practice... by using ready-made features of either `httr` or `crul`.

### Retry in httr

The `httr` package contains a handy `RETRY()` function that, well, safely retries a request until it succeeds or until the maximal number of tries is reached.
It uses [best practice written up by AWS](https://www.awsarchitectureblog.com/2015/03/backoff.html) to define the increasing waiting time.

If there's no error, it simply behaves like the corresponding verb would.


```r
httr::RETRY("GET", "http://httpbin.org/status/200")
```

```
## Response [http://httpbin.org/status/200]
##   Date: 2020-03-28 12:29
##   Status: 200
##   Content-Type: text/html; charset=utf-8
## <EMPTY BODY>
```

```r
httr::GET("http://httpbin.org/status/200")
```

```
## Response [http://httpbin.org/status/200]
##   Date: 2020-03-28 12:29
##   Status: 200
##   Content-Type: text/html; charset=utf-8
## <EMPTY BODY>
```

Now, what happens if the API keeps failing, which the example URL below ensures?


```r
httr::RETRY(
  "GET", 
  "http://httpbin.org/status/500",
  times = 5, # the function has other params to tweak its behavior
  pause_min = 5,
  pause_base = 2)
```

```
## Request failed [500]. Retrying in 5 seconds...
## Request failed [500]. Retrying in 5 seconds...
## Request failed [500]. Retrying in 5 seconds...
```

```
## Request failed [500]. Retrying in 29.2 seconds...
```

```
## Response [http://httpbin.org/status/500]
##   Date: 2020-03-28 12:37
##   Status: 500
##   Content-Type: text/html; charset=utf-8
## <EMPTY BODY>
```

The function also makes use of the `Retry-After` HTTP header so, in short, if the API says "hey please wait 33 seconds" that's what the waiting time will be.[^1]

To learn more about `httr::RETRY()`, head over to [its docs](https://httr.r-lib.org/reference/RETRY.html) and [source code](https://github.com/r-lib/httr/blob/master/R/retry.R)

A wild-caught example of a CRAN package using `httr::RETRY()` is the [`antanym` package](https://github.com/ropensci/antanym/blob/c52f26b65feb7a4f2983ea47ae84e8e2f98f936f/R/load.R#L191), whose `RETRY()` use can be traced back to [a peer-review of the package ](https://github.com/ropensci/software-review/issues/198#issuecomment-384070245) by [Lorenzo Busetto](https://github.com/lbusett) for [rOpenSci](http://ropensci.org/software-review).


### Retry in crul

_What is `crul`? `crul` is an R client organized around R6 classes._

The [retry method for `crul` `HttpClient` class](https://docs.ropensci.org/crul/reference/HttpClient.html#method-retry) was [modeled after `httr`'s `RETRY()`](https://github.com/ropensci/crul/pull/95). I replaced my homegrown retrying code with it [in a pull request](https://github.com/ropensci/ropenaq/pull/50). 

`crul`'s retrying has two interesting differences with `httr`'s retrying:

* It does not wrap the HTTP calls in `tryCatch` so the only errors it handles gracefully are _HTTP errors_.

* It offers the possibility to use a callback function, _"if the request will be retried and a wait time is being applied. The function will be passed two parameters, the response object from the failed request, and the wait time in seconds."_. For instance before retrying maybe you could query an API status endpoint if such a thing exists.

To learn more about `crul`'s `retry` method, head over to [its docs](https://docs.ropensci.org/crul/reference/HttpClient.html#method-retry) and [source code](https://github.com/ropensci/crul/blob/master/R/client.R#L388-L430).

## On not reinventing the wheel

Once I heard about `httr::RETRY()` and the `crul` `retry` method, I was a bit disappointed at having reinvented the wheel. 
Could one avoid doing that too often?

<!--html_preserve--> {{< figure src = "https://http.cat/302.jpg" width = "400" alt = "An illustration of the 302 HTTP status code (Found) showing a cat carried by a firefighter" link = "https://http.cat/302" >}}<!--/html_preserve-->

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

Lastly, you might even _want_ to create your own (better) version, which is obviously neat. :sunglasses:

### How to help users of your package not reinvent the wheel

As the developer of a package, you might help users find useful features by... working on its docs.
A good time investment could be to create a [`pkgdown`](https://pkgdown.r-lib.org/) website with a [well-organized reference index](https://pkgdown.r-lib.org/articles/pkgdown.html#reference-1).

Furthermore, some features could be added to your package if they're often implemented downstream.

## Conclusion

In this post we've presented useful functions implementing retries for API packages in `httr` and `crul`.

<!--html_preserve--> {{< figure src = "https://http.cat/426.jpg" width = "400" alt = "An illustration of the 426 HTTP status code (Upgrade Required) showing a cat in a too small box" link = "https://http.cat/302" >}}<!--/html_preserve-->

We've also discussed ways to not miss such useful shortcuts for one's code, mostly by learning more about existing R packages, whilst acknowledging such exploration takes time.
What's _your_ favorite lesser known package gem or R "joygret" moment[^2]?

[^1]: If your only worry is rate limiting and there are no requests happening at the same time, you might find the [`ratelimitr` package](https://cran.r-project.org/web/packages/ratelimitr/index.html) handy to avoid getting 429 status codes.
[^2]: _joygret_ was defined by [Hilary Parker in a blog post about writing R packages](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) as _"that familiar feeling of the joy of optimization combined with the regret of past inefficiencies"_
