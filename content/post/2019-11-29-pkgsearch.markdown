---
title: Search and discover CRAN packages with pkgsearch!
date: '2019-10-29'
slug: pkgsearch
tags:
  - pkgsearch
---

Version 3.0.1 of the `pkgsearch` package has been [released on CRAN](https://cran.r-project.org/package=pkgsearch)! `pkgsearch` munges CRAN metadata and lets you
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

:mag_right: New functionality adopted from former crandb

* `cran_package()`, `cran_packages()` and `cran_package_history()` functions to query metadata about certain packages.
    
* `cran_events()` function to list recent CRAN events, new, updated or archived packages.
    
* `cran_top_downloaded()` function to query packages with the most downloads.
    
* `cran_trending()` function to return the trending CRAN packages.

That's... a lot! Let's have some fun with the package.

## Explore packages in a GUI

SCREENCAST ONCE ADDIN FIXED. Show all tabs!

Use case for search, Wikidata, amazon, aws.

## Other use cases

The `pkgsearch` package is the answer to many questions you might have about CRAN metadata, thanks to its exposing it through different endpoints.



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
##  3   19 crul      0.9.0   Scott Chamberlain        13d HTTP Client             
##  4   14 fakemake  1.5.0   Andreas Dominik Cullmann 15d Mock the Unix Make Ut...
##  5    9 httptest  3.2.2   Neal Richardson           1y A Test Environment fo...
##  6    4 spongebob 0.4.0   Jay Qi                    9M SpongeBob-Case Conver...
##  7    0 vcr       0.3.0   Scott Chamberlain         3M Record 'HTTP' Calls t...
##  8    0 webmockr  0.4.0   Scott Chamberlain         3M Stubbing and Setting ...
```

### Dependencies of a package over time?

<!--html_preserve-->{{% tweet "1186667832718876673" %}}<!--/html_preserve-->

YES, we know! :nerd: :raised_hand: So say we want to query the dependencies of `igraph`, we can use `cran_package_history()` for that.


```r
library("magrittr")
cran_package_history("igraph")[, c("Package", "Version", "dependencies")] %>%
  tidyr::unnest(dependencies)
```

```
## # A tibble: 373 x 5
##    Package Version type     package version
##    <chr>   <chr>   <chr>    <chr>   <chr>  
##  1 igraph  0.3.1   Suggests stats4  *      
##  2 igraph  0.3.1   Suggests rgl     *      
##  3 igraph  0.3.2   Suggests stats4  *      
##  4 igraph  0.3.2   Suggests rgl     *      
##  5 igraph  0.3.3   Suggests stats4  *      
##  6 igraph  0.3.3   Suggests rgl     *      
##  7 igraph  0.4     Suggests stats4  *      
##  8 igraph  0.4     Suggests rgl     *      
##  9 igraph  0.4     Depends  stats   *      
## 10 igraph  0.4.1   Suggests stats4  *      
## # … with 363 more rows
```

Or of one particular version of `igraph`, then we can run `cran_packages()` (or `cran_package()` with its `version` argument, that returns a list).


```r
cran_packages("igraph@0.5.1")
```

```
## # A tibble: 1 x 13
##   Package Version Date  Title Author Maintainer Description License URL  
##   <chr>   <chr>   <chr> <chr> <chr>  <chr>      <chr>       <chr>   <chr>
## 1 igraph  0.5.1   Feb … Rout… Gabor… Gabor Csa… Routines f… GPL (>… http…
## # … with 4 more variables: Packaged <chr>, crandb_file_date <chr>, date <chr>,
## #   dependencies <list>
```

```r
cran_package("igraph", version = "0.5.1")
```

```
## $Package
## [1] "igraph"
## 
## $Version
## [1] "0.5.1"
## 
## $Date
## [1] "Feb 14, 2008"
## 
## $Title
## [1] "Routines for simple graphs, network analysis."
## 
## $Author
## [1] "Gabor Csardi <csardi@rmki.kfki.hu>"
## 
## $Maintainer
## [1] "Gabor Csardi <csardi@rmki.kfki.hu>"
## 
## $Description
## [1] "Routines for simple graphs and network analysis. igraph can<U+000a>handle large graphs very well and provides functions for generating random<U+000a>and regular graphs, graph visualization, centrality indices and much more."
## 
## $License
## [1] "GPL (>= 2)"
## 
## $URL
## [1] "http://cneurocvs.rmki.kfki.hu/igraph"
## 
## $Packaged
## [1] "Sat Jul 12 12:44:04 2008; csardi"
## 
## $crandb_file_date
## [1] "2008-07-12 14:35:05"
## 
## $Suggests
## $Suggests$stats4
## [1] "*"
## 
## $Suggests$rgl
## [1] "*"
## 
## $Suggests$tcltk
## [1] "*"
## 
## $Suggests$RSQLite
## [1] "*"
## 
## $Suggests$digest
## [1] "*"
## 
## $Suggests$graph
## [1] "*"
## 
## $Suggests$Matrix
## [1] "*"
## 
## 
## $Depends
## $Depends$stats
## [1] "*"
## 
## 
## $date
## [1] "2008-07-12T16:44:04+00:00"
## 
## $releases
## [1] "2.7.2" "2.8.0" "2.8.1"
## 
## attr(,"class")
## [1] "cran_package"
```

### When was CRAN incoming queue closed?

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

<img src="/post/2019-11-29-pkgsearch_files/figure-html/cranvacay-1.png" width="672" />

So yes, we do see the CRAN (well-deserved!) break in the data! 


## Related work

Without surprise `pkgsearch` is our favorite CRAN metadata munger since it is _ours_, but we know of other great tools!

* The [`packagefinder` package](https://cran.r-project.org/web/packages/packagefinder/index.html) by Joachim Zuckarelli aims at providing a Comfortable Search for R Packages on CRAN Directly from the R Console.

* [`CRANberries`](http://dirk.eddelbuettel.com/cranberries/about/) by Dirk Eddelbuettel "aggregates information about new, updated and removed packages from the CRAN network for R available as this html version and a corresponding RSS feed." and a Twitter feed. Handy!

## Conclusion

In this post we gave an overview of `pkgsearch` functionalities. It could become your go-to packages for searching and exploring CRAN packages thanks to its exposing CRAN metadata in different ways: packages related to a keyword, trending packages, information about a package, etc. And you can use it either from the R console or a GUI!

The best place to get to know `pkgsearch` is [its brand-new documentation website built with `pkgdown`](https://r-hub.github.io/pkgsearch), and the best place to provide feedback or contribute is [its GitHub repo](https://github.com/r-hub/pkgsearch). We look forward to hearing from your use cases, and hope your enthusiasm for the package can push it to the `cran_trending()` VIP list! :wink:



```r
pkg_search("search CRAN")
```

```
## - "search CRAN" ----------------------------- 15676 packages in 0.023 seconds -
##   #     package       version   by                   @ title                   
##   1 100 pkgsearch     3.0.0     Gábor Csárdi        5d Search and Query CRAN...
##   2  63 packagefinder 0.1.5     Joachim Zuckarelli 18d Comfortable Search fo...
##   3  62 CRANsearcher  1.0.0     Agustin Calatroni   2y RStudio Addin for Sea...
##   4  55 RWsearch      4.6.2     Patrice Kiener      3M Lazy Search in R Pack...
##   5  20 XML           3.98.1.20 ORPHANED            6M Tools for Parsing and...
##   6  17 RCurl         1.95.4.12 Duncan Temple Lang  9M General Network (HTTP...
##   7  12 NCmisc        1.1.6     Nicholas Cooper     1y Miscellaneous Functio...
##   8  11 badgecreatr   0.2.0     Roel M. Hogervorst 11M Create Badges for 'Tr...
##   9  11 pROC          1.15.3    Xavier Robin        4M Display and Analyze R...
##  10  10 FNN           1.1.3     Shengqiao Li        9M Fast Nearest Neighbor...
```
