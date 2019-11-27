---
title: Internal functions in R packages
date: '2019-11-01'
slug: internal functions
tags:
  - package development
---

An R package can be viewed as a [set of functions](https://github.com/ropensci/software-review/issues/350#issue-518124603), of which only a part are exposed to the user. In this blog post we shall concentrate of the functions that are not exposed to the user, so called internal functions: what are they, how does one handle them in one's own package, and how can one explore them?

## Internal functions 101

### What is an internal function? 

It's a function that lives in your package, but that isn't surfaced to the user. You could also call it unexported function or helper function; as opposed to exported functions and user-facing functions.

For instance, in the usethis package there's a `base_and_recommended()` function.


```r
# doesn't work
library("usethis")
base_and_recommended()
```

```
## Error in base_and_recommended(): could not find function "base_and_recommended"
```

```r
usethis::base_and_recommended()
```

```
## Error: 'base_and_recommended' is not an exported object from 'namespace:usethis'
```

```r
# works
usethis:::base_and_recommended()
```

```
##  [1] "base"       "boot"       "class"      "cluster"    "codetools" 
##  [6] "compiler"   "datasets"   "foreign"    "graphics"   "grDevices" 
## [11] "grid"       "KernSmooth" "lattice"    "MASS"       "Matrix"    
## [16] "methods"    "mgcv"       "nlme"       "nnet"       "parallel"  
## [21] "rpart"      "spatial"    "splines"    "stats"      "stats4"    
## [26] "survival"   "tcltk"      "tools"      "utils"
```

### Why not export all functions?

There are at least these two reasons:

* In a package you want to provide your user an API that is useful and stable. You can vouch for a few functions, that work well, serve the package main goals, are documented enough, and that you'd only change [with great care](https://devguide.ropensci.org/evolution.html) [if need be](https://ropensci.org/blog/2019/04/30/qualtrics-relaunch/). If your package users rely of an internal function that you decide to ditch when re-factoring code, they won't be happy, so only export what you want to maintain.

* If all packages exposed all their internal functions, the user environment would be flooded and the namespace conflicts would be out of control.

### Why write internal functions?

Why write internal functions instead of having everything in one block of code inside each exported functions?

When writing R code in general [there are several reasons to write functions](https://r4ds.had.co.nz/functions.html) and it is the same within R packages: you can re-use a bit of code in several places (e.g. an epoch converter used for the output of several endpoints from a web API), and you can give it a self-explaining name (e.g. `convert_epoch()`). 

Having internal functions also means you can test these bits of code on their own. That said [if you test internals too much re-factoring your code will mean breaking tests so you might want to focus testing on external functions](https://r-pkgs.org/tests.html).

To find blocks of code that could be replaced with a function used several times, you could use [the `dupree` package](https://cran.r-project.org/web/packages/dupree/index.html) whose planned enhancements [include highlighting or printing the similar blocks](https://github.com/russHyde/dupree/issues/48).

### When not to write internal functions?

There is a balance to be found between writing your own helpers for everything and only depending on external code. [You can watch this excellent code on the topic](https://resources.rstudio.com/rstudio-conf-2019/it-depends-a-dialog-about-dependencies).

### Where to put internal functions?

You could save internal functions used in one function only in the R file defining that function, and internal functions used in several other functions in a single utils.R file or specialized utils-dates.R, utils-encoding.R files.

Another possible approach to helper functions when used in several packages is to pack them up in a package such as [Yihui Xie's `xfun`](https://github.com/yihui/xfun). So then they're no longer internal functions. :dizzy_face: 

### How to document internal functions?

You should at least add a few comments in their code as usual. Best practice recommended in the [tidyverse style guide](https://style.tidyverse.org/documentation.html#internal-functions) and the [rOpenSci dev guide](https://devguide.ropensci.org/building.html) is to document them with roxygen2 tags like other functions, but to use `#' @NoRd` to prevent manual pages to be created. 

```r
#' Compare x to 1
#' @param x an integer
#' @NoRd
is_one <- function(x) {
  x == 1
}

```

The keyword `@keyword internal` would mean [a manual page is created but not present in the function index](https://roxygen2.r-lib.org/articles/rd.html#indexing). A confusing aspect is that you could use it for an *exported, not internal* function you don't want to be too visible, e.g. a function returning the default app for OAuth in a package wrapping a web API.

```r
#' A function rather aimed at developers
#' @description A function that does blabla, blabla.
#' @keywords internal
#' @export
does_thing <- function(){
 message("I am an exported function")
}
```

## Explore internal functions

You might need to have a look at the guts of a package when wanting to contribute to it, or at the guts of several packages to get some inspiration for your code.

### Explore internal functions within a package

Say you've started working on a new-to-you package (or resumed work on a long forgotten package of yours :wink:). How to know how it all hangs together?

One first way to understand what a given helper does is looking at its code, but also searching for occurrences of its names across R scripts, and using the [browser() function inside it or inside functions calling it](
One first way to understand). The first two tasks are static code analysis (well unless your brain really executes R code by reading it!), the latter is dynamic.

An useful tool is also the [in development `pkgapi` package](https://github.com/r-lib/pkgapi). Let's look at the [cranlogs source code](/2019/05/02/cranlogs-2-1-1/).


```r
map <- pkgapi::map_package("/home/maelle/Documents/R-hub/cranlogs")
```

We can see all defined functions, exported or not.


```r
str(map$defs)
```

```
## 'data.frame':	8 obs. of  7 variables:
##  $ name    : chr  "check_date" "cran_downloads" "cran_top_downloads" "cranlogs_badge" ...
##  $ file    : chr  "R/utils.R" "R/cranlogs.R" "R/cranlogs.R" "R/badge.R" ...
##  $ line1   : int  1 61 183 16 136 104 116 125
##  $ col1    : int  1 1 1 1 1 1 1 1
##  $ line2   : int  6 102 206 33 152 114 123 134
##  $ col2    : int  1 1 1 1 1 1 1 1
##  $ exported: logi  FALSE TRUE TRUE TRUE FALSE FALSE ...
```

We can see all calls inside the package code, to functions from the package and other packages.


```r
str(map$calls)
```

```
## 'data.frame':	82 obs. of  9 variables:
##  $ file : chr  "R/badge.R" "R/badge.R" "R/badge.R" "R/badge.R" ...
##  $ from : chr  "cranlogs_badge" "cranlogs_badge" "cranlogs_badge" "cranlogs_badge" ...
##  $ to   : chr  "base::c" "base::match.arg" "base::paste0" "base::paste0" ...
##  $ type : chr  "call" "call" "call" "call" ...
##  $ line1: int  17 21 23 25 30 7 8 62 65 66 ...
##  $ line2: int  17 21 23 25 30 7 8 62 65 66 ...
##  $ col1 : int  38 14 14 16 3 14 14 35 8 17 ...
##  $ col2 : int  38 22 19 21 8 19 19 35 14 25 ...
##  $ str  : chr  "c" "match.arg" "paste0" "paste0" ...
```

We can filter that data.frame to only keep calls between functions defined in the package.


```r
library("magrittr")
internal_calls <- map$calls[map$calls$to %in% glue::glue("{map$name}::{map$defs$name}"),]

internal_calls %>%
  dplyr::arrange(to)
```

```
##           file           from                      to type line1 line2 col1
## 1 R/cranlogs.R cran_downloads    cranlogs::check_date call    69    69    7
## 2 R/cranlogs.R cran_downloads    cranlogs::check_date call    73    73    7
## 3 R/cranlogs.R        to_df_1 cranlogs::fill_in_dates call   122   122    3
## 4 R/cranlogs.R cran_downloads         cranlogs::to_df call   100   100    3
## 5 R/cranlogs.R          to_df       cranlogs::to_df_1 call   108   108    5
## 6 R/cranlogs.R          to_df       cranlogs::to_df_r call   106   106    5
##   col2           str
## 1   16    check_date
## 2   16    check_date
## 3   15 fill_in_dates
## 4    7         to_df
## 5   11       to_df_1
## 6   11       to_df_r
```

That table can help understand how a package works. One could combine that with a network visualization.



```r
library("visNetwork")
internal_calls <- internal_calls %>%
  dplyr::mutate(to = gsub("cranlogs\\:\\:", "", to))

nodes <- tibble::tibble(id = map$defs$name,
                        title = map$defs$file,
                        label = map$defs$name,
                        shape = dplyr::if_else(map$defs$exported,
                                               "triangle",
                                               "square"))

edges <- internal_calls[, c("from", "to")]


visNetwork(nodes, edges, height = "500px") %>%
  visLayout(randomSeed = 42) %>%
  visNodes(size = 10)
```

<!--html_preserve--><iframe src="/cranlogs-2019-11-01.html" width="100%" height="500px"></iframe><!--/html_preserve-->

In this interactive visualization one sees three exported functions (triangles), with only one that calls internal functions. Such a network visualization might not be that useful for bigger packages, and in our workflow is limited to `pkgapi`'s capabilities (e.g. not memoised functions)... but it's at least quite pretty.

### Explore internal functions across packages

Looking at helpers in other packages can help you write your own, e.g. looking at a package elegantly wrapping a web API could help you wrap another one elegantly too.

Bob Rudis [wrote a very interesting blog post about his exploration of R packages "utility belts" i.e. the utils.R files](https://rud.is/b/2018/04/08/dissecting-r-package-utility-belts/). We also recommend our own blog post [about reading the R source](/2019/05/14/read-the-source/).

## Conclusion

In this post we explained what internal functions are, and gave a few tips as to how to explore them within a package and across packages. We hope the post can help clear up a few doubts. Feel free to comment about further ideas or questions you may have.
