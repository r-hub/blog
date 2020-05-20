---
slug: rbuildignore
title: "Non-standard files/directories, Rbuildignore and inst"
authors:
  - Maëlle Salmon
date: "2020-05-20"
tags:
- package development
- standards
output: 
  html_document:
    keep_md: true
---




Paragraphasing [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Creating-R-packages), an R package is _"directory of files which extend R"_.
These files have to follow [a standard structure](https://r-pkgs.org/package-structure-state.html): you can't store everything that suits your fancy in a tarball you submit to CRAN.
In this post we shall go through what directories and files _can_ go on CRAN and how to navigate this while shipping everything you want to CRAN and keeping some things in the package source only.

## Standard, known directory and files

At the moment of writing, what a built package can contain is [this list called `known`](https://github.com/wch/r-source/blob/512f39773b05a85ae53103c799bb9ca20ac2dced/src/library/tools/R/check.R#L1365)[^rabbit] defined in the R source, in `tools/R/check.R`.

```r
known <- c("DESCRIPTION", "INDEX", "LICENCE", "LICENSE",
           "LICENCE.note", "LICENSE.note",
           "MD5", "NAMESPACE", "NEWS", "PORTING",
           "COPYING", "COPYING.LIB", "GPL-2", "GPL-3",
           "BUGS", "Bugs",
           "ChangeLog", "Changelog", "CHANGELOG", "CHANGES", "Changes",
           "INSTALL", "README", "THANKS", "TODO", "ToDo",
           "INSTALL.windows",
           "README.md", "NEWS.md",
           "configure", "configure.win", "cleanup", "cleanup.win",
           "configure.ac", "configure.in",
           "datafiles",
           "R", "data", "demo", "exec", "inst", "man",
           "po", "src", "tests", "vignettes",
           "build",       # used by R CMD build
           ".aspell",     # used for spell checking packages
           "java", "tools", "noweb") # common dirs in packages.
```

In this post, we won't go into what these directories and files can contain and how they should be formatted, which is another standard.
We'll focus on their mere existence.

## Non-standard files

Now, in a package folder, you might have all sorts of different things

* some configuration files for continuous integration, for a `pkgdown` website, etc;
* the source of a Shiny app;
* cran-comments.md for your CRAN submissions.

If they ended up at the root of the bundled package, R CMD check would complain and tell you

> :rage: Non-standard files/directories found at top level:

Note that sometimes R CMD check could complain about files you don't see in the source because they are created by the checking process. 
In that case, [take a step back and try to fix your code, e.g. cleaning after yourself if examples create files.](https://www.mail-archive.com/r-package-devel@r-project.org/msg03254.html)

Now, how do you keep the items that sparkle joy in the bundled package and in your package source, without endangering R CMD check passing?

## Excluding files from the bundled package

There are files that don't need to make it into a built package (e.g., your CRAN comments, your `pkgdown` config.).

### R CMD build filtering

To prevent files and folders from making it from the package source to the bundled package, we need to understand how things work:
How do files and directories end up, or not, in the tarball/bundled package, from the source package?
That's one job of [R CMD build](https://cran.r-project.org/doc/manuals/R-exts.html#Building-package-tarballs) possibly via a wrapper like [`devtools::build()`](http://devtools.r-lib.org/reference/build.html).
It will copy your whole package source and then remove files in three "steps"[^copy]

* Files that are [listed in `.Rbuildignore`](https://github.com/wch/r-source/blob/1d4f7aa1dac427ea2213d1f7cd7b5c16e896af22/src/library/tools/R/build.R#L75);
    
```r
## Check for files listed in .Rbuildignore or get_exclude_patterns()
inRbuildignore <- function(files, pkgdir) {
    exclude <- rep.int(FALSE, length(files))
    ignore <- get_exclude_patterns()
    ## handle .Rbuildignore:
    ## 'These patterns should be Perl regexps, one per line,
    ##  to be matched against the file names relative to
    ##  the top-level source directory.'
    ignore_file <- file.path(pkgdir, ".Rbuildignore")
    if (file.exists(ignore_file))
	ignore <- c(ignore, readLines(ignore_file, warn = FALSE))
    for(e in ignore[nzchar(ignore)])
	exclude <- exclude | grepl(e, files, perl = TRUE,
				ignore.case = TRUE)
    exclude
}
```
    
* And some [standard exclude patterns](https://github.com/wch/r-source/blob/1d4f7aa1dac427ea2213d1f7cd7b5c16e896af22/src/library/tools/R/build.R#L53)
    
```r
get_exclude_patterns <- function()
    c("^\\.Rbuildignore$",
      "(^|/)\\.DS_Store$",
      "^\\.(RData|Rhistory)$",
      "~$", "\\.bak$", "\\.swp$",
      "(^|/)\\.#[^/]*$", "(^|/)#[^/]*#$",
      ## Outdated ...
      "^TITLE$", "^data/00Index$",
      "^inst/doc/00Index\\.dcf$",
      ## Autoconf
      "^config\\.(cache|log|status)$",
      "(^|/)autom4te\\.cache$", # ncdf4 had this in subdirectory 'tools'
      ## Windows dependency files
      "^src/.*\\.d$", "^src/Makedeps$",
      ## IRIX, of some vintage
      "^src/so_locations$",
      ## Sweave detrius
      "^inst/doc/Rplots\\.(ps|pdf)$"
      )
```

* And then [some more out-of-the-box exclusion](https://github.com/wch/r-source/blob/1d4f7aa1dac427ea2213d1f7cd7b5c16e896af22/src/library/tools/R/build.R#L1027)
    
```r
exclude <- inRbuildignore(allfiles, pkgdir)

isdir <- dir.exists(allfiles)
## old (pre-2.10.0) dirnames
exclude <- exclude | (isdir & (bases %in%
                               c("check", "chm", .vc_dir_names)))
exclude <- exclude | (isdir & grepl("([Oo]ld|\\.Rcheck)$", bases))
## FIXME: GNU make uses GNUmakefile (note capitalization)
exclude <- exclude | bases %in% c("Read-and-delete-me", "GNUMakefile")
## Mac resource forks
exclude <- exclude | startsWith(bases, "._")
exclude <- exclude | (isdir & grepl("^src.*/[.]deps$", allfiles))
## Windows DLL resource file
exclude <- exclude | (allfiles == paste0("src/", pkgname, "_res.rc"))
## inst/doc/.Rinstignore is a mistake
exclude <- exclude | endsWith(allfiles, "inst/doc/.Rinstignore") |
    endsWith(allfiles, "inst/doc/.build.timestamp") |
    endsWith(allfiles, "vignettes/.Rinstignore")
## leftovers
exclude <- exclude | grepl("^.Rbuildindex[.]", allfiles)
        ## or simply?  exclude <- exclude | startsWith(allfiles, ".Rbuildindex.")
        exclude <- exclude | (bases %in% .hidden_file_exclusions)
```

Of particular interest is [`.vc_dir_names`](https://github.com/wch/r-source/blob/68c9ec863d59d9757da8a8603e684c48c5178622/src/library/tools/R/utils.R#L564): had you noticed your `.git` folder was magically not included in the bundled package?[^git] 

```r
## Version control directory names: CVS, .svn (Subversion), .arch-ids
## (arch), .bzr, .git, .hg (mercurial) and _darcs (Darcs)
## And it seems .metadata (eclipse) is in the same category.

.vc_dir_names <-
    c("CVS", ".svn", ".arch-ids", ".bzr", ".git", ".hg", "_darcs", ".metadata")
```

And [`.hidden_file_exclusions`](https://github.com/wch/r-source/blob/68c9ec863d59d9757da8a8603e684c48c5178622/src/library/tools/R/utils.R#L577)

```r
## We are told
## .Rproj.user is Rstudio
## .cproject .project .settings are Eclipse
## .exrc is for vi
## .tm_properties is Mac's TextMate
.hidden_file_exclusions <-
    c(".Renviron", ".Rprofile", ".Rproj.user",
      ".Rhistory", ".Rapp.history",
      ".tex", ".log", ".aux", ".pdf", ".png",
      ".backups", ".cvsignore", ".cproject", ".directory",
      ".dropbox", ".exrc", ".gdb.history",
      ".gitattributes", ".gitignore", ".gitmodules",
      ".hgignore", ".hgtags",
      ".htaccess",
      ".latex2html-init",
      ".project", ".seed", ".settings", ".tm_properties")
```

Note that `R CMD build` will _silently_ remove files from the bundled package, which [is a source of weird errors](https://www.mail-archive.com/r-package-devel@r-project.org/msg01325.html).
For instance, if you wrote a wrong pattern in `.Rbuildignore` that ends up removing one of your R files, R CMD check will complain about a function not existing and you might be a bit puzzled.

### .Rbuildignore

So, if your package source features any file or directory that is not known, not standard, and also not listed in the common exclusions, then you need to add it to [`.Rbuildignore`](https://cran.r-project.org/doc/manuals/R-exts.html#index-_002eRbuildignore-file).

As written in "Writing R extensions", _"To exclude files from being put into the package, one can specify a list of exclude patterns in file .Rbuildignore in the top-level source directory. These patterns should be Perl-like regular expressions (see the help for regexp in R for the precise details), one per line, to be matched case-insensitively against the file and directory names relative to the top-level package source directory."_.

Below is [`knitr` `.Rbuildignore`](https://github.com/yihui/knitr/blob/master/.Rbuildignore)

```r
.gitignore
tikzDictionary$
aux$
log$
out$
inst/examples/knitr-.*.pdf
inst/examples/child/knitr-.*.pdf
inst/examples/child/knitr-.*\.md
inst/examples/figure
inst/examples/cache
knitr-minimal.md
knitr-spin.md
png$
^\.Rproj\.user$
^.*\.Rproj$
^\.travis\.yml$
FAQ.md
Makefile
^knitr-examples$
^\.github$
^docs$
^README-ES\.md$
^README-PT\.md$
^codecov\.yml$
^NEWS\.md$
```

#### How to edit `.Rbuildignore`?

You could edit `.Rbuildignore` by hand, from the command line, or using [`usethis::use_build_ignore()`](https://usethis.r-lib.org/reference/use_build_ignore.html) that will escape paths by default.
There is also the [`usethis::edit_r_buildignore()`](https://usethis.r-lib.org/reference/edit.html) function for creating/opening the user-level or project-level `.Rbuildignore`.

#### When to edit `.Rbuildignore`?

You could edit `.Rbuildignore` when R CMD check complains, or when creating non-standard files.
This is where [workflow tools](/2020/04/29/maintenance/) can help.
If you e.g. use `usethis::use_cran_comments()` to create `cran-commends.md`, it will also add it to `.Rbuildignore`

## Keeping non-standard things in the bundled package

Now you might wonder, how do I package up a Shiny app, a raw data file, etc. if they're not allowed at the root of a bundled package?
Well, easy, keep them but not at the root, ah!
More seriously, a good idea is to look at existing practice in recent CRAN packages.
Often, you'll see stuff is stored in `inst/`: classic elements such as citation information in `inst/CITATION`[^citation], [raw data in `inst/extdata/`](https://r-pkgs.org/data.html#data-extdata) but also more modern or exotic elements such as [RStudio addins](https://github.com/ThinkR-open/remedy/tree/master/inst/rstudio).

## What about .Rinstignore?

`.Rbuildignore` has [a sibling called `.Rinstignore` for another use case](https://cran.r-project.org/doc/manuals/R-exts.html#index-_002eRinstignore-file): _"The contents of the inst subdirectory will be copied recursively to the installation directory. Subdirectories of inst should not interfere with those used by R (currently, R, data, demo, exec, libs, man, help, html and Meta, and earlier versions used latex, R-ex). The copying of the inst happens after src is built so its Makefile can create files to be installed. To exclude files from being installed, one can specify a list of exclude patterns in file .Rinstignore in the top-level source directory. These patterns should be Perl-like regular expressions[^extras] (see the help for regexp in R for the precise details), one per line, to be matched case-insensitively against the file and directory paths, e.g. doc/.*[.]png$ will exclude all PNG files in inst/doc based on the extension."_

See for instance [`future.apply` `.Rinstignore`](https://github.com/HenrikBengtsson/future.apply/blob/58f5a21f7f25415ce487b1a3bbbe4d44109c056c/.Rinstignore)

```r
# Certain LaTeX files (e.g. bib, bst, sty) must be part of the build 
# such that they are available for R CMD check.  These are excluded
# from the install using .Rinstignore in the top-level directory
# such as this one.
doc/.*[.](bib|bst|sty)$
```



## Conclusion

In this post we explained what files and directories can be present in a bundled package. 
We also explained how to prevent non-standard things from making it from the package source into the bundled package: using `.Rbuildignore`; and how to let non-standard things make it into the bundled package: `inst/` -- but don't make it your junk drawer, of course.
Let's end with a quote from [Marie Kondo's The Life-Changing Magic of Tidying Up](https://www.goodreads.com/work/quotes/41711738-jinsei-ga-tokimeku-katazuke-no-maho)

> "Keep only those things that speak to your heart."

... that we need to amend...

> "Keep only those things that speak to your R CMD check."

[^rabbit]: I might have entered a rabbit hole looking through [THANKS files](https://github.com/search?l=&q=user%3Acran+filename%3ATHANKS&type=Code) on [R-hub mirror of CRAN source code](https://docs.r-hub.io/#cran-source-code-mirror).
I sure like reading acknowledgements. :bouquet:
[^git]: I am fascinated by common exclusions, that reflect what is accepted as common practice.
[^copy]: That procedure can make R CMD build very slow when you have huge hidden directories, refer to [this excellent R-package-devel thread](https://stat.ethz.ch/pipermail/r-package-devel/2020q1/005031.html).
[^citation]: That citation will be found by the `citation()` function when an user calls it e.g. `citation("stplanr")`, and by `pkgdown` when building the website, see [`stplanr` CITATION page](https://docs.ropensci.org/stplanr/authors.html) that is linked from its [homepage](https://docs.ropensci.org/stplanr/).
[^extras]: Another file full of Perl regex that is out of scope for this post is [`.install_extras`](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#index-_002einstall_005fextras-file) that influences what makes it (rather than what doesn't make it) from the `vignettes` to `inst/doc` when building the package.
