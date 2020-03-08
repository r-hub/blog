---
slug: packageRank-intro
title: "'packageRank': Introduction and Caveat"
authors:
  - lindbrook
date: 2020-03-01
tags:
- package development
output:
  html_document:
    keep_md: true
---


'packageRank', [CRAN](https://cran.r-project.org/package=cholera) and [GitHub](https://www.github.com/lindbrook/packageRank), is an R package that helps you compute and visualize package download counts. It has two core functions: `cranDownloads()` and `packageRank()`.[^1] In this post, I'll do a brief overview of the package's features and of the systematic positive bias that affects download counts.

The package began as an effort to numerically and visually put a package's download counts into perspective: to see how well your package is really doing, you need to see how well (all) other packages are doing. One thing led to another in terms of features and functionality. But it was my hope of using this package to create an index of the state and health of R and its ecosystem(s) that led me to put this package on CRAN.

Note that throughout this blog plot post, I'll refer to _active_ and _inactive_ packages: the former are packages that are still being developed and that appear in the [CRAN repository](https://cran.r-project.org/web/packages/index.html); the latter are "retired" package that are stored in the [Archive](https://cran.r-project.org/src/contrib/Archive) along with past versions of active packages .

## `cranDownloads()`

`cranDownloads()` builds on [`cranlogs::cran_downloads()`](http://r-hub.github.io/cranlogs/). It uses all the same arguments:


```r
cranlogs::cran_downloads(packages = "HistData")
```
```
        date count  package
1 2020-03-03   359 HistData
```
<br/>
```r
cranDownloads(packages = "HistData")
```
```
        date count  package
1 2020-03-03   359 HistData
```

But it adds four features:

### "spell check" for package names

```r
cranDownloads(packages = "ggplot")
```
```
## Error in cranDownloads(packages = "ggplot") :
##   ggplot: misspelled or not on CRAN.
```
<br/>
```r
cranDownloads(packages = "ggplot2")
```

```
        date count package
1 2020-03-03 50320 ggplot2
```

For inactive packages, this is optional because it currently requires scraping the CRAN website:


```r
cranDownloads(packages = "vr", check.archive = TRUE)
```
```
## Error in cranDownloads(packages = "vr", check.archive = TRUE) :
##  vr: misspelled or not on CRAN/Archive.
```


```r
cranDownloads(packages = "VR", check.archive = TRUE)
```

```
        date count package
1 2020-03-03    17      VR
```

### two additional date formats

In addition to "yyyy-mm-dd", you can also use "yyyy-mm" or "yyyy" (yyyy works too!). This provides convenient and useful shortcuts.


##### "yyyy-mm"

Let's say you want the June 2019 download counts for 'HistData'. With `cranlogs::cran_downloads()`, you'd have to type out the whole date and remember that June has only 30 days:


```r
cranlogs::cran_downloads(packages = "HistData", from = "2019-06-01", to = "2019-06-30")
```

With `cranDownloads()`, you can just specify the year and month:


```r
cranDownloads(packages = "HistData", from = "2019-06", to = "2019-06")
```

"yyyy-mm" also automatically takes care of leap days:


```r
# The first will have 28 observations (rows); the second will have 29.
cranDownloads(packages = "HistData", from = "2019-02", to = "2019-02")
cranDownloads(packages = "HistData", from = "2020-02", to = "2020-02")
```

##### "yyyy"

Let's say you want the year-to-date download counts for 'rstan'. With `cranlogs::cran_downloads()`, you'd type:


```r
cranlogs::cran_downloads(packages = "HistData", from = "2020-01-01", to = Sys.Date() - 1)
```

With `cranDownloads()`, you can just type:


```r
cranDownloads(packages = "HistData", from = "2020")
```

### check dates

`cranDownloads()` will also try to check for valid dates:


```r
cranDownloads(packages = "HistData", from = "2019-01-15", to = "2019-01-35")
```
```
## Error in resolveDate(to, type = "to") : Not a valid date.
```

### visualization

To visualize `cranDownloads()`, use `plot()`:

<!-- # ```{r cranDownloads_viz1, fig.width = 5, fig.height = 5, fig.align = "center", fig.cap = "Figure 1 'HistData' Year-to-Date Downloads"} -->

```r
plot(cranDownloads(packages = "HistData", from = "2020"))
```

{{<figure src="cranDownloads_viz1-1.png" caption="Figure 1 'HistData' Year-to-Date Downloads" width="400" height="400">}}

{{<figure src="cranDownloads_viz1-1.png" caption="Figure 1 'HistData' Year-to-Date Downloads" width="64"0 height="640">}}

{{<figure src="cranDownloads_viz1-1.png" caption="Figure 1 'HistData' Year-to-Date Downloads">}}

When you pass a vector of package names, the function will, by default, make use of `ggplot2` facets:

<!-- ```{r cranDownloads_viz2, fig.width = 5, fig.height = 5, fig.align = "center", fig.cap = "Figure 2 Multiple Package Year-to-Date Downloads"} -->

```r
plot(cranDownloads(packages = c("ggplot2", "data.table", "Rcpp"), from = "2020"))
```

{{<figure src="cranDownloads_viz2-1.png" caption="Figure 2 Multiple Package Year-to-Date Downloads" width="400" height="400">}}

## `packageRank()` and population plot

To see whether the patterns you see above are typical or atypical, 'packageRank' provides two ways to locate your package in the overall distribution of package downloads: `packageRank()` and a population plot.

### `packageRank()`

In contrast to `cranDownloads()`, `packageRank()` uses ranks and rank percentiles instead of counts.

The rank percentiles, a measure that will be familiar to anyone who's taken a standardized test like the SAT or GRE, is the percentage of packages that have fewer downloads than yours. For example, on January 1, 2020 'HistData''s 90 downloads put it in the 93rd percentile: 93% of packages had fewer than 90 downloads.


```r
packageRank(packages = "HistData", date = "2020-01-01")
```

```
        date packages downloads percentile            rank
1 2020-01-01 HistData        90       93.5 1,143 of 17,696
```

You can visualize the results using plot().


```r
plot(packageRank(packages = "HistData", date = "2020-01-01"))
```
<!-- ```{r packageRank_plot_code, fig.width = 5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 3 'HistData' Position in the Distribution of Package Downloads, 01 January 2020"} -->
{{<figure src="packageRank_plot_code-1.png" caption="Figure 3 'HistData' Position in the Distribution of Package Downloads, 01 January 2020" width="400" height="400">}}

The graph plots the rank of the download count for _all_ packages downloaded that day (x-axis) against the natural log of those counts (y-axis). It then highlights your package's position in that distribution along with its rank percentile and download count (in red). In the background, you'll see the location of the 75th, 50th and 25th percentiles (dotted gray vertical lines); the package with the most downloads, 'magrittr' (in blue, top left); and the total number of downloads (2,254,532) (in blue, top right).

### population plot

The population plot provides a way to visually estimate the overall distribution of CRAN package downloads. It does so by fitting lowess curves to the download counts of a stratified random sample of packages.[^2] You simply set the `population.plot` argument to TRUE:[^3]

<!-- ```{r pop_plot, fig.width = 5, fig.height = 5, fig.align = "center", fig.cap = "Figure 4 'HistData' Population Plot"} -->

```r
plot(cranDownloads(packages = "HistData", when = "last-month"), population.plot = TRUE)
```

{{<figure src="pop_plot-1.png" caption="this is what this image shows, write it here or in the paragraph after the image as you prefer" width="400" height="400">}}

## caveat: positive bias in download counts

A systematic positive bias affects package download counts. This bias manifests itself as two types of "invalid" downloads: 1) downloads that are "too small"; and 2) an overrepresentation of past versions. These "invalid" downloads undermine the strategy of counting package downloads by counting the number of entries in the download logs.

What makes these downloads especially problematic is that, as part of efforts to mirror or download CRAN in its entirety, they are particularly numerous on Wednesdays (and additional days). Depending on what you're trying to do, this could affect your analyses and inferences. Fortunately, I think we can minimize their effect by cleaning the data by filtering out "small" downloads and by filtering out or discounting past versions.

To understand this bias, you should look at actual download logs. RStudio's logs are available [here](http://cran-logs.rstudio.com/). You can also access them using `packageRank::packageLog()`. Below is the log for 'cholera' for February 2, 2020:


```r
packageLog(package = "cholera", date = "2020-02-02")
```

```
         date     time    size package version country ip_id
1  2020-02-02 03:25:16 4156216 cholera   0.7.0      US 10411
2  2020-02-02 04:24:41 4165122 cholera   0.7.0      CO  4144
3  2020-02-02 06:28:18 4165122 cholera   0.7.0      US   758
4  2020-02-02 07:57:22 4292917 cholera   0.7.0      ET  3242
5  2020-02-02 10:19:17 4147305 cholera   0.7.0      US  1047
6  2020-02-02 10:19:17   34821 cholera   0.7.0      US  1047
7  2020-02-02 10:19:17     539 cholera   0.7.0      US  1047
8  2020-02-02 10:55:22     539 cholera   0.2.1      US  1047
9  2020-02-02 10:55:22 3510325 cholera   0.2.1      US  1047
10 2020-02-02 10:55:22   65571 cholera   0.2.1      US  1047
11 2020-02-02 11:25:30 4151442 cholera   0.7.0      US  1047
12 2020-02-02 11:25:30     539 cholera   0.7.0      US  1047
13 2020-02-02 11:25:30   14701 cholera   0.7.0      US  1047
14 2020-02-02 14:23:57 4165122 cholera   0.7.0    <NA>     6
15 2020-02-02 14:51:10 4298412 cholera   0.7.0      US     2
16 2020-02-02 17:27:40 4297845 cholera   0.7.0      US     2
17 2020-02-02 18:44:10 4298744 cholera   0.7.0      US     2
18 2020-02-02 23:32:13   13247 cholera   0.6.0      GB    20
```

### "small" downloads

Entries 5 through 7 of that log illustrate the "small" downloads problem:



```
        date     time    size package version country ip_id
5 2020-02-02 10:19:17 4147305 cholera   0.7.0      US  1047
6 2020-02-02 10:19:17   34821 cholera   0.7.0      US  1047
7 2020-02-02 10:19:17     539 cholera   0.7.0      US  1047
```

Notice the differences in size: 4.1 MB, 35 kB and 539 B. On CRAN, the source and binary files of 'cholera' are either a [4.0 or a 4.1 MB \*.tar.gz file](https://cran.r-project.org/src/contrib/Archive/cholera/). In short, the problem with "small" downloads is that we end up overcounting the number of actual downloads.

While I'm unsure about the kB-sized entry (it may be a side effect of caching or an incomplete download), my current understanding is that ~500 B downloads represent [HTTP HEAD requests from lftp](https://github.com/r-hub/cranlogs/issues/45). The earliest example I've found goes back to "2012-10-17" (Note that RStudio's download logs only go back to "2012-10-01".). While these "small" downloads aren't always paired with "complete" downloads, their frequency is such that I wonder whether `lftp` or something similar is/was part of the R and/or RStudio.

To get a sense of their frequency, I look back to October 2019. In aggregate, ~500 B downloads account for approximately 2% of the total. While this seems modest (if 2.5 million downloads could be modest), I'd argue that there's actually something lurking underneath: a closer look reveals that the difference between the total and filtered (without ~500 B entries) is greatest on the five Wednesdays.

<!-- ```{r counts_plot, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 5 Total CRAN Downloads With and Without ~500 B Entries"} -->
{{<figure src="counts_plot-1.png" alt="alternative text please make it informative" title="title of the image" caption="Figure 5 Total CRAN Downloads With and Without ~500 B Entries" width="520" height="400">}}

To see what's going on, I switch the unit of observation from download counts to the number of unique packages downloaded:

<!-- ```{r packages_plot, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 6 Total Number of Unique Packages Downloaded from CRAN With and Without ~500 B Entries"} -->
{{<figure src="packages_plot-1.png" caption="Figure 6 Total Number of Unique Packages Downloaded from CRAN With and Without ~500 B Entries" width="520" height="400">}}

Doing so, we see that on Wednesdays (+3 days) the total number of unique packages downloaded tops 17,000. This is significant because it exceeds the 15,000+ active packages on CRAN (see the latest count [here](https://cran.r-project.org/web/packages/index.html)). The only way to hit 17,000+ would be to include some, if not all, of the 2,000+ inactive packages. Based on this, I'd say that on those peak days virtually, if not literally, all active and inactive packages on CRAN were downloaded.[^4]

### past versions

This actually understates what's going on. It's not just that "all" packages are being downloaded but that "all" versions of "all" packages are being downloaded. This is what leads me to argue that there's an overrepresentation of past versions. Here, I'm not referring to downloads done for compatibility or research, which one would think would be random and infrequent. Instead, I'm talking about seeing regular and repeated patterns like this:


```r
packageLog(packages = "cholera", date = "2019-10-22")[1:8, ]
```

```
        date     time    size package version country  ip_id
1 2019-10-22 04:17:09 4158481 cholera   0.7.0      US 110912
2 2019-10-22 08:00:56 3797773 cholera   0.2.1      CH  24085
3 2019-10-22 08:01:06 4109048 cholera   0.3.0      UA  10526
4 2019-10-22 08:01:28 3764845 cholera   0.5.1      RU   7828
5 2019-10-22 08:01:33 4284606 cholera   0.6.5      RU  27794
6 2019-10-22 08:01:39 4275828 cholera   0.6.0      DE   6214
7 2019-10-22 08:01:43 4285678 cholera   0.4.0      RU   5721
8 2019-10-22 08:01:46 3766511 cholera   0.5.0      RU  15119
```

On this day, eight versions of 'cholera' were downloaded. A little digging with `packageRank::packageHistory()` will reveal that these eight versions represent all the versions that were available that day:


```r
packageHistory("cholera")
```

```
  package version       date repository
1 cholera   0.2.1 2017-08-10    Archive
2 cholera   0.3.0 2018-01-26    Archive
3 cholera   0.4.0 2018-04-01    Archive
4 cholera   0.5.0 2018-07-16    Archive
5 cholera   0.5.1 2018-08-15    Archive
6 cholera   0.6.0 2019-03-08    Archive
7 cholera   0.6.5 2019-06-11    Archive
8 cholera   0.7.0 2019-08-28       CRAN
```

Showing that "all" versions are being downloaded is not as easy as showing the effect of "small" downloads. To do so, you'd need to the version history of all packages. This is currently a computationally expensive task.[^5] For this post, I'm relying on a random sample of 100 active and 100 inactive packages.

The graph below plots the percent of versions downloaded for each day in October 2019 (IDs 1-100 are _active_ packages; IDs 101-200 are inactive _packages_). On the five Wednesdays (+ 3 additional days), there's a horizontal line at 100% that indicates that all versions of the packages in the sample were downloaded.[^6]

<!-- ```{r versions_plot, fig.align = "center", echo = FALSE, fig.cap = "Figure 7 Percent of Versions Downloaded for 100 Active & 100 Inactive Packages"} -->
{{<figure src="versions_plot-1.png" caption="Figure 7 Percent of Versions Downloaded for 100 Active & 100 Inactive Packages" width="520" height="400">}}

### solutions

To minimize this bias we could filter out "small" downloads and past versions. Filtering out 500 B downloads is simple and straightforward (`packageRank()` and `packageLog()` already include this functionality). My [understanding](https://github.com/r-hub/cranlogs/issues/45#issuecomment-553874788) is that there may be plans to do this in 'cranlogs' as well. Filtering out other "small" downloads is more involved but not impossible. You just need the size of "valid" downloads. Filtering out "past" versions is more complicated since you not only need to know which version is current, you probably also want a way to discount rather than simply exclude previous version(s).

Whether you should worry about this depends on what you're trying to do. It also depend on the package you're interested in. This is because the bias is variable, a function of a package's "popularity" (i.e, its number of "valid" downloads) and the number of versions of package has. A package with more "real" downloads will be less affected than one with fewer "real" downloads because the bias gets diluted (typically "real" interest is greater than "artificial" interest). A package with more versions will be more affected because as CRAN in its entirety is being downloaded, a package with more versions will record more downloads than one with fewer versions.

#### popularity

To illustrate the effect of popularity, I compare 'ggplot2' and 'cholera'. With one million plus downloads, 500 B entries inflate the download count for 'ggplot2' by 2%:

<!-- ```{r ggplot2, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 8 Effect of ~500 B Downloads on Download Counts for a Popular Package"} -->
{{<figure src="ggplot2-1.png" caption="Figure 8 Effect of ~500 B Downloads on Download Counts for a Popular Package" width="520" height="400">}}

With under 400 downloads, 500 B entries inflate the download count for 'cholera' by 25%:

<!-- ```{r cholera, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 9 Effect of ~500 B Downloads on Download Counts for an Unpopular Package"} -->
{{<figure src="cholera-1.png" caption="Figure 9 Effect of ~500 B Downloads on Download Counts for an Unpopular Package" width="520" height="400">}}

#### number of versions

To illustrate the effect of the number of versions, I compare 'cholera', an active package with 8 versions, and 'VR', an inactive package last updated in 2009 with 92 versions. In both cases, I filter out all downloads except for those the most recent version.

With 'cholera', the past version inflate the download count by 27%:

<!-- ```{r cholera_version, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 10 Effect of the Number of Past Versions on Download Counts for a Package with Few Versions"} -->
{{<figure src="cholera_version-1.png" caption="Figure 10 Effect of the Number of Past Versions on Download Counts for a Package with Few Versions" width="520" height="400">}}

For 'VR', past version inflated the download count by 7,500%:

<!-- ```{r vr_version, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 11 Effect of the Number of Past Versions on Download Counts for a Package with Many Versions"} -->
{{<figure src="vr_version-1.png" caption="Figure 11 Effect of the Number of Past Versions on Download Counts for a Package with Many Versions" width="520" height="400">}}

#### popularity & versions

To illustrate the joint effect of both ~500 B downloads and previous versions, I use 'cholera'. Here, we see that the joint effect of both biases inflate the download count by 31%:

<!-- ```{r cholera_size.version, fig.width = 6.5, fig.height = 5, fig.align = "center", echo = FALSE, fig.cap = "Figure 12 Effect of ~500 B Downloads and Number of Past Versions on Download Counts"} -->
{{<figure src="cholera_size.version-1.png" caption="Figure 12 Effect of ~500 B Downloads and Number of Past Versions on Download Counts" width="520" height="400">}}

Even though the bias is pretty mechanical and deterministic, to show that examples above are not idiosyncratic, I conclude with a back-of-the-envelope estimate of the effect of popularity (unfiltered downloads) and version count (total number of versions) on total bias (the percent change in download counts after filtering out ~500 B download and prior versions). The sample of 200 active and inactive packages used above is my data. I fit a linear model using the natural log of the three variables. The hope is that signs are right: bias is negatively related to popularity and positively related to the number of versions.




```

Call:
lm(formula = log(bias) ~ log(popularity) + log(versions) + log(popularity) *
    log(versions), data = p.data)

Residuals:
     Min       1Q   Median       3Q      Max
-1.15194 -0.29496 -0.07894  0.18592  2.53147

Coefficients:
                              Estimate Std. Error t value Pr(>|t|)
(Intercept)                    6.89264    0.10981  62.768   <2e-16 ***
log(popularity)               -0.92101    0.02471 -37.280   <2e-16 ***
log(versions)                  0.98727    0.07625  12.948   <2e-16 ***
log(popularity):log(versions)  0.02570    0.01458   1.763   0.0794 .
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.5038 on 195 degrees of freedom
Multiple R-squared:  0.9567,	Adjusted R-squared:  0.956
F-statistic:  1435 on 3 and 195 DF,  p-value: < 2.2e-16
```

## Notes

[^1]: Similar but limited functionality is available for Bioconductor packages using `bioconductorDownloads()` and `bioconductorRank()`.
[^2]: I take a random sample of 5% of the packages within each of the twenty 5 percentile bins between between 0 and 1: between 0 and 0.05, 0.05 and 0.10, etc.
[^3]: Because this is computationally intensive, this is only available for `when = "last-week"` or `when = "last-month"`.
[^4]: The slight upward trend in the peaks probably reflects the addition of new packages during the month.
[^5]: `packageHistory()` currently scrapes the CRAN website.
[^6]: On 22 October 2019, there are two exceptions among inactive packages, 'UScensus2000blkgrp' and 'msDilution', which had zero downloads.
