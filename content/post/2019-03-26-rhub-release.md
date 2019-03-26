---
date: "2019-03-26"
title: rhub 1.1.0 is on CRAN!
---

Version 1.1.0 of the `rhub` package has been released on CRAN! `rhub` allows to check packages on R-hub package builder, 
or on local Docker images, _without leaving R_.

Get `rhub`'s latest version from 
a [safe](https://rud.is/b/2019/03/03/cran-mirror-security/) CRAN mirror near
you:

```r
install.packages("rhub")
```

This release should improve user experience thanks to several :sparkles: new 
features :sparkles: and one bug fix :wave: :bug:.


## New features

### Extract builds from list

### Solaris check shortcut

### Local Docker checks! Not for Windows yet

* New `local_check_linux()` function to run an R-hub check on the local
  host's Docker. New `local_check_linux_images()` function to list R-hub
  Docker images.

* New `check_on_solaris()` shortcut to check on Solaris X86, without
  building the PDF manual or the vignettes.

* New `get_check()` function that works with check ids, or a check group id.

* `list_package_checks()` and `list_my_checks()` now output a `tibble`, that is nicely formatted when printed to the screen.

* The output of `get_check()`, `check()`, `check_on_`, `check_for_cran()`,
  etc. functions gained
    * an `urls()` method returning a `data.frame` with URLs to the html and
    text logs, as well as the artifacts, of the check(s);
    * a `browse()` method replacing the `web()` method for opening the
  URLs corresponding to a `rhub_check` object.


### Better helper for CRAN submissions

The output of `check_` functions, in particular `check_for_cran()`, and of `get_check()` has a new `cran_summary()` method to print a summary ready to copy-paste in your cran-comments.md. So, here's how you can use `rhub` as part of your CRAN submission preparation: First, run `check_for_cran()` and assign the result to an object (or retrieve 
the results from a previous `check_for_cran()` submission by its `group` ID 
as shown in the previous subsection). Then once the checks are done, 
use the `cran_summary()` method to get a message that you can copy-paste in 
your cran-comments.md file (created via e.g. `usethis::use_cran_comments()`).

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
 whose checklist suggest using R-hub :-);
 
 * `usethis::use_release_issue()` opens an issue with a handy checklist in your GitHub issue tracker;

* [this book chapter](https://r-pkgs.org/release.html#release-process);

* [this collaborative list](https://github.com/ThinkR-open/prepare-for-cran).



## Bug fix

In printing methods the submitted time is now always correct thanks to explicitly specifying units for `as.numeric.difftime`. Thanks to [Jim Hester](https://github.com/) and [Barret Schloerke](https://github.com/schloerke)!