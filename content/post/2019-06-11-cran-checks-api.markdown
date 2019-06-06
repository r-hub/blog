---
title:  Overview of the CRAN checks API
date: '2019-06-11'
slug:  cran-checks-api
tags:
  - CRAN
---

We've recently introduced [CRAN checks on our blog](/2019/04/25/r-devel-linux-x86-64-debian-clang/): once on CRAN your package is checked daily on a dozen platforms, and new failures can lead to its being archived or orphaned. We mentioned [ways to monitor your CRAN checks results](/2019/04/25/r-devel-linux-x86-64-debian-clang/#cran-checks-surveillance), including a cool web API, the CRAN checks API. We were thrilled to talk to its creator Scott Chamberlain, co-founder and tech lead at rOpenSci!  :telephone_receiver: :tada: In this post, we shall summarize our discussion with him about the API's functionalities, tech stack and future goals!

# CRAN checks data at your fingertips

### A handy API for all CRAN package maintainers

When [introducing the API on his blog in 2017](https://recology.info/2017/09/cranchecks-api/), Scott presented the motivation for it with these words _"it’d be nice to have a modern way (read: an API) to check CRAN check results."_. Prior to the API creation, the data was only available via CRAN check pages like e.g. [`rhub` CRAN check results](https://cran.r-project.org/web/checks/check_results_rhub.html), [by package or by maintainer](https://cran.r-project.org/web/checks/). Programmatic access to this data was only possible via webscraping, so now Scott webscrapes it for everyone and makes it available in :sparkles: _JSON_ :sparkles: and :sparkles: _SVG badges_ :sparkles:.

Initially, Scott was thinking of providing the service only for [rOpenSci packages](https://ropensci.org/packages/), but luckily for all of us, he noticed the system was easy enough to scale up and made it available for all CRAN packages, a service for the whole R community! :rocket: So, what can you do with the API? 

### What the API can do

There are two good ways to get to know the API, [its docs](https://github.com/ropenscilabs/cchecksapi/blob/master/docs/api_docs.md) and [its R client](https://docs.ropensci.org/cchecks). Scott admitted _he_ doesn't use the R client, preferring to call the API via the command line or the browser, e.g. before releasing a new version of the `taxize` package to CRAN he'd check https://cranchecks.info/pkgs/taxize We'll feature examples with `cchecks`. In the command line you get JSON, in R nested lists, both of which you can then wrangle to serve your goals.

Here's an example of showing how to use the API to get results for two packages,

<details>

```r
library("magrittr")
cchecks::cch_pkgs(c("rhub", "cranlogs")) %>%
  jsonlite::toJSON() %>%
  jsonlite::prettify()
```

```
## [
##     {
##         "error": {
## 
##         },
##         "data": {
##             "_id": [
##                 "rhub"
##             ],
##             "package": [
##                 "rhub"
##             ],
##             "url": [
##                 "https://cloud.r-project.org/web/checks/check_results_rhub.html"
##             ],
##             "summary": {
##                 "any": [
##                     false
##                 ],
##                 "ok": [
##                     12
##                 ],
##                 "note": [
##                     0
##                 ],
##                 "warn": [
##                     0
##                 ],
##                 "error": [
##                     0
##                 ],
##                 "fail": [
##                     0
##                 ]
##             },
##             "checks": [
##                 {
##                     "flavor": "r-devel-linux-x86_64-debian-clang",
##                     "version": "1.1.1",
##                     "tinstall": 5.52,
##                     "tcheck": 51.1,
##                     "ttotal": 56.62,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-debian-clang/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-linux-x86_64-debian-gcc",
##                     "version": "1.1.1",
##                     "tinstall": 4.41,
##                     "tcheck": 40.83,
##                     "ttotal": 45.24,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-debian-gcc/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-linux-x86_64-fedora-clang",
##                     "version": "1.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 67.79,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-clang/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-linux-x86_64-fedora-gcc",
##                     "version": "1.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 64.61,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-gcc/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-windows-ix86+x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 21,
##                     "tcheck": 58,
##                     "ttotal": 79,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-windows-ix86+x86_64/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-patched-linux-x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 5.45,
##                     "tcheck": 50.78,
##                     "ttotal": 56.23,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-patched-linux-x86_64/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-patched-solaris-x86",
##                     "version": "1.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 82.3,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-patched-solaris-x86/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-release-linux-x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 4.99,
##                     "tcheck": 50,
##                     "ttotal": 54.99,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-release-linux-x86_64/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-release-windows-ix86+x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 19,
##                     "tcheck": 90,
##                     "ttotal": 109,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-release-windows-ix86+x86_64/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-release-osx-x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 0,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-release-osx-x86_64/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-oldrel-windows-ix86+x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 8,
##                     "tcheck": 99,
##                     "ttotal": 107,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-oldrel-windows-ix86+x86_64/rhub-00check.html"
##                 },
##                 {
##                     "flavor": "r-oldrel-osx-x86_64",
##                     "version": "1.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 0,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-oldrel-osx-x86_64/rhub-00check.html"
##                 }
##             ],
##             "check_details": {
## 
##             },
##             "date_updated": [
##                 "2019-06-06T06:02:32.541Z"
##             ]
##         }
##     },
##     {
##         "error": {
## 
##         },
##         "data": {
##             "_id": [
##                 "cranlogs"
##             ],
##             "package": [
##                 "cranlogs"
##             ],
##             "url": [
##                 "https://cloud.r-project.org/web/checks/check_results_cranlogs.html"
##             ],
##             "summary": {
##                 "any": [
##                     false
##                 ],
##                 "ok": [
##                     12
##                 ],
##                 "note": [
##                     0
##                 ],
##                 "warn": [
##                     0
##                 ],
##                 "error": [
##                     0
##                 ],
##                 "fail": [
##                     0
##                 ]
##             },
##             "checks": [
##                 {
##                     "flavor": "r-devel-linux-x86_64-debian-clang",
##                     "version": "2.1.1",
##                     "tinstall": 1.75,
##                     "tcheck": 20.09,
##                     "ttotal": 21.84,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-debian-clang/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-linux-x86_64-debian-gcc",
##                     "version": "2.1.1",
##                     "tinstall": 1.45,
##                     "tcheck": 16.59,
##                     "ttotal": 18.04,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-debian-gcc/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-linux-x86_64-fedora-clang",
##                     "version": "2.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 27.03,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-clang/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-linux-x86_64-fedora-gcc",
##                     "version": "2.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 25.78,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-gcc/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-devel-windows-ix86+x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 7,
##                     "tcheck": 50,
##                     "ttotal": 57,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-devel-windows-ix86+x86_64/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-patched-linux-x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 1.78,
##                     "tcheck": 20.33,
##                     "ttotal": 22.11,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-patched-linux-x86_64/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-patched-solaris-x86",
##                     "version": "2.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 44.8,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-patched-solaris-x86/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-release-linux-x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 1.78,
##                     "tcheck": 20.21,
##                     "ttotal": 21.99,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-release-linux-x86_64/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-release-windows-ix86+x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 15,
##                     "tcheck": 50,
##                     "ttotal": 65,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-release-windows-ix86+x86_64/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-release-osx-x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 0,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-release-osx-x86_64/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-oldrel-windows-ix86+x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 4,
##                     "tcheck": 36,
##                     "ttotal": 40,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-oldrel-windows-ix86+x86_64/cranlogs-00check.html"
##                 },
##                 {
##                     "flavor": "r-oldrel-osx-x86_64",
##                     "version": "2.1.1",
##                     "tinstall": 0,
##                     "tcheck": 0,
##                     "ttotal": 0,
##                     "status": "OK",
##                     "check_url": "https://www.R-project.org/nosvn/R.check/r-oldrel-osx-x86_64/cranlogs-00check.html"
##                 }
##             ],
##             "check_details": {
## 
##             },
##             "date_updated": [
##                 "2019-06-06T06:02:32.491Z"
##             ]
##         }
##     }
## ]
## 
```
</details>

And for one maintainer,

<details>

```r
library("magrittr")
cchecks::cch_maintainers("maelle.salmon_at_yahoo.se") %>%
  jsonlite::toJSON() %>%
  jsonlite::prettify()
```

```
## {
##     "error": {
## 
##     },
##     "data": {
##         "_id": [
##             "maelle.salmon_at_yahoo.se"
##         ],
##         "email": [
##             "maelle.salmon_at_yahoo.se"
##         ],
##         "name": [
##             "Maëlle Salmon"
##         ],
##         "url": [
##             "https://cloud.r-project.org/web/checks/check_results_maelle.salmon_at_yahoo.se.html"
##         ],
##         "table": [
##             {
##                 "package": "geoparser",
##                 "any": false,
##                 "ok": 12,
##                 "note": 0,
##                 "warn": 0,
##                 "error": 0
##             },
##             {
##                 "package": "monkeylearn",
##                 "any": true,
##                 "ok": 7,
##                 "note": 5,
##                 "warn": 0,
##                 "error": 0
##             },
##             {
##                 "package": "opencage",
##                 "any": false,
##                 "ok": 12,
##                 "note": 0,
##                 "warn": 0,
##                 "error": 0
##             },
##             {
##                 "package": "riem",
##                 "any": false,
##                 "ok": 12,
##                 "note": 0,
##                 "warn": 0,
##                 "error": 0
##             },
##             {
##                 "package": "ropenaq",
##                 "any": false,
##                 "ok": 12,
##                 "note": 0,
##                 "warn": 0,
##                 "error": 0
##             },
##             {
##                 "package": "rtimicropem",
##                 "any": true,
##                 "ok": 6,
##                 "note": 6,
##                 "warn": 0,
##                 "error": 0
##             }
##         ],
##         "packages": [
##             {
##                 "package": "geoparser",
##                 "url": "https://cloud.r-project.org/web/checks/check_results_geoparser.html",
##                 "check_result": [
##                     {
##                         "category": "OK",
##                         "number_checks": 12
##                     }
##                 ]
##             },
##             {
##                 "package": "monkeylearn",
##                 "url": "https://cloud.r-project.org/web/checks/check_results_monkeylearn.html",
##                 "check_result": [
##                     {
##                         "category": "NOTE",
##                         "number_checks": 5
##                     },
##                     {
##                         "category": "OK",
##                         "number_checks": 7
##                     }
##                 ]
##             },
##             {
##                 "package": "opencage",
##                 "url": "https://cloud.r-project.org/web/checks/check_results_opencage.html",
##                 "check_result": [
##                     {
##                         "category": "OK",
##                         "number_checks": 12
##                     }
##                 ]
##             },
##             {
##                 "package": "riem",
##                 "url": "https://cloud.r-project.org/web/checks/check_results_riem.html",
##                 "check_result": [
##                     {
##                         "category": "OK",
##                         "number_checks": 12
##                     }
##                 ]
##             },
##             {
##                 "package": "ropenaq",
##                 "url": "https://cloud.r-project.org/web/checks/check_results_ropenaq.html",
##                 "check_result": [
##                     {
##                         "category": "OK",
##                         "number_checks": 12
##                     }
##                 ]
##             },
##             {
##                 "package": "rtimicropem",
##                 "url": "https://cloud.r-project.org/web/checks/check_results_rtimicropem.html",
##                 "check_result": [
##                     {
##                         "category": "NOTE",
##                         "number_checks": 6
##                     },
##                     {
##                         "category": "OK",
##                         "number_checks": 6
##                     }
##                 ]
##             }
##         ],
##         "date_updated": [
##             "2019-04-03T12:01:43.725Z"
##         ]
##     }
## }
## 
```
</details>

Last but not least, with the API you can get badges! See the following badges for the `rhub` package.

* Summary, binary badge, either a green "OK" :grin: or a red "Not OK" :sob: `[![cran checks](https://cranchecks.info/badges/summary/rhub)](https://cran.r-project.org/web/checks/check_results_rhub.html)` or `[![cran checks](https://cranchecks.info/badges/summary/rhub)](https://cranchecks.info/pkgs/rhub)` depending on whether you want to point to CRAN check results in hipster html format or in modern JSON. [![cran checks](https://cranchecks.info/badges/summary/rhub)](https://cranchecks.info/pkgs/rhub)

* "Worst", a badge that'll show the worst check result your package has i.e. NOTE/WARNING/ERROR. `[![cran checks](https://cranchecks.info/badges/worst/rhub)](https://cranchecks.info/pkgs/rhub)` [![cran checks](https://cranchecks.info/badges/worst/rhub)](https://cranchecks.info/pkgs/rhub) 

* Check by flavor, e.g. if you want a special badge because you're proud you fixed checks on Solaris. `[![cran checks](https://cranchecks.info/badges/flavor/solaris/rhub)](https://cranchecks.info/pkgs/rhub)` [![cran checks](https://cranchecks.info/badges/flavor/solaris/rhub)](https://cranchecks.info/pkgs/rhub) 

According to the API usage logs, the JSON data isn't queried that much: what's most successful are badges, both of the summary and worst types.

# Tech stack

Scott underlined the main challenge he faced when creating API was that he learnt tools for the job as he went. Cool learning experience, lots of reading (blogs, Stack Overflow, etc.) and a bit of error making! 

Scott chose the programming language Ruby as a tool for the job because Ruby is good for building web APIs and because he already knew Ruby. In Ruby, he used the Sinatra framework/library for the REST API because it's light weight, and the Faraday library for scraping. Scraping was a bit too slow at first, so he complemented the toolset with the [Go ganda library](https://github.com/tednaleid/ganda/) for making parallel curl requests. By the way, the pages he scrapes are the one from the RStudio CRAN mirror, not from other mirrors.

The data lives in two types of databases, MongoDB (noSQL) for the data of the day, MariaDB (SQL) for the rest. Originally the service only used MongoDB which was slow. Data and processing are wrapped in containers, via Docker Compose, on the cloud :cloud: on an Amazon Web Services server, which costs about 75$ a year.

The whole thing is brought to life by CRON jobs: package specific data is scraped every 3 hours, maintainer level data every 4 hours and the history routes are populated once a day. To ensure Scott knows when something is going wrong, which happens less often now that the system is stable, he uses [Healthchecks](https://healthchecks.io/) that alerts you when your CRON jobs fail.

Gábor, the API uses the crandb API that hasn't been transferred yet, should we mention the crandb API anyway?

# Future plans

There are two big and exciting TODOs for the CRAN checks API: a notification system and a better availability of historical data.

A **notification system** would allow maintainers to subscribe and get emails/Slack messages about new failures. The main challenge with that is that sometimes there are false positives, e.g. a transient change on R-devel or a failure of the check platform itself, so that could be a lot of a notifications.

**Historical data** is at the moment only available via the package history route e.g. https://cranchecks.info/pkgs/rhub/history In the future Scott would like to still provide historical data for the last 30 days via the API, but all older data via data dumps on Amazon S3. Imagine how interesting such data could be to explore the health of CRAN platforms over time for instance, or to [pinpoint when a given change was introduced and packages had be updated](/2019/04/25/r-devel-linux-x86-64-debian-clang/)!

# Conclusion

Thanks Scott for talking to us and for maintaining the API, and good luck with its future development! Dear readers, Scott let us know feedback, bug reports and suggestions are more than welcome in [the API's issue tracker](https://github.com/ropenscilabs/cchecksapi/issues). We wish all your READMEs will display green OK badges, and if they ever turn orange or red, don't forget [R-hub is here to help](/2019/04/25/r-devel-linux-x86-64-debian-clang/).
