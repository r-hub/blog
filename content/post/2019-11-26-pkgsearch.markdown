---
title: Search and discover CRAN packages with pkgsearch!
date: '2019-11-26'
slug: pkgsearch
tags:
  - pkgsearch
---

We have just released version 3.0.1 of the `pkgsearch` package [on CRAN](https://cran.r-project.org/package=pkgsearch)! :tada: `pkgsearch` munges CRAN metadata and lets you
access it through several lenses: **search packages by keyword, popularity, recent activity, package name and more.** 

Get `pkgsearch`'s latest version from 
a [safe](https://rud.is/b/2019/03/03/cran-mirror-security/) CRAN mirror near
you:

```r
install.packages("pkgsearch")
```

This release, compared to `pkgsearch` 2.0.0, brings 

:mag_right: Better package search functionality

*  New RStudio addin to search for packages in a GUI: `pkg_search_addin()`.

* New function `advanced_search()` for more search flexibility.

:mag_right: New functionality

* `cran_package()`, `cran_packages()` and `cran_package_history()` functions to query metadata about certain packages.
    
* `cran_events()` function to list recent CRAN events, new, updated or archived packages.
    
* `cran_top_downloaded()` function to query packages with the most downloads.
    
* `cran_trending()` function to return the trending CRAN packages.

That's... a lot! Let's have some fun with the package.

## Explore packages in a GUI

You can use `pkgsearch` with an interface. See more in the video below. You can also launch the interface in a browser without RStudio, [refer to the addin docs](https://r-hub.github.io/pkgsearch/reference/pkg_search_addin.html).

<!--html_preserve-->{{% vimeo "375618736" %}}<!--/html_preserve-->

## Other use cases

The `pkgsearch` package is the answer to many questions you might have about CRAN packages, thanks to its exposing it through different lenses.



```r
library("pkgsearch")
```

### Packages to do mocking

Remember our [blog post about mocking when unit testing](/2019/10/29/mocking/)? How could we search CRAN packages related to mocking?


```r
pkg_search("mocking")
```

```
## - "mocking" ------------------------------------- 8 packages in 0.008 seconds -
##   #     package   version by                         @ title                   
##  1  100 mockery   0.4.2   Jim Hester                3M Mocking Library for R   
##  2   43 mockr     0.1     Kirill Müller             3y Mocking in R            
##  3   19 crul      0.9.0   Scott Chamberlain        20d HTTP Client             
##  4   14 fakemake  1.5.0   Andreas Dominik Cullmann 22d Mock the Unix Make Ut...
##  5    9 httptest  3.2.2   Neal Richardson           1y A Test Environment fo...
##  6    4 spongebob 0.4.0   Jay Qi                    9M SpongeBob-Case Conver...
##  7    0 vcr       0.3.0   Scott Chamberlain         3M Record 'HTTP' Calls t...
##  8    0 webmockr  0.4.0   Scott Chamberlain         4M Stubbing and Setting ...
```

### Dependencies of a package over time?

<!--html_preserve-->{{% tweet "1186667832718876673" %}}<!--/html_preserve-->

YES, we know!  :grin: :raised_hand: So say we want to query the dependencies of `tsibble`, we can use `cran_package_history()` for that.


```r
library("magrittr")
cran_package_history("tsibble")[, c("Package", "Version", "dependencies")] %>%
  tidyr::unnest(dependencies)
```

```
## # A tibble: 447 x 5
##    Package Version type    package    version  
##    <chr>   <chr>   <chr>   <chr>      <chr>    
##  1 tsibble 0.1.0   Depends R          >= 3.1.3 
##  2 tsibble 0.1.0   Imports rlang      *        
##  3 tsibble 0.1.0   Imports tidyr      *        
##  4 tsibble 0.1.0   Imports purrr      *        
##  5 tsibble 0.1.0   Imports tibble     >= 1.4.1 
##  6 tsibble 0.1.0   Imports pillar     >= 1.0.1 
##  7 tsibble 0.1.0   Imports lubridate  *        
##  8 tsibble 0.1.0   Imports dplyr      >= 0.7.3 
##  9 tsibble 0.1.0   Imports Rcpp       >= 0.12.3
## 10 tsibble 0.1.0   Imports tidyselect *        
## # … with 437 more rows
```

Or of one particular version of `tsibble`, then we can run `cran_packages()` (or `cran_package()` with its `version` argument, that returns a list).


```r
cran_packages("tsibble@0.2.0")
```

```
## # A tibble: 1 x 25
##   Package Type  Title Version Date  `Authors@R` Description ByteCompile
##   <chr>   <chr> <chr> <chr>   <chr> <chr>       <chr>       <chr>      
## 1 tsibble Pack… Tidy… 0.2.0   2018… "c(\nperso… "Provides … true       
## # … with 17 more variables: VignetteBuilder <chr>, License <chr>, URL <chr>,
## #   BugReports <chr>, Encoding <chr>, LazyData <chr>, RoxygenNote <chr>,
## #   NeedsCompilation <chr>, Packaged <chr>, Author <chr>, Maintainer <chr>,
## #   Repository <chr>, `Date/Publication` <chr>, crandb_file_date <chr>,
## #   MD5sum <chr>, date <chr>, dependencies <list>
```

```r
cran_package("tsibble", version = "0.2.0")
```

```
## $Package
## [1] "tsibble"
## 
## $Type
## [1] "Package"
## 
## $Title
## [1] "Tidy Temporal Data Frames and Tools"
## 
## $Version
## [1] "0.2.0"
## 
## $Date
## [1] "2018-05-11"
## 
## $`Authors@R`
## [1] "c(\nperson(\"Earo\", \"Wang\", email = \"earo.wang@gmail.com\", role = c(\"aut\", \"cre\"), comment = c(ORCID = \"0000-0001-6448-5260\")),\nperson(\"Di\", \"Cook\", role = c(\"aut\", \"ths\"), comment = c(ORCID = \"0000-0002-3813-7155\")),\nperson(\"Rob\", \"Hyndman\", role = c(\"aut\", \"ths\"), comment = c(ORCID = \"0000-0002-2140-5352\")),\nperson(\"Mitchell\", \"O'Hara-Wild\", role = c(\"ctb\"))\n)"
## 
## $Description
## [1] "Provides a 'tbl_ts' class (the 'tsibble') to store and manage\ntemporal-context data in a data-centric format, which is built on top of\nthe 'tibble'. The 'tsibble' aims at easily manipulating and analysing temporal\ndata, including counting and filling time gaps, aggregate over calendar periods,\nperforming rolling window calculations, and etc."
## 
## $Depends
## $Depends$R
## [1] ">= 3.1.3"
## 
## 
## $Imports
## $Imports$rlang
## [1] ">= 0.2.0"
## 
## $Imports$tidyr
## [1] "*"
## 
## $Imports$purrr
## [1] ">= 0.2.3"
## 
## $Imports$tibble
## [1] ">= 1.4.1"
## 
## $Imports$pillar
## [1] ">= 1.0.1"
## 
## $Imports$lubridate
## [1] "*"
## 
## $Imports$dplyr
## [1] ">= 0.7.3"
## 
## $Imports$Rcpp
## [1] ">=\n0.12.3"
## 
## $Imports$tidyselect
## [1] "*"
## 
## 
## $Suggests
## $Suggests$knitr
## [1] "*"
## 
## $Suggests$rmarkdown
## [1] "*"
## 
## $Suggests$testthat
## [1] "*"
## 
## $Suggests$covr
## [1] "*"
## 
## $Suggests$hts
## [1] "*"
## 
## $Suggests$hms
## [1] "*"
## 
## $Suggests$nycflights13
## [1] "*"
## 
## $Suggests$ggplot2
## [1] ">= 2.2.0"
## 
## 
## $LinkingTo
## $LinkingTo$Rcpp
## [1] ">= 0.12.0"
## 
## 
## $ByteCompile
## [1] "true"
## 
## $VignetteBuilder
## [1] "knitr"
## 
## $License
## [1] "GPL (>= 3)"
## 
## $URL
## [1] "https://pkg.earo.me/tsibble"
## 
## $BugReports
## [1] "https://github.com/tidyverts/tsibble/issues"
## 
## $Encoding
## [1] "UTF-8"
## 
## $LazyData
## [1] "true"
## 
## $RoxygenNote
## [1] "6.0.1"
## 
## $NeedsCompilation
## [1] "yes"
## 
## $Packaged
## [1] "2018-05-11 08:07:56 UTC; earo"
## 
## $Author
## [1] "Earo Wang [aut, cre] (<https://orcid.org/0000-0001-6448-5260>),\nDi Cook [aut, ths] (<https://orcid.org/0000-0002-3813-7155>),\nRob Hyndman [aut, ths] (<https://orcid.org/0000-0002-2140-5352>),\nMitchell O'Hara-Wild [ctb]"
## 
## $Maintainer
## [1] "Earo Wang <earo.wang@gmail.com>"
## 
## $Repository
## [1] "CRAN"
## 
## $`Date/Publication`
## [1] "2018-05-11 08:58:28 UTC"
## 
## $crandb_file_date
## [1] "2018-05-11 09:02:20"
## 
## $MD5sum
## [1] "7350c661bb9d48b2c16bfee8d6cc0314"
## 
## $date
## [1] "2018-05-11T07:58:28+00:00"
## 
## $releases
## list()
## 
## attr(,"class")
## [1] "cran_package"
```

### When was the CRAN incoming queue closed?

From time to time [CRAN incoming queue is closed](https://stat.ethz.ch/pipermail/r-package-devel/2019q3/004242.html), for instance earlier this year from August 9 to August 18. Can we see that in the data?




```r
library("ggplot2")

cran_events <- cran_events(limit = 5000)
events_df <- tibble::tibble(
  date = anytime::anytime(purrr::map_chr(cran_events, "date")),
  type = purrr::map_chr(cran_events, "event")
)

ggplot(events_df) +
  geom_segment(aes(x = date, xend = date,
                 col = type), 
                   y = 0, yend = 1) +
  viridis::scale_colour_viridis(discrete = TRUE) +
  theme_minimal() +
  hrbrthemes::theme_ipsum(base_size = 16,
                          axis_title_size = 16) +
  xlab("Time") + 
  theme(
  axis.text.y = element_blank(),
  axis.ticks.y = element_blank(),
  axis.title.y = element_blank(),
  legend.position = "bottom") +
  ggtitle("Latest 5,000 CRAN events",
          subtitle = "Data obtained via the R-hub pkgsearch R package")
```

<img src="/post/2019-11-26-pkgsearch_files/figure-html/cranvacay-1.png" width="672" />

So yes, we do see the CRAN (well-deserved!) break in the data! 


## Related work

Without surprise `pkgsearch` is our favorite CRAN metadata munger since it is _ours_, but we know of other great tools!

* The [`packagefinder` package](https://cran.r-project.org/web/packages/packagefinder/index.html) by Joachim Zuckarelli aims at providing a Comfortable Search for R Packages on CRAN Directly from the R Console.

* [`CRANberries`](http://dirk.eddelbuettel.com/cranberries/about/) by Dirk Eddelbuettel "aggregates information about new, updated and removed packages from the CRAN network for R available as this html version and a corresponding RSS feed." and a Twitter feed. Handy!

## Conclusion

In this post we gave an overview of `pkgsearch` functionalities. It could become your go-to package for searching and exploring CRAN packages thanks to its exposing CRAN metadata in different ways: packages related to a keyword, trending packages, information about a package, etc. And you can use it either from the R console or a GUI!

The best place to get to know `pkgsearch` is [its brand-new documentation website built with `pkgdown`](https://r-hub.github.io/pkgsearch), and the best place to provide feedback or contribute is [its GitHub repo](https://github.com/r-hub/pkgsearch). We look forward to hearing from your use cases, and hope your enthusiasm for the package can push it to the `cran_trending()` VIP list! :wink:



```r
pkg_search("search CRAN")
```

```
## - "search CRAN" ----------------------------- 15699 packages in 0.016 seconds -
##   #     package       version   by                   @ title                   
##   1 100 pkgsearch     3.0.1     Gábor Csárdi       17h Search and Query CRAN...
##   2  63 packagefinder 0.1.5     Joachim Zuckarelli 25d Comfortable Search fo...
##   3  62 CRANsearcher  1.0.0     Agustin Calatroni   2y RStudio Addin for Sea...
##   4  55 RWsearch      4.6.2     Patrice Kiener      3M Lazy Search in R Pack...
##   5  20 XML           3.98.1.20 ORPHANED            6M Tools for Parsing and...
##   6  17 RCurl         1.95.4.12 Duncan Temple Lang  9M General Network (HTTP...
##   7  12 NCmisc        1.1.6     Nicholas Cooper     1y Miscellaneous Functio...
##   8  11 badgecreatr   0.2.0     Roel M. Hogervorst 11M Create Badges for 'Tr...
##   9  11 pROC          1.15.3    Xavier Robin        4M Display and Analyze R...
##  10  10 FNN           1.1.3     Shengqiao Li        9M Fast Nearest Neighbor...
```
