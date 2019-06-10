---
title:  Overview of the CRAN checks API
date: '2019-06-10'
slug:  cran-checks-api
tags:
  - CRAN
---

We've recently introduced [CRAN checks on our blog](/2019/04/25/r-devel-linux-x86-64-debian-clang/): once on CRAN your package is checked regularly on a dozen platforms, and new failures can lead to its being archived or orphaned. We mentioned [ways to monitor your CRAN checks results](/2019/04/25/r-devel-linux-x86-64-debian-clang/#cran-checks-surveillance), including a cool web API, the CRAN checks API. We were thrilled to talk to its creator Scott Chamberlain, co-founder and tech lead at rOpenSci!  :telephone_receiver: :tada: In this post, we shall summarize our discussion with him about the API's functionalities, tech stack and future goals!

# CRAN checks data at your fingertips

### A handy API for all CRAN package maintainers

When [introducing the API on his blog in 2017](https://recology.info/2017/09/cranchecks-api/), Scott presented the motivation for it with these words _"it’d be nice to have a modern way (read: an API) to check CRAN check results."_. Prior to the API creation, the data was only available via CRAN check pages like e.g. [`rhub` CRAN check results](https://cran.r-project.org/web/checks/check_results_rhub.html), [by package or by maintainer](https://cran.r-project.org/web/checks/). Programmatic access to this data was only possible via webscraping, so now Scott webscrapes it for everyone and makes it available in :sparkles: _JSON_ :sparkles: and :sparkles: _SVG badges_ :sparkles:.

Initially, Scott was thinking of providing the service only for [rOpenSci packages](https://ropensci.org/packages/), but luckily for all of us, he noticed the system was easy enough to scale up and made it available for all CRAN packages, a service for the whole R community! :rocket: So, what can you do with the API? 

### What the API can do

There are two good ways to get to know the API, [its docs](https://github.com/ropenscilabs/cchecksapi/blob/master/docs/api_docs.md) and [its R client](https://docs.ropensci.org/cchecks). Scott admitted _he_ doesn't use the R client, preferring to call the API via the command line or the browser, e.g. before releasing a new version of the `taxize` package to CRAN he'd check https://cranchecks.info/pkgs/taxize We'll feature examples with `cchecks`. In the command line you get JSON, in R nested lists, both of which you can then wrangle to serve your goals.

Here's an example of showing how to use the API to get results for two packages,


```r
res <- cchecks::cch_pkgs(c("rhub", "cranlogs"))

res[[1]]$data$package
```

```
## [1] "rhub"
```

```r
res[[1]]$data$checks
```

```
##                               flavor version tinstall tcheck ttotal status
## 1  r-devel-linux-x86_64-debian-clang   1.1.1     5.74  51.08  56.82     OK
## 2    r-devel-linux-x86_64-debian-gcc   1.1.1     4.28  41.02  45.30     OK
## 3  r-devel-linux-x86_64-fedora-clang   1.1.1     0.00   0.00  67.18     OK
## 4    r-devel-linux-x86_64-fedora-gcc   1.1.1     0.00   0.00  64.12     OK
## 5        r-devel-windows-ix86+x86_64   1.1.1    11.00  60.00  71.00     OK
## 6             r-patched-linux-x86_64   1.1.1     5.56  50.22  55.78     OK
## 7              r-patched-solaris-x86   1.1.1     0.00   0.00  82.30     OK
## 8             r-release-linux-x86_64   1.1.1     5.40  50.51  55.91     OK
## 9      r-release-windows-ix86+x86_64   1.1.1    20.00  79.00  99.00     OK
## 10              r-release-osx-x86_64   1.1.1     0.00   0.00   0.00     OK
## 11      r-oldrel-windows-ix86+x86_64   1.1.1     8.00  99.00 107.00     OK
## 12               r-oldrel-osx-x86_64   1.1.1     0.00   0.00   0.00     OK
##                                                                                      check_url
## 1  https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-debian-clang/rhub-00check.html
## 2    https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-debian-gcc/rhub-00check.html
## 3  https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-clang/rhub-00check.html
## 4    https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-gcc/rhub-00check.html
## 5        https://www.R-project.org/nosvn/R.check/r-devel-windows-ix86+x86_64/rhub-00check.html
## 6             https://www.R-project.org/nosvn/R.check/r-patched-linux-x86_64/rhub-00check.html
## 7              https://www.R-project.org/nosvn/R.check/r-patched-solaris-x86/rhub-00check.html
## 8             https://www.R-project.org/nosvn/R.check/r-release-linux-x86_64/rhub-00check.html
## 9      https://www.R-project.org/nosvn/R.check/r-release-windows-ix86+x86_64/rhub-00check.html
## 10              https://www.R-project.org/nosvn/R.check/r-release-osx-x86_64/rhub-00check.html
## 11      https://www.R-project.org/nosvn/R.check/r-oldrel-windows-ix86+x86_64/rhub-00check.html
## 12               https://www.R-project.org/nosvn/R.check/r-oldrel-osx-x86_64/rhub-00check.html
```

And for one maintainer,


```r
cchecks::cch_maintainers("maelle.salmon_at_yahoo.se")$data$table
```

```
##       package   any ok note warn error
## 1   geoparser FALSE 12    0    0     0
## 2 monkeylearn  TRUE  7    5    0     0
## 3    opencage FALSE 12    0    0     0
## 4        riem FALSE 12    0    0     0
## 5     ropenaq FALSE 12    0    0     0
## 6 rtimicropem  TRUE  6    6    0     0
```

So it's all the same information as on the CRAN html pages, but in a nicer format for further wrangling and analysis.

Last but not least, with the API you can get badges! See the following badges for the `rhub` package.

* Summary, binary badge, either a green "OK" :grin: or a red "Not OK" :sob: `[![cran checks](https://cranchecks.info/badges/summary/rhub)](https://cran.r-project.org/web/checks/check_results_rhub.html)` or `[![cran checks](https://cranchecks.info/badges/summary/rhub)](https://cranchecks.info/pkgs/rhub)` depending on whether you want to point to CRAN check results in hipster html format or in modern JSON. [![cran checks](https://cranchecks.info/badges/summary/rhub)](https://cranchecks.info/pkgs/rhub)

* "Worst", a badge that'll show the worst check result your package has i.e. NOTE/WARNING/ERROR. `[![cran checks](https://cranchecks.info/badges/worst/rhub)](https://cranchecks.info/pkgs/rhub)` [![cran checks](https://cranchecks.info/badges/worst/rhub)](https://cranchecks.info/pkgs/rhub) 

* Check by flavor, e.g. if you want a special badge because you're proud you fixed checks on Solaris. `[![cran checks](https://cranchecks.info/badges/flavor/solaris/rhub)](https://cranchecks.info/pkgs/rhub)` [![cran checks](https://cranchecks.info/badges/flavor/solaris/rhub)](https://cranchecks.info/pkgs/rhub) 

According to the API usage logs, the JSON data isn't queried that much: what's most successful are badges, /badges requests are 36 times that of /pkgs requests. :nail_care: Among badges, "worst" gets about 4.5 times the usage as summary and flavor (summary and flavor are about equal).

# Tech stack

Scott underlined the main challenge he faced when creating API was that he learnt tools for the job as he went. Cool learning experience, lots of reading (blogs, Stack Overflow, etc.) and a bit of error making! 

Scott chose the [programming language Ruby](https://www.ruby-lang.org/en/) because it is good for building web APIs and because he already knew Ruby. In Ruby, he used the [Sinatra framework/library](http://sinatrarb.com/) for the REST API because it's light weight, and the [Faraday library](https://github.com/lostisland/faraday) for scraping. Scraping was a bit too slow at first, so he complemented the toolset with the [Go ganda library](https://github.com/tednaleid/ganda/) for making parallel curl requests. By the way, the pages he scrapes are the one from the RStudio CRAN mirror, not from other mirrors.

The data lives in two types of databases, [MongoDB](https://www.mongodb.com/) (NoSQL) for the data of the day, [MariaDB](https://mariadb.org/) (SQL) for the rest. Originally the service only used MongoDB which was not optimal for storing large amounts of historical CRAN checks data. Data and processing are wrapped in containers, via [Docker Compose](https://docs.docker.com/compose/), on the cloud :cloud: on an [Amazon Web Services](https://aws.amazon.com/) server, which costs about 75$ a year.

The whole thing is brought to life by [CRON jobs](https://en.wikipedia.org/wiki/Cron): package specific data is scraped every 3 hours, maintainer level data every 4 hours and the history routes are populated once a day. To ensure Scott knows when something is going wrong, which happens less often now that the system is stable, he uses [Healthchecks](https://healthchecks.io/) that alerts you when your CRON jobs fail.

Last but not least, to know what packages are on CRAN, Scott's scripts use [the crandb API](http://crandb.r-pkg.org/).

# Future plans

There are two big and exciting TODOs for the CRAN checks API: a notification system and a better availability of historical data.

A **notification system** would allow maintainers to subscribe and get emails/Slack messages about new failures. The main challenge with that is that sometimes there are false positives, e.g. a transient change on R-devel or a failure of the check platform itself, so that could be a lot of a notifications.

**Historical data** is at the moment only available via the package history route e.g. https://cranchecks.info/pkgs/rhub/history In the future Scott would like to still provide historical data for the last 30 days via the API, but all older data via data dumps on [Amazon S3](https://aws.amazon.com/s3/). Imagine how interesting such data could be to explore the health of CRAN platforms over time for instance, or to [pinpoint when a given change was introduced and packages had be updated](/2019/04/25/r-devel-linux-x86-64-debian-clang/)!

# Conclusion

Thanks Scott for talking to us and for maintaining the API, and good luck with its future development! Dear readers, Scott let us know feedback, bug reports and suggestions are more than welcome in [the API's issue tracker](https://github.com/ropenscilabs/cchecksapi/issues). We wish all your READMEs will display green OK badges, and if they ever turn orange or red, don't forget [R-hub is here to help](/2019/04/25/r-devel-linux-x86-64-debian-clang/).
