---
slug: user-preferences
title: "Persistent config and data for R packages"
authors:
  - Maëlle Salmon
date: "2020-03-05"
tags:
- package development
output: 
  html_document:
    keep_md: true
---

Does your R package work best with some configuration? 
You probably want it to be easily found by your package.
Does your R package download huge datasets that don't change much on the provider side? 
Maybe you want to save the corresponding data somewhere persistent so that things will go faster during the next R session. 
In this blog post we shall explain how an R package developer can go about using and setting persistent configuration and data on the user's machine.

## Preface: standard locations on the user's machine

Throughout this post we'll often refer to standard locations on the user's machine.
As [explained by Gábor Csárdi in an R-pkg-devel email](https://www.mail-archive.com/r-package-devel@r-project.org/msg02460.html), _"Applications can actually store user level configuration information, cached data, logs, etc. in the user's home directory, and there standard way to do this [depending on the operating system]."_
R packages that are on CRAN cannot write to the home directory without warning, but they can and should use standard locations.
To find where those are, package developers can use the [`rappdirs` package](https://github.com/r-lib/rappdirs).


```r
# Using an R6 object
rhub_app <- rappdirs::app_dir("rhub", "r-hub")
rhub_app$cache()
```

```
## [1] "/home/maelle/.cache/rhub"
```

```r
# or functions
rappdirs::user_cache_dir("rhub")
```

```
## [1] "/home/maelle/.cache/rhub"
```

On top of these non-R specific standard locations, we'll also mention the standard homes of R _options_ and _environment variables_, .Rprofile and .Renviron.

## User preferences

As written in [Android developer guidance](https://developer.android.com/training/id-auth/identify) and probably every customer service guide ever, _"Everyone likes it when you remember their name."_. 
Everyone probably likes it too when the barista at their favourite coffee shop remembers their usual orders. 
As an R package developer, what can you do for your R package to correctly assess user preferences and settings?

### Using options

In R, `options` _allow the user to set and examine a variety of global options which affect the way in which R computes and displays its results_. For instance, for the usethis package, the [`usethis.quiet` option can control whether usethis is chatty](https://github.com/r-lib/usethis/blob/c0acd1b5e43f03773a5934c1d937bf70b77a2557/principles.md#communicating-with-the-user)[^1]. Users either:

* write `options(usethis.quiet = TRUE)` at the beginning of a script or directly in the console;

* or write that same line in their [.Rprofile that's loaded before every session](https://rstats.wtf/r-startup.html), which is more persistent. 

Users can use a project-level or more global user-level .Rprofile. 
The use of a project-level .Rprofile overrides the user-level .Rprofile unless the project-level .Rprofile contains the following lines [as mentioned in the `blogdown` book](https://bookdown.org/yihui/blogdown/global-options.html):

```r
# in .Rprofile of the project
if (file.exists('~/.Rprofile')) {
  base::sys.source('~/.Rprofile', envir = environment())
}
# then set project options
```

For more startup tweaks, the user could adopt [the `startup` package](https://cran.r-project.org/web/packages/startup/index.html).

As a package developer in your code you can retrieve options by using `getOption()` whose second argument is a fallback for when the option hasn't been set by the user.
The use of options in the .Rprofile startup file is great for workflow packages like `usethis`, `blogdown`, etc., but shouldn't be used for, say, arguments influencing the results of a statistical function.

### Using environment variables

Environment variables, found via `Sys.getenv()` rather than `getOption()`, are appropriate for storing secrets (like [`GITHUB_PAT` for the `gh` package](https://github.com/r-lib/gh#tokens)) or the path to secrets on disk (like [`TWITTER_PAT` for `rtweet`](https://rtweet.info/articles/auth.html)), or not secrets (e.g. [the browser to use for `chromote`](https://github.com/rstudio/chromote#specifying-which-browser-to-use)).

Similar to using `options()` in the console or at the top of a script the user could use `Sys.setenv()`.
Obviously, secrets should not be written at the top of a script that's public.
To make environment variables persistent they need to be stored in a startup file, .Renviron.
.Renviron does not contain R code like .Rprofile, but rather key-value pairs that are only called via `Sys.getenv()`.

As a package developer, you probably want to at least document how to set persistent variables or provide a link to such documentation; and you could even provide helper functions like [what `rtweet` does](https://rtweet.info/reference/create_token.html).

### Using credential stores for secrets

Although say API keys can be stored in `.Renviron`, they could also be stored in a standard location depending on the operating system.
The [`keyring` package](https://github.com/r-lib/keyring#keyring) allows to interact with such credential stores.
You could either take it on as a dependency or recommend your user to use `keyring` and to add a line like

```r
Sys.setenv(SUPERSECRETKEY = keyring::key_get("myservice"))
```

in their scripts.

### Using an app dir for storing secrets

The `rhub` package stores and retrieves validated email addresses and corresponding tokens from [a standard location on disk](https://github.com/r-hub/rhub/blob/caa9bf7dddd64c36941f043575d10a6e7af6a7aa/R/email.R#L163), [as documented](https://r-hub.github.io/rhub/reference/validate_email.html#details):

```r
email_file <- function() {
  rhub_data_dir <- rappdirs::user_data_dir("rhub", "rhub")
  file.path(rhub_data_dir, "validated_emails.csv")
}
```

e.g. in my case


```r
rhub:::email_file()
```

```
## [1] "/home/maelle/.local/share/rhub/validated_emails.csv"
```

### Using a config file

The `batchtools` package expect its users to setup a config file somewhere if they don't want to use the defaults.
That somewhere can be several locations, as [explained in the `batchtools::findConfFile()` manual page](https://mllg.github.io/batchtools/reference/findConfFile.html).
Two of the possibilities are `rappdirs::user_config_dir("batchtools", expand = FALSE)` and `rappdirs::site_config_dir("batchtools")` which refer to standard locations that are different depending on the operating system.

### A good default experience

Obviously, on top of letting users set their own preferences, you probably want your package functions to have sensible defaults. :grin:

### Asking or guessing?

For basic information such as username, email, GitHub username, the [`whoami` package](https://github.com/r-lib/whoami#readme) does pretty well.


```r
whoami::whoami()
```

```
##                 username                 fullname            email_address 
##                 "maelle"          "Maëlle Salmon" "maelle.salmon@yahoo.se" 
##              gh_username 
##                 "maelle"
```

```r
whoami::email_address()
```

```
## [1] "maelle.salmon@yahoo.se"
```

In particular, for the email address, if the R environment variable `EMAIL` isn't set, `whoami` uses a call to `git` to find Git's global configuration. 
Similarly, the [`gert` package](https://jeroen.cran.dev/gert/) can find and return Git's preferences via [`gert::git_config_global()`](https://jeroen.cran.dev/gert/reference/git_config.html)[^2].

In these cases where packages _guess_ something, their guessing is based on the use of standard locations for such information on different operating systems. 
Unsurprisingly, in the next section, we'll recommend using such standard locations when caching _data_.

## Not so temporary files[^3]

To quote [Android developers guide](https://developer.android.com/jetpack/docs/guide#best-practices) again, _"Persist as much relevant and fresh data as possible."_.

A package that exemplifies doing so is [`getlandsat`](https://docs.ropensci.org/getlandsat/) that downloads "Landsat 8 data from AWS public data sets" from the web.
The first time the user [downloads an image](https://docs.ropensci.org/getlandsat/reference/lsat_image.html), the result is cached so next time no query needs to be made.
A very nice aspect of `getlandsat` is its providing [cache management functions](https://docs.ropensci.org/getlandsat/reference/lsat_cache.html)



```r
library("getlandsat")
# list files in cache
lsat_cache_list()
```

```
## [1] "/home/maelle/.cache/landsat-pds/L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B3.TIF"
## [2] "/home/maelle/.cache/landsat-pds/L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B4.TIF"
## [3] "/home/maelle/.cache/landsat-pds/L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B7.TIF"
```

```r
# List info for single files
lsat_cache_details(files = lsat_cache_list()[1])
```

```
## <landsat cached files>
##   directory: /home/maelle/.cache/landsat-pds
## 
##   file: /L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B3.TIF
##   size: 64.624 mb
```

```r
lsat_cache_details(files = lsat_cache_list()[2])
```

```
## <landsat cached files>
##   directory: /home/maelle/.cache/landsat-pds
## 
##   file: /L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B4.TIF
##   size: 65.36 mb
```

```r
# List info for all files
lsat_cache_details()
```

```
## <landsat cached files>
##   directory: /home/maelle/.cache/landsat-pds
## 
##   file: /L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B3.TIF
##   size: 64.624 mb
## 
##   file: /L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B4.TIF
##   size: 65.36 mb
## 
##   file: /L8/001/002/LC80010022016230LGN00/LC80010022016230LGN00_B7.TIF
##   size: 62.974 mb
```

```r
# delete files by name in cache
# lsat_cache_delete(files = lsat_cache_list()[1])

# delete all files in cache
# lsat_cache_delete_all()
```


The `getlandasat` [uses the `rappdirs` package](https://github.com/ropensci/getlandsat/blob/b753ec8a4254953565a2a8a5f200a70e34c68bbf/R/cache.R#L111) we mentioned earlier.

```r
lsat_path <- function() rappdirs::user_cache_dir("landsat-pds")
```

When using `rappdirs`, keep [caveats](https://rdrr.io/cran/rappdirs/man/rappdirs-package.html#heading-3) in mind.

If you hesitate to use e.g. `rappdirs::user_cache_dir()` vs `rappdirs::user_data_dir()`, use a [GitHub code search](/2019/05/14/read-the-source/#how-to-search-the-source).

### rappdirs or not

To use an app directory from within your package you can use `rappdirs` as mentioned earlier, but also other tools.

* Package developers might also like the [`hoardr` package](https://docs.ropensci.org/hoardr/) that basically creates an R6 object building on `rappdirs` with a few more methods (directory creation, deletion).

<!--html_preserve-->{{% tweet "1233495999982628865" %}}<!--/html_preserve-->

* Some package authors "roll their own" like Henrik Bengtsson in [`R.cache`](https://github.com/HenrikBengtsson/R.cache).

<!--html_preserve-->{{% tweet "1233487759412809734" %}}<!--/html_preserve-->

* R-devel "just gained support for OS-agile user-specific #rstats cache/config/data folders" [which is big](https://twitter.com/henrikbengtsson/status/1233496382608199683) (but if you use the base R implementation available after R 4.x.y, [unless your package depends on R above that version you'll need to backport the functionality](https://twitter.com/JennyBryan/status/1233506099292246016)).

## More or less temporary solutions

A bit out-of-scope for this post but nonetheless interesting are solutions for caching results very temporarily, or less temporarily.

### Caching results within an R session

To cache results within an R session, you could use a temporary directory for data.
For any function call you could use `memoise` that supports, well [memoization](https://en.wikipedia.org/wiki/Memoization) which is best explained with an example.


```r
time <- memoise::memoise(Sys.time)
time()
```

```
## [1] "2020-03-04 13:37:20 CET"
```

```r
Sys.sleep(1)
time()
```

```
## [1] "2020-03-04 13:37:20 CET"
```

Only the first call to `time()` actually calls `Sys.time()`, after that the results is saved for the entire session unless `memoise::forget()` is called.
It is great for speeding up code, and for [not abusing internet resources which is why the `polite` package wraps `memoise`](https://dmi3kno.github.io/polite/).

### Providing a ready-to-use dataset in a non-CRAN package

If your package depends on the use of a huge dataset, the same for all users, that is by definition too huge for CRAN, you can use [a setup like the one presented by Brooke Anderson and Dirk Eddelbuettel in which the data is packaged up in a separate package not on CRAN](https://journal.r-project.org/archive/2017/RJ-2017-026/index.html), that the user will install therefore saving the data on disk somewhere where you can find it easily.

## Conclusion

In this blog post we presented ways of saving configuration options and data in a not so temporary way in R packages.
We mentioned R startup files (options in .Rprofile and secrets in .Renviron, the `startup` package); the `rappdirs` and `hoardr` packages as well as an exciting similar feature in R devel; the keyring package.
Writing in the user home directory can be viewed as invasive (and can trigger CRAN archival), hence there is a need for a good package design (asking for confirmation; providing cache management functions like `getlandsat` does) and documentation for transparency.
Do _you_ use any form of caching on disk with a default location in one of your packages? 
Did you know where your `rhub` email token lived? :wink:

[^1]: Note that in tests `usethis` suppresses the chatty behaviour by the use of [`withr::local_options(list(usethis.quiet = FALSE))`](https://github.com/r-lib/usethis/blob/7af1aa2e0ac0b699fdd39f5cfbe4d1ccba41bc48/tests/testthat/test-use-pipe.R#L36).
[^2]: The `gert` package uses libgit2, not Git directly.
[^3]: We're using the [very good email subject by Roy Mendelssohn](https://www.mail-archive.com/r-package-devel@r-project.org/msg02450.html) on [R-pkg-devel](/2019/04/11/r-package-devel/).
