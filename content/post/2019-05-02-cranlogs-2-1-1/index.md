---
title: cranlogs 2.1.1 is on CRAN!
date: '2019-05-02'
slug: cranlogs-2-1-1
authors:
  - Maëlle Salmon
tags:
  - cranlogs
  - R package
  - release
---

Version 2.1.1 of the `cranlogs` package has been [released on CRAN](https://cran.r-project.org/package=cranlogs)!
`cranlogs` queries a [web API maintained by R-hub](https://github.com/r-hub/cranlogs.app#the-api-of-the-cran-downloads-database) that contains the daily download numbers for each package and for R itself from the RStudio CRAN mirror.
:chart_with_upwards_trend:

Get `cranlogs`'s latest version from CRAN, hopefully from RStudio CRAN mirror so we can monitor counts.
:wink:

``` r
install.packages("cranlogs", repos = "https://cran.rstudio.com/")
```

The [changes brought by this version](https://r-hub.github.io/cranlogs/news/index.html#cranlogs-2-1-1) mostly are a few docs and bug fixes :wave: :bug:, but also the addition of a brand-new function simplifying your use of cranlogs badges, [`cranlogs_badge()`](https://r-hub.github.io/cranlogs/reference/cranlogs_badge.html)!
Since it is the first time we blog about `cranlogs` after its transfer to R-hub, we shall use the rest this blog post as an introduction to it.

### `cranlogs`, how and why?

### `cranlogs` data source and its quality

[RStudio](http://www.rstudio.com) publishes the download logs from their CRAN package mirror daily at <http://cran-logs.rstudio.com>.
The `cranlogs` package queries a [web API maintained by R-hub](https://github.com/r-hub/cranlogs.app#the-api-of-the-cran-downloads-database) that contains the daily download numbers for each package.

The RStudio CRAN mirror is not the only CRAN mirror, but it's a popular one: it's the default choice for RStudio users.
The actual number of downloads over all CRAN mirrors is unknown.
Therefore, using numbers of downloads from that mirror is a *proxy* for actual numbers of downloads, and when analysing it one has to assume the observed trends are representative of what happens via other mirrors.

The data `cranlogs` queries has other limitations such as re-download/CRAN mirror spikes due to package updates that can be corrected, if you want, by the use of the [`adjustedcranlogs` package](https://github.com/tylermorganwall/adjustedcranlogs) by Tyler Morgan-Wall.
Refer to that package documentation and code to find out more about it adjusts the download counts.
For another type of context information about the download counts, refer to the brand-new and in development [`packageRank`](https://github.com/lindbrook/packageRank) package by lindbrook that provides *ranks* for packages.

### `cranlogs` use cases

Now, *why* would you even be interested in the download counts of packages and R?
As a package maintainer, is it only egosurfing?

Probably not, such data can be useful:

-   As the developer, you can e.g. assess effect of promotion efforts, and maybe use proof of your package's popularity in career reports?
    (Note that it is perfectly fine to maintain a small niche package! `cranlogs` itself is no `ggplot2`. :wink:)

-   As the potential user, you can use download counts to compare popularity of packages you're hesitating to use.
    Again, quality does not necessitate popularity but a higher usage can be a good sign, in particular a good sign of the probability to get help from other users.

-   You could also use download counts as a way to summarize the "most important" packages around a topic, like what Zev Ross did below with spatial packages (the code attached to the tweet, [available as a GitHub gist](https://gist.github.com/zross/b64657b05156d43cf81dbdd093df5c13), uses the list of packages of the [spatial CRAN task view](https://cran.r-project.org/web/views/Spatial.html), get their downloads with `cranlogs`, and sort them by popularity).
    Note that the [R-hub `pkgsearch` package returns the downloads of last month for search results](https://r-hub.github.io/pkgsearch/)!

<!--html_preserve-->{{% tweet user="zevross" id="1123204696141963264" %}}<!--/html_preserve-->

# How to use `cranlogs`?

We shall first show how to use `cranlogs` from within R.

### Most popular packages

The package has two functions to get downloads, one to query downloads by package name (with "R" giving downloads for R itself), one to query downloads for the top `count` downloaded packages from the RStudio CRAN mirror.
So, what were the most popular packages over the last month?

``` r
cranlogs::cran_top_downloads(when = "last-month")
```

    ##    rank    package   count       from         to
    ## 1     1      rlang 1031362 2019-03-31 2019-04-29
    ## 2     2       Rcpp  888903 2019-03-31 2019-04-29
    ## 3     3      dplyr  822528 2019-03-31 2019-04-29
    ## 4     4   devtools  818129 2019-03-31 2019-04-29
    ## 5     5    ggplot2  811036 2019-03-31 2019-04-29
    ## 6     6     tibble  775563 2019-03-31 2019-04-29
    ## 7     7 data.table  721868 2019-03-31 2019-04-29
    ## 8     8       glue  664281 2019-03-31 2019-04-29
    ## 9     9        cli  655877 2019-03-31 2019-04-29
    ## 10   10     pillar  637211 2019-03-31 2019-04-29

Were these packages the ones you expected?

The `when` argument can take 3 values: "last-day" is the last day for which data is available (often two days before today), "last-week" is from 6 days prior to that last day with data, "last-month" is from 29 days prior to that last day with data.

### Downloads of `cranlogs` itself

Let's have a look at the downloads of a much less popular package, `cranlogs`!
:sunglasses: The `cranlogs::cran_downloads()` function also has the `when` argument, but you can also specify a more flexible interval by using `from` and `to`, both either dates or a string in the yyyy-mm-dd format.
Below we're setting `from` to "2015-05-07" because that's when `cranlogs` was first released on CRAN.

``` r
library("ggplot2")
dl <- cranlogs::cran_downloads("cranlogs",
                               from = "2015-05-07",
                               to = "2019-04-24")

ggplot(dl, aes(date, count)) +
  geom_point() +
  geom_smooth() +
  viridis::scale_colour_viridis(discrete = TRUE) +
  theme_minimal() +
  hrbrthemes::theme_ipsum(base_size = 16,
                          axis_title_size = 16) +
  xlab("Time") +
  ylab("No. of downloads") +
  ggtitle("Daily count of downloads of the R-hub cranlogs package",
          subtitle = "Downloads from the RStudio CRAN mirror. Data queried with {cranlogs} itself ;-)")
```

{{< figure src="cranlogs-dl-1.png" alt="Time series of cranlogs downloads showing a few dozens of downloads a day, with an upward trend since 2018." width="672" caption="Figure 1 Time series of cranlogs downloads showing a few dozens of downloads a day, with an upward trend since 2018." >}}

These aren't huge download counts, but there's an upward trend!
More awareness of the package existence, or more package developers egosurfing?
:surfer: :wink:

### `cranlogs` on the web

If you wish to have a quick look at downloads count time series without even firing up your own R session, you can use [Hadley Wickham's online handy Shiny app](https://hadley.shinyapps.io/cran-downloads/), whose [source code](https://github.com/hadley/cran-downloads) uses `cranlogs`.

# cranlogs badges, or how to show off usage

Are you into README badges?
You can add a `cranlogs` badge for each of your packages!
cranlogs badges [were the third most popular type of badges in a sample of CRAN packages studied in an rOpenSci tech note](https://ropensci.org/technotes/2018/09/10/github-badges/#what-are-the-most-common-badges).
You can tweak two aspects of the badges: the time period over which to compute the number of downloads, and the color of the badge.
To create the Markdown code for the badge, you could use the [`badger` package](https://cran.r-project.org/package=badger) or [`cranlogs::cranlogs_badge()`](http://r-hub.github.io/cranlogs/reference/cranlogs_badge.html)!

Below are some examples:

``` r
cranlogs::cranlogs_badge("cranlogs")
```

    ## [1] "[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/last-month/cranlogs?color=blue)](https://r-pkg.org/pkg/cranlogs)"

Resulting badge: [![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/last-month/cranlogs?color=blue)](https://r-pkg.org/pkg/cranlogs)

``` r
cranlogs::cranlogs_badge("cranlogs", summary = "grand-total")
```

    ## [1] "[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/grand-total/cranlogs?color=blue)](https://r-pkg.org/pkg/cranlogs)"

Resulting badge: [![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/grand-total/cranlogs?color=blue)](https://r-pkg.org/pkg/cranlogs)

Available colours *by name* are "brightgreen", "green", "yellowgreen", "yellow", "orange", "red", "lightgrey", "blue".

``` r
cranlogs::cranlogs_badge("cranlogs", summary = "last-week", 
                         color = "orange")
```

    ## [1] "[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/last-week/cranlogs?color=orange)](https://r-pkg.org/pkg/cranlogs)"

Resulting badge: [![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/last-week/cranlogs?color=orange)](https://r-pkg.org/pkg/cranlogs)

The colour can also be any hex code so there's no limit to your creativity (you might want to check [contrast](https://medium.com/@uistephen/text-contrast-for-web-pages-d685636c0749), though).
:rainbow:

``` r
cranlogs::cranlogs_badge("cranlogs", color = "ff8c69")
```

    ## [1] "[![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/last-month/cranlogs?color=ff8c69)](https://r-pkg.org/pkg/cranlogs)"

Resulting badge: [![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/last-month/cranlogs?color=ff8c69)](https://r-pkg.org/pkg/cranlogs)

# Conclusion

In this post we've presented the `cranlogs` package that makes download counts from RStudio CRAN mirror available in R.
The web API that powers it is used by another packages, [`dlstats`](https://cran.r-project.org/web/packages/dlstats/index.html) by Guangchuang Yu that also features Bioconductor download stats.

The best place to get to know `cranlogs` is [its brand-new documentation website built with `pkgdown`](https://r-hub.github.io/cranlogs), and the best place to provide feedback or contribute is [its GitHub repo](https://github.com/r-hub/cranlogs).
Also feel free to report your use cases via [gitter](https://gitter.im/r-hub/community) or [Twitter](https://twitter.com/rhub_)!
Thanks to all folks who chimed in in the issue tracker and pull request tab!
