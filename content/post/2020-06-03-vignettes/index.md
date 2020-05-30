---
slug: vignettes
title: Optimal workflows for package vignettes
authors: Maëlle Salmon
date: '2020-06-03'
tags:
- package development
- documentation
output: hugodown::hugo_document
rmd_hash: c90f1b7b4a28d6c1

---




Yet another post with a focus on [package documentation](/tags/documentation/)!
This time, we'll cover vignettes a.k.a "long-form package documentation".
What are they? Where do they live?
How do you create one without upsetting R CMD check?
How do you ensure user-friendliness?

## What is a vignette? Where does it live?

In this section we shall go over basics of package vignettes.

### Vignette 101

In the "R packages" book by Hadley Wickham and Jenny Bryan, the [vignettes chapter](https://r-pkgs.org/vignettes.html) starts with _"A vignette is a long-form guide to your package. Function documentation is great if you know the name of the function you need, but it’s useless otherwise."_[^disagree]
In ["Writing R Extensions"](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-package-vignettes), vignettes are defined as _"documents in PDF or HTML format obtained from plain-text literate source files from which R knows how to extract R code and create output (in PDF/HTML or intermediate LaTeX)."_.

In practice, if your package contains one or several vignette(s), an user could 

* find them using the `vignette()` or `browseVignettes()` function, for instance they could type `vignette(package = "rhub")` or `browseVignettes(package = "rhub")` to access the list of installed vignettes for the `rhub` package[^printr]

```r 
vignette(package = "rhub")
```


|Item            |Title                                         |
|:---------------|:---------------------------------------------|
|rhub            |get-started (source, html)                    |
|local-debugging |Local Linux checks with Docker (source, html) |

```r 
browseVignettes("rhub")
```


|Vignette             |Title                          |
|:--------------------|:------------------------------|
|rhub.html            |get-started                    |
|local-debugging.html |Local Linux checks with Docker |

* see them from the [CRAN page of the package](https://cran.r-project.org/web/packages/rhub/index.html), and its [`pkgdown` website](https://r-hub.github.io/rhub/) if there's one.

As a package author you could be fine only knowing about [`usethis::use_vignette()`](https://usethis.r-lib.org/reference/use_vignette.html) for creating a vignette, and that packages used in the vignette need to be listed in `DESCRIPTION` (under `Suggests` if they're only used in the vignette).
Still, it's useful to know about vignettes for debugging problems or finding
workarounds for issues you might encounter.

### Infrastructure for vignettes

Package vignettes can either use the default Sweave vignette engine, or [a vignette engine provided by a CRAN package like `knitr`](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Non_002dSweave-vignettes).
[`knitr::rmarkdown` vignette engine](https://community.rstudio.com/t/question-about-usethis-vignette-template/32048) is the one recommended in the R packages book, and `usethis`.
It allows writing vignettes in R Markdown.

[See the source of `rhub` main vignette](https://github.com/r-hub/rhub/blob/master/vignettes/rhub.Rmd). 
It has YAML metadata at the top, some non-executed code chunks, some executed code chunks.
To allow for that vignette to be built, a [field in `DESCRIPTION`](https://github.com/r-hub/rhub/blob/6ae6f35e958f3beab1e2c8e6f704affa23c8ce29/DESCRIPTION#L47) mentions the vignette engine:

```yaml
VignetteBuilder: knitr
```

The boilerplate Rmd under a new `vignettes` folder, and that `DESCRIPTION` field, are what `usethis::use_vignette()` would create for you.
Then you can write as you would a standard R Markdown document, knitting for previewing it.

Other vignette builders include [`R.rsp`](https://cran.r-project.org/web/packages/R.rsp/index.html) that we'll mention again later, [`noweb`](https://cran.r-project.org/web/packages/noweb/index.html) to use the [noweb literate programming tool](https://en.wikipedia.org/wiki/Noweb) (which actually looks a lot like sweave?), [`rasciidocs`](https://cran.r-project.org/web/packages/rasciidoc/index.html) that was recently archived at the time of writing.
It is unlikely you'll want to write your own vignette engine. 

How many packages use a non-Sweave vignette?
One way to assess that is to look for packages that have a `VignetteBuilder` field in `DESCRIPTION` with R-hub's own [`pkgsearch`](http://r-hub.github.io/pkgsearch/).

```r 
results <- pkgsearch::advanced_search("_exists_" = "VignetteBuilder")
attr(results, "metadata")$total
[1] 4951
```

```r 
# for comparison
nrow(available.packages())
[1] 15679
```

Quite a lot!
Other packages might have _Sweave_ vignettes, and some CRAN packages don't have vignettes, whereas having a vignette is compulsory for Bioconductor packages.

### Overview of vignettes states

Following the [neat diagram of the R packages book](https://r-pkgs.org/package-structure-state.html),

* You write your vignette(s) in the `vignettes/` folder. [`rhub` source](https://github.com/r-hub/rhub).

* During building vignettes are [built](https://github.com/wch/r-source/blob/1d4f7aa1dac427ea2213d1f7cd7b5c16e896af22/src/library/tools/R/build.R#L320) and then vignettes sources, outputs, and anything written in [`install_extras`](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#index-_002einstall_005fextras-file) (a friend of [`.Rbuildignore` and `.Rinstignore`](/2020/05/20/rbuildignore/) except it shows what to _keep_ not _discard_!) gets moved to `inst/doc/`. [`rhub` contents on CRAN](https://github.com/cran/rhub). 

:bulb: Note that R CMD build therefore builds vignettes from `vignettes/`
 whereas R CMD check checks they can be rebuilt from `inst/doc/`. So if there were data in `vignettes/`, given it's not copied to `inst/doc/`... R CMD check will error!
 
:bulb: If your vignette shows an external image not generated by the build process, you also need to include it in `install_extras`, 
* During installation the content of `inst/doc/` get copied to `doc/`. `rhub` content in my local library:

```r 
fs::dir_tree(find.package("rhub"))
/home/maelle/R/x86_64-pc-linux-gnu-library/3.6/rhub
├── DESCRIPTION
├── INDEX
├── LICENSE
├── Meta
│   ├── Rd.rds
│   ├── features.rds
│   ├── hsearch.rds
│   ├── links.rds
│   ├── nsInfo.rds
│   ├── package.rds
│   └── vignette.rds
├── NAMESPACE
├── NEWS.md
├── R
│   ├── rhub
│   ├── rhub.rdb
│   └── rhub.rdx
├── bin
│   ├── rhub-linux-docker.sh
│   └── rhub-linux.sh
├── doc
│   ├── index.html
│   ├── local-debugging.R
│   ├── local-debugging.Rmd
│   ├── local-debugging.html
│   ├── rhub.R
│   ├── rhub.Rmd
│   └── rhub.html
├── help
│   ├── AnIndex
│   ├── aliases.rds
│   ├── figures
│   │   └── logo.png
│   ├── paths.rds
│   ├── rhub.rdb
│   └── rhub.rdx
└── html
    ├── 00Index.html
    └── R.css
```

### Your vignette for R CMD check

 R CMD check
options around vignettes, reminders of how to pass them to R-hub package
builder. 

## Workflows around vignettes

### How to include my pre-print / cheatsheet as a vignette?

why, indexing.

### How to include a compute-intensive / authentication-dependent vignette?

my post on RStudio community

### Re-use content from the README and manual pages

Rmd fragments

## User-friendly vignettes

How to make vignettes pretty, and information easy to find?

### Pretty vignettes

You might want to tweak layout and aspect of your vignette a bit, maybe with [custom CSS](https://bookdown.org/yihui/rmarkdown/r-package-vignette.html)[^bc].
Using a [disappointingly unspecific GitHub code search on R-hub mirror of CRAN](https://github.com/search?l=&o=desc&q=css+user%3Acran++extension%3ARmd+path%3Ainst%2Fdoc&s=indexed&type=Code) we found the example of [`idiogramFISH`](https://gitlab.com/ferroao/idiogramFISH/-/tree/master) that [defines](https://gitlab.com/ferroao/idiogramFISH/-/tree/master/vignettes/css) and [uses](https://gitlab.com/ferroao/idiogramFISH/-/blob/master/vignettes/AplotIdiogramsVig.Rmd#L33) custom stylesheets for its vignette, that makes the vignette look very modern [on its CRAN page](https://cran.r-project.org/web/packages/idiogramFISH/vignettes/AplotIdiogramsVig.html)!
Note that it also uses some JavaScript for the table of content and "return to top" links.

We haven't tried this ourselves with the latest RStudio IDE version but [apparently there can be conflicts between your vignette background and RStudio IDE theme](https://community.rstudio.com/t/html-vignettes-with-dark-themed-ide/3532).
Any experience report?

Now, an even better way to tweak your vignettes is to invest some time in creating a `pkgdown` website.
Should your local vignettes contain a link to the `pkgdown` version to be sure that users that look at an offline vignette but have an internet connection can get a better user experience?
And regarding the offline experience, would it make sense to also generate a PDF version of vignettes, maybe with paged.js[^pagejs]

### Cross-references

Link from vignettes to docs, from docs to vignettes.
Link pkgdown websites from vignettes?


 vignettes and pkgdown When
mentioning pkgdown, special role of the vignette pkgname.Rmd + mention tweaking
the navbar. Articles index. Recommended workflows for standard stuff. Rmd
fragments Workflows for working around issues (prebuilding Jeroen's note, PDF
stuff; purl&eval; articles not vignettes) Further stuff: PDF with paged.js?
Vignettes or book? See drake

## Conclusion

In this post we offered a quite detailed, but probably not exhaustive, guide around R package vignettes.
We didn't really discuss _content_ of vignettes or how to best assess their usefulness.


[^printr]: For rendering the vignettes list in this post we used the [`printr`](https://yihui.org/printr/#vignette-dataset-lists) package.
[^bc]: Bioconductor has its [own vignette style](https://www.bioconductor.org/packages/release/bioc/html/BiocStyle.html).
[^pagejs]: Compared with [`pagedown`](https://pagedown.rbind.io/) the vague idea mentioned here would mean adding a custom print stylesheet to the vignette and using the [paged.js CLI](https://gitlab.pagedmedia.org/tools/pagedjs-cli) for generating a PDF, that'd be present in `inst/doc`, and linked to from the html vignette.
[^disagree]: Note that on a `pkgdown` website, a [well-organized reference](https://pkgdown.r-lib.org/articles/pkgdown.html#reference-1) page can help make function documentation more useful.
