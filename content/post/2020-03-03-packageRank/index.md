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


> This post was contributed by [Peter Li](https://www.github.com/lindbrook/). Thank you, Peter!

[`'packageRank'`](https://cran.r-project.org/package=packageRank)' is an R package that helps put package download counts into context. It does so via two functions, `cranDownloads()` and `packageRank()`.[^1]

`cranDownloads()` extends [`cranlogs::cran_downloads()`](http://r-hub.github.io/cranlogs/) package by adding a `plot()` method and a more user-friendly interface to the task of counting package downloads. `packageRank()` uses rank percentiles, a nonparametric statistic that tells you the percentage of packages with fewer downloads, to help you see how your package is doing compared to all other packages on [CRAN](https://cran.r-project.org/).

In this post, I'll do two things. First, I'll give an overview of the package's features and functions. Second, I'll discuss the systematic positive bias that affects download counts.

Note that in this post, I'll refer to _active_ and _inactive_ packages: the former are packages that are still being developed and appear in the [CRAN repository](https://cran.r-project.org/web/packages/index.html); the latter are "retired" packages that are stored in the [Archive](https://cran.r-project.org/src/contrib/Archive) along with past versions of active packages.

******

# `cranDownloads()`

`cranDownloads()` uses all the same arguments as `cranlogs::cran_downloads()`:


```r
cranlogs::cran_downloads(packages = "HistData")
```

```
        date count  package
1 2020-04-04   249 HistData
```

<br/>


```r
cranDownloads(packages = "HistData")
```

```
        date count  package
1 2020-04-05     0 HistData
```

<br/>
The only difference is that `cranDownloads()` adds four features:
<br/>

## "spell check" package names


```r
cranDownloads(packages = "GGplot2")
```
```
## Error in cranDownloads(packages = "GGplot2") :
##   GGplot2: misspelled or not on CRAN.
```

<br/>

```r
cranDownloads(packages = "ggplot2")
```

```
        date count package
1 2020-04-05     0 ggplot2
```

<br/>
This also works for inactive packages in the [Archive](https://cran.r-project.org/src/contrib/Archive):

<br/>


```r
cranDownloads(packages = "vr")
```
```
## Error in cranDownloads(packages = "vr") :
##  vr: misspelled or not on CRAN/Archive.
```

<br/>

```r
cranDownloads(packages = "VR")
```

```
        date count package
1 2020-04-05     0      VR
```

<br/>

## additional date formats

In addition to "yyyy-mm-dd", you can also use "yyyy-mm" or "yyyy" (yyyy works too!). This provides convenient and useful shortcuts.

### "yyyy-mm"

Let's say you want the June 2019 download counts for [`'HistData'`](https://cran.r-project.org/package=HistData). With `cranlogs::cran_downloads()`, you'd have to type out the whole date and remember that June has only 30 days:


```r
cranlogs::cran_downloads(packages = "HistData", from = "2019-06-01",
  to = "2019-06-30")
```

<br/>
With `cranDownloads()`, you can just specify the year and month:


```r
cranDownloads(packages = "HistData", from = "2019-06", to = "2019-06")
```

<br/>
"yyyy-mm" will even take care of leap days:


```r
# 28 observations
cranDownloads(packages = "HistData", from = "2019-02", to = "2019-02")

# 29 observations
cranDownloads(packages = "HistData", from = "2020-02", to = "2020-02")
```

<br/>

### "yyyy"

Let's say you want the year-to-date download counts for [`'rstan'`](https://cran.r-project.org/package=rstan). With `cranlogs::cran_downloads()`, you'd type something like:


```r
cranlogs::cran_downloads(packages = "HistData", from = "2020-01-01",
  to = Sys.Date() - 1)
```

<br/>
With `cranDownloads()`, you can just type:


```r
cranDownloads(packages = "HistData", from = "2020")
```

<br/>

## check dates

`cranDownloads()` also tries to check for valid dates:


```r
cranDownloads(packages = "HistData", from = "2019-01-15",
  to = "2019-01-35")
```
```
## Error in resolveDate(to, type = "to") : Not a valid date.
```

<br/>

## visualization

To visualize `cranDownloads()`, use `plot()`:


```r
plot(cranDownloads(packages = "HistData", from = "2020"))
```

{{<figure src="cranDownloads_viz1-1.png" title="Figure 1 Year-to-Date Downloads for 'HistData' package">}}

<br/>
When you pass a vector of package names, `plot()` defaults to using `ggplot2` facets:


```r
plot(cranDownloads(packages = c("ggplot2", "data.table", "Rcpp"),
  from = "2020"))
```

{{<figure src="cranDownloads_viz2-1.png" title="Figure 2 Year-to-Date Downloads for Multiple Packages Using 'ggplot2' facets">}}

<br/>
If you want to plot all the data in a single plot, use `multi.plot = TRUE`:


```r
plot(cranDownloads(packages = c("ggplot2", "data.table", "Rcpp"),
  from = "2020"), multi.plot = TRUE)
```

<br/>
If you want to plot the data in separate plots, use `graphics = "base"`:


```r
plot(cranDownloads(packages = c("ggplot2", "data.table", "Rcpp"),
  from = "2020"), graphics = "base")
```

******

# `packageRank()`

[`'packageRank'`](https://cran.r-project.org/package=packageRank) began as a collection of functions I wrote to gauge interest in the [`'cholera'`](https://cran.r-project.org/package=cholera) package. However, after looking the data for this and other packages the "compared to what?" question quickly comes to mind. For instance, consider the data for the first week of March 2020:


```r
plot(cranDownloads(packages = "cholera", from = "2020-03-01",
  to = "2020-03-07"))
```

{{<figure src="motivation_code-1.png" title="Figure 3 Downloads for 'cholera' package for March 1-7, 2020">}}

Do the peaks on Wednesday and Saturday represent surges of interest in the package or surges of traffic to [CRAN](https://cran.r-project.org/)? To put it more broadly, how can we know if a given download count is typical or unusual?

One way to answer these questions is to locate your package in the frequency distribution of download counts. Below are the distributions for Wednesday and Saturday with the location of [`'cholera'`](https://cran.r-project.org/package=cholera) highlighted:

{{<figure src="skew_wed-1.png" title="Figure 4 Frequency Distribution of Package Downloads for March 4, 2020 (Wednesday)">}}

{{<figure src="skew_sat-1.png" title="Figure 5 Frequency Distribution of Package Downloads for March 7, 2020 (Saturday)">}}

Unfortunately, the frequency distribution of package downloads typically has an exponential and heavily skewed shape. The left side, where packages with fewer downloads are located, _looks_ like a vertical line. Using Wednesday as an example, this is a consequence of the fact that the most downloaded package had 177,745 downloads while the least downloaded package had just 1.

To help see what's going on, I redraw the plots using the logarithm of download counts (x-axis). In these plots, a vertical segment's position on the x-axis represents its download count while its height represents the number of packages that have that download count:




```r
plot(packageDistribution(package = "cholera", date = "2020-03-04"))
```
{{<figure src="packageDistribution_wed_code-1.png" title="Figure 6 Frequency Distribution of Package Downloads for March 4, 2020 (Wednesday) with Base 10 Logarithm of Download Counts">}}


```r
plot(packageDistribution(package = "cholera", date = "2020-03-07"))
```
{{<figure src="packageDistribution_sat_code-1.png" title="Figure 7 Frequency Distribution of Package Downloads for March 7, 2020 (Saturday) with Base 10 Logarithm of Download Counts">}}

While these plots give us a better picture of where [`'cholera'`](https://cran.r-project.org/package=cholera) is located, any comparison between Wednesday and Saturday is impressionistic at best: all we can confidently say is that the download counts for both days were above than the mode.

To address this, I compute the _rank percentile_ of download counts. This nonparametric statistic tells us the percentage of packages with fewer downloads than your package. By standardizing or normalizing download counts, we get an easy-to-interpret measure that also gives us a way to compare Wednesday and Saturday.


```r
packageRank(package = "cholera", date = "2020-03-04", size.filter = FALSE)
```

```
        date packages downloads percentile            rank
1 2020-03-04  cholera        38       67.9 5,556 of 18,038
```

<br/>


```r
packageRank(package = "cholera", date = "2020-03-07", size.filter = FALSE)
```

```
        date packages downloads percentile            rank
1 2020-03-07  cholera        29         80 3,061 of 15,950
```

On Wednesday, we can see that [`'cholera'`](https://cran.r-project.org/package=cholera) had 38 downloads and came in 5,556th place out of 18,038 unique packages downloaded. This earned [`'cholera'`](https://cran.r-project.org/package=cholera) a spot in the 68th percentile. On Saturday, we can see that [`'cholera'`](https://cran.r-project.org/package=cholera) had 29 downloads and came in 3,061st place out of 15,950 unique packages downloaded. This earned [`'cholera'`](https://cran.r-project.org/package=cholera) a spot in the 80th percentile. So contrary to what the nominal download counts tell us, one could argue that there was greater interest in [`'cholera'`](https://cran.r-project.org/package=cholera) on Saturday than on Wednesday.

<br/>

## computing rank percentiles

To compute the rank percentile, I do the following. For each package I first tabulate the number of downloads and then compute the percentage of packages with fewer downloads. Here are the details using [`'cholera'`](https://cran.r-project.org/package=cholera) from that Wednesday as an example:


```r
pkg.rank <- packageRank(packages = "cholera", date = "2020-03-04",
  size.filter = FALSE)

downloads <- pkg.rank$crosstab

round(100 * mean(downloads < downloads["cholera"]), 1)
```

```
[1] 67.9
```

```r
# OR

(pkgs.with.fewer.downloads <- sum(downloads < downloads["cholera"]))
```

```
[1] 12250
```

```r
(tot.pkgs <- length(downloads))
```

```
[1] 18038
```

```r
round(100 * pkgs.with.fewer.downloads / tot.pkgs, 1)
```

```
[1] 67.9
```

<br/>

## visualizing rank percentiles

To visualize `packageRank()`, use `plot()`.


```r
plot(packageRank(packages = "cholera", date = "2020-03-04"))
```



{{<figure src="packageRank_plot_code_wed-1.png" title="Figure 8 Rank Frequency Distribution of Package Downloads, March 4, 2020">}}

<br/>


```r
plot(packageRank(packages = "cholera", date = "2020-03-07"))
```

{{<figure src="packageRank_plot_code_sat-1.png" title="Figure 9 Rank Frequency Distribution of Package Downloads, March 7, 2020">}}

These graphs, customized to be on the same scale, plot the rank of the download count for _all_ packages downloaded that day (x-axis) against the base 10 logarithm of those counts (y-axis). It then highlights your package's position in the distribution along with its rank percentile and download count (in red). In the background, the 75th, 50th and 25th percentiles are plotted as dotted vertical lines; the package with the most downloads, which in both cases is [`'magrittr'`](https://cran.r-project.org/package=magrittr) (in blue, top left); and the total number of downloads, 5,561,681 and 3,403,969 respectively (in blue, top right).

<br/>

## computational performance and analytical limits

Unlike `cranlogs::cran_download()`, which benefits from server-side support (i.e., download counts are "pre-computed"), `packageRank()` needs to download the [logs from RStudio](http://cran-logs.rstudio.com/) and compute the ranks of download counts. This imposes a performance penalty and a limit on analysis.

While the performance penalty is mitigated by caching downloaded log files using the [`'memoise'`](https://CRAN.R-project.org/package=memoise) package, the analytic limitation is harder to overcome. Anything beyond a one-day cross-sectional comparison (e.g., rank percentiles over time) is "expensive"; you have to download all the needed log files, each of which can push 50 MB. If you want to compare ranks for a week, you'd have to download 7 log files. If you want to compare ranks for a month, you'd have to download 30 odd log files.

Nevertheless, as a proof-of-concept the plot below compares nominal download counts with their rank percentiles for [`'cholera'`](https://cran.r-project.org/package=cholera) for the first week in March:

{{<figure src="counts_ranks-1.png" title="Figure 10 A Comparison of Package Download Counts and Rank Percentiles">}}

******

# caveat: positive bias in download counts

Putting aside the elephant-in-the-room inflation (arguably) caused by package dependencies, a systematic positive bias affects package download counts. This bias manifests itself in two ways: 1) downloads that are "too small" and 2) an overrepresentation of prior versions. The former is, apparently, a software artifact. The latter is, I'll argue, a consequence of efforts to mirror or download CRAN in its entirety. These mirroring efforts are what makes both "invalid" types of downloads so problematic: numerically, they undermine our strategy of counting package downloads by counting entries in download logs; conceptually, they lead us to overestimate interest in a package.

This bias is variable. The greater a package's "true" popularity (i.e., the number of "real" downloads), the lower the bias. Essentially, the bias gets diluted. The greater the number of prior versions, the greater the bias. When all of CRAN is being downloaded, more versions means more package downloads. Fortunately, we can minimize the bias by filtering out "small" downloads, and by filtering out or discounting prior versions.[^2]

## download logs

To understand this bias, you should look at actual download logs. You can access RStudio's logs [directly](http://cran-logs.rstudio.com/) or via `packageRank::packageLog()`. Below is the log for [`'cholera'`](https://cran.r-project.org/package=cholera) for February 2, 2020:


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

<br/>

## "small" downloads

Entries 5 through 7 form the log above illustrate "small" downloads:



```
        date     time    size package version country ip_id
5 2020-02-02 10:19:17 4147305 cholera   0.7.0      US  1047
6 2020-02-02 10:19:17   34821 cholera   0.7.0      US  1047
7 2020-02-02 10:19:17     539 cholera   0.7.0      US  1047
```

Notice the differences in size: 4.1 MB, 35 kB and 539 B. On CRAN, the source and binary files of [`'cholera'`](https://cran.r-project.org/package=cholera) are [4.0 and 4.1 MB \*.tar.gz files](https://cran.r-project.org/src/contrib/Archive/cholera/). With "small" downloads, I'd argue that we end up overcounting the number of actual downloads.

While I'm unsure about the kB-sized entry (insights are welcome!), my current understanding is that ~500 B downloads are [HTTP HEAD requests from lftp](https://github.com/r-hub/cranlogs/issues/45). The earliest example I've found goes back to "2012-10-17" (RStudio's download logs only go back to "2012-10-01".). I've also noticed that, unlike the above example, "small" downloads aren't always paired with "complete" downloads.


To get a sense of their frequency, I look back to October 2019. In aggregate, ~500 B downloads account for approximately 2% of the total. While this seems modest (if 2.5 million downloads could be modest),[^3] I'd argue that there's actually something lurking underneath. A closer look reveals that the difference between the total and filtered (without ~500 B entries) counts is greatest on the five Wednesdays.

{{<figure src="counts_plot-1.png" title="Figure 11 Total Package Downloads from CRAN With and Without ~500 B Entries: October 2019">}}

<br/>
To see what's going on, I switch the unit of observation from download counts to the number of unique packages:

{{<figure src="packages_plot-1.png" title="Figure 12 Total Number of Unique Packages Downloaded from CRAN With and Without ~500 B Entries: October 2019">}}

Doing so, we see that on Wednesdays (+3 additional days) the total number of unique packages downloaded tops 17,000. This is significant because it exceeds the 15,000+ active packages on CRAN (go [here](https://cran.r-project.org/web/packages/index.html) for the latest count). The only way to hit 17,000+ would be to include some, if not all, of the 2,000+ inactive packages. Based on this, I'd say that on those peak days virtually, if not literally, all CRAN packages (both active _and_ inactive) were downloaded.[^4]

<br/>

## past versions

This actually understates what's going on. It's not just that "all" packages are being downloaded but that all versions of all packages are being regularly and repeatedly download. It's these efforts, rather than downloads done for reasons of compatibility or research, that lead me to argue that there's an overrepresentation of prior versions in the download logs.

As an example, see the first eight entries for [`'cholera'`](https://cran.r-project.org/package=cholera) in the October 22, 2019 log:


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

<br/>
These eight entries record the download of eight _different_ versions of [`'cholera'`](https://cran.r-project.org/package=cholera). A little digging with `packageRank::packageHistory()` reveals that eight different versions represent all the version available on that day:

<br/>


```r
packageHistory("cholera")
```

```
  Package Version       Date Repository
1 cholera   0.2.1 2017-08-10    Archive
2 cholera   0.3.0 2018-01-26    Archive
3 cholera   0.4.0 2018-04-01    Archive
4 cholera   0.5.0 2018-07-16    Archive
5 cholera   0.5.1 2018-08-15    Archive
6 cholera   0.6.0 2019-03-08    Archive
7 cholera   0.6.5 2019-06-11    Archive
8 cholera   0.7.0 2019-08-28       CRAN
```

Showing that "all" versions of all packages are being downloaded is not as easy as showing the effect of "small" downloads. For this post, I'm relying on a random sample of 100 active and 100 inactive packages.

The graph below plots the percent of versions downloaded for each day in October 2019 (IDs 1-100 are _active_ packages; IDs 101-200 are _inactive_ packages). On the five Wednesdays (+ 3 additional days), there's a horizontal line at 100% that indicates that all versions of the packages in the sample were downloaded.[^5]

<br/>

{{<figure src="versions_plot-1.png" title="Figure 13 Percent of Package-Versions Downloaded for 100 Active & 100 Inactive Packages: October 2019">}}

## solutions

To minimize this bias, we could filter out "small" downloads and past versions.

Filtering out 500 B downloads is simple and straightforward (`packageRank()` and `packageLog()` already include this functionality). My [understanding](https://github.com/r-hub/cranlogs/issues/45#issuecomment-553874788) is that there may be plans to do this in 'cranlogs' as well. Filtering out the other "small" downloads is a bit more involved because you'd need the size of a "valid" download.

Filtering out previous versions is more complicated. You'd not only need to know the current version, you'd probably also want a way to discount rather than to simply exclude previous version(s). This is especially when a package update occurs.

# Significance and Form of Bias

Should you be worried about this inflationary bias? In general, I think the answer is yes. The reason is that most of us use download counts to estimate of the amount of interest our packages attract and, more implicitly, to estimate our packages' importance and quality (witness all the badges displaying download counts on GitHub).

The bias undermines this relationship. It does so in variable, unequal fashion: the bias is a function of a package's "popularity" (i.e, the number of "valid" downloads) and the number of prior versions. A package with more "real" downloads will be less affected than one with fewer "real" downloads because the bias gets diluted (typically "real" interest is greater than "artificial" interest). A package with more versions will be more greatly affected because, especially if CRAN in its entirety is being downloaded, a package with more versions will record more downloads than one with fewer versions.

<br/>

## popularity


To illustrate the effect of popularity, I compare [`'ggplot2'`](https://cran.r-project.org/package=ggplot2) and [`'cholera'`](https://cran.r-project.org/package=cholera) for October 2019. With one million plus downloads, ~500 B entries inflate the download count for [`'ggplot2'`](https://cran.r-project.org/package=ggplot2) by 2%:

{{<figure src="ggplot2-1.png" title="Figure 14 Effect of ~500 B Downloads on Download Counts for a More Popular Package: October 2019">}}

With under 400 downloads, ~500 B entries inflate the download count for [`'cholera'`](https://cran.r-project.org/package=cholera) by 25%:

{{<figure src="cholera-1.png" title="Figure 15 Effect of ~500 B Downloads on Download Counts for a Less Popular Package: October 2019">}}

<br/>

## number of versions

To illustrate the effect of the number of versions, I compare [`'cholera'`](https://cran.r-project.org/package=cholera), an active package with 8 versions, and 'VR', an inactive package last updated in 2009, with 92 versions. In both cases, I filter out all downloads except for those of the most recent version.

With [`'cholera'`](https://cran.r-project.org/package=cholera), past versions inflate the download count by 27%:

{{<figure src="cholera_version-1.png" title="Figure 16 Effect of the Number of Prior Versions on Download Counts for a Package with Few Versions: October 2019">}}

With 'VR', past version inflate the download count by 7,500%:

{{<figure src="vr_version-1.png" title="Figure 17 Effect of the Number of Past Versions on Download Counts for a Package with Many Versions: October 2019">}}

<br/>

## popularity & versions

To illustrate the joint effect of both ~500 B downloads and previous versions, I again use [`'cholera'`](https://cran.r-project.org/package=cholera). Here, we see that the joint effect of both biases inflate the download count by 31%:

{{<figure src="cholera_size.version-1.png" title="Figure 18 Effect of ~500 B Downloads and Number of Past Versions on Download Counts: October 2019">}}

## OLS estimate

Even though the bias is pretty mechanical and deterministic, to show that examples above are not idiosyncratic, I conclude with a back-of-the-envelope estimate of the general effect of popularity (unfiltered downloads) and version count (total number of versions) on total bias (the percent change in download counts after filtering out ~500 B download and prior versions).

I reuse the sample of 200 active and inactive packages as the data and fit a linear model using the base 10 log of all the three variables. The hope is that I at least get the signs right and that the bias is negatively related to popularity and positively related to the number of versions.




```

Call:
lm(formula = bias ~ popularity + versions + popularity * versions, 
    data = p.data)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.50028 -0.12810 -0.03428  0.08074  1.09940 

Coefficients:
                    Estimate Std. Error t value Pr(>|t|)    
(Intercept)          2.99344    0.04769  62.768   <2e-16 ***
popularity          -0.92101    0.02471 -37.280   <2e-16 ***
versions             0.98727    0.07625  12.948   <2e-16 ***
popularity:versions  0.05918    0.03356   1.763   0.0794 .  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.2188 on 195 degrees of freedom
Multiple R-squared:  0.9567,	Adjusted R-squared:  0.956 
F-statistic:  1435 on 3 and 195 DF,  p-value: < 2.2e-16
```

******

# Conclusions

This post introduces some of the functions and features of [`'packageRank'`](https://cran.r-project.org/package=packageRank). The aim of the package is to put package download counts into context using visualization and nonparametric statistics like the rank percentile. The post also describes a systematic, positive bias that affects download counts and offers some ideas about how to minimize its effect.

The package is a work-in-progress. Suggestions, feature requests and problems can be submitted to the package's repository on [GitHub](https://www.github.com/lindbrook/packageRank/issues/). Additionally, any insights about "small" downloads would be particularly welcome.

I conclude with one final bit of data. On February 29, 2020 (a leap day and Sunday), there was a noticeable decline in traffic to CRAN. Barring some technical issue with [RStudio's logs](http://cran-logs.rstudio.com/), there wasn't anything in the real world that might explain the drop. In the R world however, the day was notable for the release of the source code for R version 3.6.3.

{{<figure src="cran_pkgs-1.png" title="Figure 19 Leap Day 2020">}}

{{<figure src="cran_r-1.png" title="Figure 20 Leap Day 2020">}}

In the past I've noticed that website maintenance (renaming files and folders, etc.) sometimes coincides with software updates. So my working hypothesis, which I haven't explored empirically, is that the scripts used to do automated downloading may have been "broken" by changes on CRAN. If so, this might actually be a better estimate of the "real" level of interest in R and its packages.

[^1]: Similar but limited functionality is available for Bioconductor packages using `bioconductorDownloads()` and `bioconductorRank()`.
[^2]: Based upon my reading of the documentation and source code, I'd say that the [`'adjustedcranlogs'`](https://cran.r-project.org/package=adjustedcranlogs) package is also concerned with the inflation of package download counts. However, I'd argue that its source of inflation are package updates and its objective is to estimate the number of new users (new package installations) by subtracting the number existing users (installation of package updates) from the total downloads. From the perspective of [`'packageRank'`](https://cran.r-project.org/package=packageRank), however, package updates are revelatory not problematic. Interest in a package is defined by both new and existing users. This is why `plot.cranDownloads()` include `package.version` and `r.version` arguments to annotate graphs with the the release of new package versions and new versions of R.
[^3]: The frequency of ~500 B downloads is such that I wonder whether `lftp` or something similar is/was part of the R and/or RStudio. That said, I've found that IP addresses with a "US" top level domain code account for 72% of ~500 B downloads but only 46% of all downloads. For details, see `head(packageRank::blog.data$ccode.ct, 5)`: "filtered" records download counts without ~500 B entries; "delta" is the arithmetic difference between "unfiltered" and "filtered".
[^4]: The slight upward trend in the peaks probably reflects the addition of new packages during the month.
[^5]: On 22 October 2019, there were two exceptions among inactive packages, 'UScensus2000blkgrp' and 'msDilution', which had zero downloads.
