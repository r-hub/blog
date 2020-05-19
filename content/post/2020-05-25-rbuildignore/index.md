---
slug: rbuildignore
title: "Non-standard files/directories and Rbuildignore"
authors:
  - Maëlle Salmon
date: "2020-05-25"
tags:
- package development
- standards
output: 
  html_document:
    keep_md: true
---




Paragraphasing [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Creating-R-packages), an R package is _"directory of files which extend R"_.
These files have to follow [a standard structure](https://r-pkgs.org/package-structure-state.html): you can't store everything that suits your fancy in a tarball you submit to CRAN.
In this post we shall go through what can go on CRAN, what else you might want to keep, and how not to let the latter upset R CMD check.

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
* cran-comments.md for your CRAN submissions.

If they ended up in the bundled package, R CMD check would complain and tell you

> :rage: Non-standard files/directories found at top level:

Note that sometimes R CMD check could complain about files you don't see, that are created by the checking process. 
In that case, [take a step back and try to fix your code, e.g. cleaning after yourself if examples create example files.](https://www.mail-archive.com/r-package-devel@r-project.org/msg03254.html)

## Excluding files

Now, how do you keep the items that sparkle joy in your package source, without endangering R CMD check passing?

To do that we need to understand how files and directories end up, or not, in the tarball/bundled package, from the source package?
That's one job of [R CMD build](https://cran.r-project.org/doc/manuals/R-exts.html#Building-package-tarballs) possibly via a wrapper like `devtools::build()`.
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

### How to edit `.Rbuildignore`?

You could edit `.Rbuildignore` by hand, from the command line, or using `usethis::use_build_ignore()` that will escape paths by default.

[^rabbit]: I might have entered a rabbit hole looking through [THANKS files](https://github.com/search?l=&q=user%3Acran+filename%3ATHANKS&type=Code) on [R-hub mirror of CRAN source code](https://docs.r-hub.io/#cran-source-code-mirror).
I sure like reading acknowledgements. :bouquet:
[^git]: I am fascinated by common exclusions, that reflect what is accepted as common practice.
[^copy]: That procedure can make R CMD build very slow when you have huge hidden directories, refer to [this excellent R-package-devel thread](https://stat.ethz.ch/pipermail/r-package-devel/2020q1/005031.html).
