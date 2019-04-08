---
date: "2019-04-08"
title: rhub 1.1.1 is on CRAN!
slug: rhub-1.1.1
---

Version 1.1.1 of the `rhub` package has been released on CRAN! `rhub` allows to check packages on R-hub package builder, 
or on local Docker images, _without leaving R_.

Get `rhub`'s latest version from 
a [safe](https://rud.is/b/2019/03/03/cran-mirror-security/) CRAN mirror near
you:

```r
install.packages("rhub")
```

This release, compared to `rhub` 1.0.2, should improve user experience thanks to several :sparkles: new 
features :sparkles: and two bug fixes :wave: :bug: :bug:.


## New features

### List and extract checks

The `list_package_checks()` and `list_my_checks()`, that help you browse your previous checks, now output a `tibble` which is nicely formatted when printed to the screen. 

```r
list_my_checks(howmany = 2)
```

```r
# A tibble: 6 x 13
  package version result group   id      platform_name build_time
  <chr>   <chr>   <rhub> <rhub:> <rhub:> <chr>         <time>    
1 namer   0.1.4   ok     0a0dee9 051154f ubuntu-gcc-r… ~13m      
2 namer   0.1.4   ok     0a0dee9 417e55c windows-x86_… ~2m       
3 namer   0.1.4   ok     0a0dee9 f082296 fedora-clang… ~18m      
4 note    1.0     NN     fd088cf 4cb8d3e ubuntu-gcc-r… ~1m       
5 note    1.0     NN     fd088cf 8162246 windows-x86_… ~1m       
6 note    1.0     NN     fd088cf a9c5420 fedora-clang… ~1m       
# … with 6 more variables: submitted <dttm>, started <dttm>, platform <list>,
#   builder <chr>, status <rhub::status>, email <chr>
```

Furthermore, the `get_check()` function allows extracting a check or group of simultaneously submitted checks with check ids, or a check group id. For instance, to extract the check corresponding to the first id in the `tibble` above,

```r
rhub::get_check("051154f")
```

```r
── namer 0.1.4: OK

  Build ID:   namer_0.1.4.tar.gz-051154f0c636463a8ff5a6aa282f8e9c
  Platform:   Ubuntu Linux 16.04 LTS, R-release, GCC
  Submitted:  1h 8m 13.1s ago
  Build time: 13m 4.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

### Find your checks and their artifacts on the web

The output of `get_check()`, `check()`, `check_on_`, `check_for_cran()`,
  etc. functions gained
    
* an `urls()` method returning a `data.frame` with URLs to the html and text logs, as well as the artifacts, of the check(s);
    
```r
rhub::get_check("051154f")$urls()
``` 

```r
# A tibble: 1 x 4
html                text                artifacts             stringsAsFactors
<chr>               <chr>               <chr>                 <lgl>           
1 https://builder-te… https://builder-te… https://artifacts.r-… FALSE   
```
    
* a `browse()` method replacing the `web()` method for opening the URLs corresponding to a `rhub_check` object.

### Solaris check shortcut

You can now use the `check_on_solaris()` shortcut to check on Solaris X86, without building the PDF manual or the vignettes, because building them was 
a source of failures (you can check your package with manual and vignettes on other platforms!).

### Local Docker checks! Not for Windows yet :crying_cat_face:

Two new functions help you make the most of R-hub Docker Linux images:

* `local_check_linux_images()` lists R-hub Docker images.
* `local_check_linux()` allows to run an R-hub check on the local
  host's Docker. The function is doesn't work on Windows yet, which we plan to solve in the next CRAN release.
  
Find more information in the dedicated vignette [Local Linux checks with Docker](https://r-hub.github.io/rhub/articles/local-debugging.html).

### Better helper for CRAN submissions

The output of `check_` functions, in particular `check_for_cran()`, and of `get_check()` has a new `cran_summary()` method to print a summary ready to copy-paste in your cran-comments.md. **So, here's how you can use `rhub` as part of your CRAN submission preparation:, in video and written form.** 

#### `rhub` and CRAN submission preparation, screencast


{{< vimeo 329059890 >}}

#### `rhub` and CRAN submission preparation, script

First, run `check_for_cran()` and assign the result to an object. Then once the checks are done, use the `cran_summary()` method to get a message that you can copy-paste in your cran-comments.md file (created via e.g. `usethis::use_cran_comments()`).

```r
cran_prep <- check_for_cran()
cran_prep$cran_summary()
#> ## Test environments
#> - R-hub fedora-clang-devel (r-devel)
#>  - R-hub windows-x86_64-devel (r-devel)
#>  - R-hub ubuntu-gcc-release (r-release)
#> 
#> ## R CMD check results
#> ❯ On fedora-clang-devel (r-devel), windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release)
#>   checking CRAN incoming feasibility ... NOTE
#>   Maintainer: ‘Maëlle Salmon <maelle.salmon@yahoo.se>’
#>   
#>   New submission
#>   
#>   The Description field contains
#>     <http://http://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file>
#>   Please enclose URLs in angle brackets (<...>).
#>   
#>   The Date field is over a month old.
#> 
#> ❯ On fedora-clang-devel (r-devel), windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release)
#>   checking R code for possible problems ... NOTE
#>   .bello: no visible global function definition for ‘tail’
#>   Undefined global functions or variables:
#>     tail
#>   Consider adding
#>     importFrom("utils", "tail")
#>   to your NAMESPACE file.
#> 
#> 0 errors ✔ | 0 warnings ✔ | 2 notes ✖

```

For more general information about CRAN submissions, refer to 

* [CRAN itself](https://cran.r-project.org//web//packages//submission_checklist.html)
 whose checklist suggest using R-hub :sunglasses:;
 
* `usethis::use_release_issue()` that opens an issue with a handy checklist, including an item about R-hub :sunglasses:, in your GitHub issue tracker;

* [this book chapter](https://r-pkgs.org/release.html#release-process);

* [this collaborative list](https://github.com/ThinkR-open/prepare-for-cran).

## Bug fixes

In printing methods the submitted time is now always correct thanks to explicitly specifying units for `as.numeric.difftime`. Thanks to [Jim Hester](https://github.com/) and [Barret Schloerke](https://github.com/schloerke)!


## That's a wrap!

The best place to get to know `rhub` is [its brand-new documentation website built with `pkgdown`](https://r-hub.github.io/rhub), and the best place to provide feedback or contribute is [its GitHub repo](https://github.com/r-hub/rhub). Thanks to all folks who chimed in in the issue tracker and pull request tab!
