---
title: Internal functions in R packages
date: '2019-11-01'
slug: internal functions
tags:
  - package development
---

An R package can be viewed as a [set of functions](https://github.com/ropensci/software-review/issues/350#issue-518124603), part of which are exposed to the user, part of which are not. In this blog post we shall explain what the latter, internal functions, are good for, and we shall present the best practice for documenting and testing them.

## Internal functions 101

### What is an internal function? 

It's a function that your package functions know about, but that isn't surfaced to the user. You could also call it unexported function or helper function as opposed to exported functions, and user-facing functions.

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

* In a package you want to provide your user an API that is useful and stable. You can vouch for a few functions, that work well, serve the package main goals, are documented enough, and that you'd only change[with great care](https://devguide.ropensci.org/evolution.html) [if need be](https://ropensci.org/blog/2019/04/30/qualtrics-relaunch/). If your package users rely of an internal function that you decide to ditch when re-factoring code, they won't be happy, so only export what you want to maintain.

* If all packages exposed all their internal functions, the user environment would be flooded and the namespace conflicts would be out of control.

### Why write internal functions?

Why writing internal functions instead of having everything in one block of code inside each exported functions?

When writing R code in general [there are several reasons to write functions](https://r4ds.had.co.nz/functions.html) and it is the same within R packages: you can re-use a bit of code in several places (e.g. an epoch converter used for the output of several endpoints from a web API), and you can give it a self-explaining name (e.g. `convert_epoch()`). 

Having internal functions also means you can test these bits of code on their own. That said [if you test internals too much re-factoring your code will mean breaking tests so you might want to focus testing on external functions](https://r-pkgs.org/tests.html).

To find blocks of code that could be replaced with a function used several times, you could use [the `dupree` package](https://cran.r-project.org/web/packages/dupree/index.html) whose planned enhancements [include highlighting or printing the similar blocks](https://github.com/russHyde/dupree/issues/48).

### When not to write internal functions?

There is a balance to be found between writing your own helpers for everything and only depending on external code. [You can watch this excellent code on the topic](https://resources.rstudio.com/rstudio-conf-2019/it-depends-a-dialog-about-dependencies).

### Where to put internal functions?

You could save internal functions used in one function only in the R file defining that function, and internal functions used in several other functions in a single utils.R file or specialized utils-dates.R, utils-encoding.R files.

### How to document internal functions?

You should at least add a few comments in their code as usual. Best practice recommended in the [tidyverse style guide](https://style.tidyverse.org/documentation.html#internal-functions) and the [rOpenSci dev guide](https://devguide.ropensci.org/building.html) is to document them with roxygen2 tags like other functions, but to use `#' @NoRd` to prevent manual pages to be created. 

The keyword `@keyword internal` would mean [a manual page is created but not present in the function index](https://roxygen2.r-lib.org/articles/rd.html#indexing).

## Explore internal functions

You might need to have a look at the guts of a package when wanting to contribute to it, or at the guts of several packages to get some inspiration for your code.

### Explore internal functions within a package

Say you've started working on a new-to-you package (or resumed work on a long forgotten package of yours :wink:). How to know how it all hangs together?

One first way to understand what a given helper does is looking at its code, but also searching for occurrences of its names across R scripts, and using the [browser() function inside it or inside functions calling it](
One first way to understand). The first two tasks are static code analysis (well unless your brain really executes R code by reading it!), the latter is dynamic.

An useful tool is also the `pkgapi` package. Let's look at the [rversions source code](/2019/04/15/rversions-1-1-0/).


```r
map <- pkgapi::map_package("/home/maelle/Documents/R-hub/rversions")
```

We can see all defined functions, exported or not.


```r
knitr::kable(map$defs)
```



|name                 |file          | line1| col1| line2| col2|exported |
|:--------------------|:-------------|-----:|----:|-----:|----:|:--------|
|cached_nicks         |R/nicks.R     |     2|    1|    46|    1|FALSE    |
|cran_url             |R/urls.R      |     5|    1|    11|    1|FALSE    |
|fetch_all            |R/nicks.R     |    63|    1|    76|    1|FALSE    |
|get_content          |R/nicks.R     |    78|    1|    83|    1|FALSE    |
|get_nicknames        |R/nicks.R     |    48|    1|    61|    1|FALSE    |
|keep_head            |R/keep-head.R |     2|    1|    22|    1|FALSE    |
|lapply_named         |R/nicks.R     |    85|    1|    87|    1|FALSE    |
|r_download_url       |R/urls.R      |    13|    1|    15|    1|FALSE    |
|r_macos_download_url |R/urls.R      |    21|    1|    23|    1|FALSE    |
|r_oldrel             |R/rversions.R |    69|    1|    81|    1|TRUE     |
|r_release            |R/rversions.R |    50|    1|    52|    1|TRUE     |
|r_release_macos      |R/macos.R     |    19|    1|    21|    1|TRUE     |
|r_release_tarball    |R/tarball.R   |    19|    1|    21|    1|TRUE     |
|r_release_win        |R/win.R       |    19|    1|    21|    1|TRUE     |
|r_svn_url            |R/urls.R      |     1|    1|     3|    1|FALSE    |
|r_versions           |R/rversions.R |    20|    1|    34|    1|TRUE     |
|r_versions_fetch     |R/rversions.R |    84|    1|   116|    1|FALSE    |
|r_win_download_url   |R/urls.R      |    17|    1|    19|    1|FALSE    |
|squote               |R/nicks.R     |    93|    1|    95|    1|FALSE    |
|str_trim             |R/nicks.R     |    89|    1|    91|    1|FALSE    |

We can see all calls inside the package code, to functions from the package and other packages.


```r
str(map$calls)
```

```
## 'data.frame':	108 obs. of  9 variables:
##  $ file : chr  "R/keep-head.R" "R/keep-head.R" "R/keep-head.R" "R/keep-head.R" ...
##  $ from : chr  "keep_head" "keep_head" "keep_head" "keep_head" ...
##  $ to   : chr  "utils::tail" "rversions::r_versions" "curl::new_handle" "curl::handle_setopt" ...
##  $ type : chr  "call" "call" "call" "call" ...
##  $ line1: int  3 3 4 5 6 8 9 10 11 15 ...
##  $ line2: int  3 3 4 5 6 8 9 10 11 15 ...
##  $ col1 : int  15 20 13 3 3 13 17 12 13 20 ...
##  $ col2 : int  18 29 22 15 15 16 22 17 29 26 ...
##  $ str  : chr  "tail" "r_versions" "new_handle" "handle_setopt" ...
```

We can filter that data.frame to only keep calls between functions defined in the package.


```r
library("magrittr")
map$calls[map$calls$to %in% glue::glue("{map$name}::{map$defs$name}"),] %>%
  dplyr::arrange(to) %>%
  knitr::kable()
```



|file          |from                 |to                              |type | line1| line2| col1| col2|str                  |
|:-------------|:--------------------|:-------------------------------|:----|-----:|-----:|----:|----:|:--------------------|
|R/rversions.R |r_versions           |rversions::cached_nicks         |call |    25|    25|   12|   23|cached_nicks         |
|R/urls.R      |r_download_url       |rversions::cran_url             |call |    14|    14|   10|   17|cran_url             |
|R/urls.R      |r_win_download_url   |rversions::cran_url             |call |    18|    18|   10|   17|cran_url             |
|R/urls.R      |r_macos_download_url |rversions::cran_url             |call |    22|    22|   10|   17|cran_url             |
|R/nicks.R     |get_nicknames        |rversions::fetch_all            |call |    56|    56|   12|   20|fetch_all            |
|R/rversions.R |r_versions           |rversions::get_nicknames        |call |    27|    27|   41|   53|get_nicknames        |
|R/macos.R     |r_release_macos      |rversions::keep_head            |call |    20|    20|    3|   11|keep_head            |
|R/tarball.R   |r_release_tarball    |rversions::keep_head            |call |    20|    20|    3|   11|keep_head            |
|R/win.R       |r_release_win        |rversions::keep_head            |call |    20|    20|    3|   11|keep_head            |
|R/nicks.R     |fetch_all            |rversions::lapply_named         |call |    75|    75|    3|   14|lapply_named         |
|R/tarball.R   |r_release_tarball    |rversions::r_download_url       |call |    20|    20|   13|   26|r_download_url       |
|R/macos.R     |r_release_macos      |rversions::r_macos_download_url |call |    20|    20|   13|   32|r_macos_download_url |
|R/rversions.R |r_versions_fetch     |rversions::r_svn_url            |call |    88|    88|   30|   38|r_svn_url            |
|R/keep-head.R |keep_head            |rversions::r_versions           |call |     3|     3|   20|   29|r_versions           |
|R/nicks.R     |get_nicknames        |rversions::r_versions           |call |    48|    48|   34|   43|r_versions           |
|R/rversions.R |r_release            |rversions::r_versions           |call |    51|    51|    8|   17|r_versions           |
|R/rversions.R |r_oldrel             |rversions::r_versions           |call |    71|    71|   15|   24|r_versions           |
|R/rversions.R |r_versions           |rversions::r_versions_fetch     |call |    21|    21|    9|   24|r_versions_fetch     |
|R/win.R       |r_release_win        |rversions::r_win_download_url   |call |    20|    20|   13|   30|r_win_download_url   |
|R/nicks.R     |get_content          |rversions::squote               |call |    80|    80|   33|   38|squote               |
|R/nicks.R     |get_content          |rversions::str_trim             |call |    82|    82|    3|   10|str_trim             |

That table can help understand how a package works. One could combine that with a network visualization.

### Explore internal functions across packages

Bob Rudis [wrote a very interesting blog post about his exploration of R packages "utility belts" i.e. the utils.R files](https://rud.is/b/2018/04/08/dissecting-r-package-utility-belts/). We also recommend our own blog post [about reading the R source](/2019/05/14/read-the-source/).
