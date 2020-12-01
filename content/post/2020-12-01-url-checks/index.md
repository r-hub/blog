---
slug: url-checks
title: "A NOTE on URL checks of your R package" 
authors: 
- Maëlle Salmon 
date: "2020-12-01" 
tags: 
- package development 
- documentation
- description
output: hugodown::hugo_document
rmd_hash: 4722c8fd1405130e

---

Have you ever tried submitting your R package to CRAN and gotten the NOTE `Found the following (possibly) invalid URLs:`? R devel recently got [more URL checks](https://github.com/wch/r-source/commits/trunk/src/library/tools/R/urltools.R).[^1] In this post, we shall explain where and how CRAN checks URLs validity, and we shall explain how to best prepare your package for this check. We shall start by a small overview of links, including cross-references, in the documentation of R packages.

Links where and how?
--------------------

Adding URLs in your documentation (DESCRIPTION, manual pages, README, vignettes) is a good way to provide more information for users of the package.

### Links in DESCRIPTION's Description

We've already made the case for storing URLs to your development repository and package documentation website in [DESCRIPTION](/2019/12/10/urls/). Now, the *Description* part of the DESCRIPTION, that gives a short summary about what your package does, can contain URLs between [`<`](https://rdrr.io/r/base/Comparison.html) and [`>`](https://rdrr.io/r/base/Comparison.html).

-   URL to the [data source your package is wrapping](https://devguide.ropensci.org/building.html#general), if relevant (not the API URL, an human facing website instead);

-   URL to a reference. CRAN policies have a [format preferrence](https://cran.r-project.org/web/packages/policies.html) for those ([source](https://github.com/ropensci/roweb3/issues/56#issuecomment-706947606) for the example below):

<!-- -->

    Please write references in the description of the DESCRIPTION file in the form
    authors (year) <doi:...>
    authors (year) <arXiv:...>
    authors (year, ISBN:...)
    or if those are not available: authors (year) <https:...>
    with no space after 'doi:', 'arXiv:', 'https:' and angle brackets for auto-linking.

The auto-linking (i.e. from `<doi:10.21105/joss.01857>` to `<a href="https://doi.org/10.21105/joss.01857">doi:10.21105/joss.01857</a>`) happens when building the package, via regular expressions. So you don't type in an URL, but one will be constructed.

### Links in manual pages

For adding links to manual pages, it is best to have [roxygen2 docs about linking](https://roxygen2.r-lib.org/articles/rd-formatting.html#links-2) in mind or open in a browser tab. Also refer to the [Writing R Extensions section about cross-references](https://cran.r-project.org/doc/manuals/R-exts.html#Cross_002dreferences).[^2]

There are links you add yourself (i.e. actual URLs), but also generated links when you want to refer to another topic or function, typeset as code or not. The documentation features useful tables summarizing how to use the syntax `[thing]` and `[text][thing]` to produce the links and look you expect.

And see also... the [`@seealso` roxygen2 tag](https://roxygen2.r-lib.org/articles/rd.html#cross-references)/`\Seealso` section! It is meant especially for storing cross-references and external links, following the syntax of links mentioned before.

The links to documentation topics are not *URLs* but they will be checked by [`roxygen2::roxygenize()`](https://roxygen2.r-lib.org/reference/roxygenize.html) ([`devtools::document()`](https://devtools.r-lib.org//reference/document.html)) and `R CMD check`. roxygen2 will warn `Link to unknown topic` and `R CMD check` will warn too `Missing link or links in documentation object 'foo.Rd'`.

### Links in vignettes

When adding links in a vignette, use the format dictated by the vignette engine and format you are using. Note that in R Markdown vignettes, even plain URLs (e.g. `https://r-project.org`) will be "autolinked" by Pandoc (to `<a href="https://r-project.org">https://r-project.org</a>`) so their validity will be checked. To prevent Pandoc to autolink plain URLs, use

``` yaml
output: 
  rmarkdown::html_vignette:
    md_extensions: [ 
      "-autolink_bare_uris" 
    ]
```

as output format.

### Links in pkgdown websites

In the pkgdown website of your package, you will notice links in inline and block code, for which you can thank [downlit](https://github.com/r-lib/downlit#features). These links won't be checked by `R CMD check`.

URLs checks by CRAN
-------------------

At this point we have seen that there might be URLs in your package DESCRIPTION, manual pages and vignettes, coming from

-   Actual links (`[The R project](https://r-project.org)`, `<https://r-project.org>`),
-   Plain URLs in vignettes,
-   Special formatting for DOIs and arXiv links.

For these URLs to be of any use to users, they need to be "valid". Therefore, CRAN submission checks include a check of URLs. There is a whole official page dedicated to [CRAN URL checks](https://cran.r-project.org/web/packages/URL_checks.html), that is quite short. It states "The checks done are equivalent to using `curl -I -L`" and lists potential sources of headache (like websites behaving differently when called via curl vs via a browser).

Note that [checks of DOIs](https://github.com/wch/r-source/blob/trunk/src/library/tools/R/doitools.R) are a bit different than checks of URLs since one *expects* a redirect for a DOI, whereas for an URL, CRAN does not tolerate permanent redirections.

Even before an actual submission, you can obtain CRAN checks of the URLs in your package by using [WinBuilder](/2020/04/01/win-builder/).

URLs checks locally or on R-hub
-------------------------------

How to reproduce CRAN URL checks locally? For this you'd need to use R development version so using R-hub instead might be easier. :smile_cat:

You can use [`devtools::check()`](https://devtools.r-lib.org//reference/check.html) with a recent R version (and with [libcurl enabled](https://www.mail-archive.com/r-package-devel@r-project.org/msg00046.html)) and with the correct values for the `manual`, `incoming` and `remote` arguments.

``` r
devtools::check(
  manual = TRUE,
  remote = TRUE,
  incoming = TRUE
  )
```

Or, for something faster, you can use the [`urlchecker` package](https://github.com/r-lib/urlchecker/). It is especially handy because it can also help you *fix* URLs that are redirected, by replacing them with the thing they are re-directed to.

On R-hub package builder, the equivalent of

``` r
devtools::check(
  manual = TRUE,
  remote = TRUE,
  incoming = TRUE
  )
```

is

``` r
rhub::check(
  env_vars = c(
    "_R_CHECK_CRAN_INCOMING_REMOTE_" = "true", 
    "_R_CHECK_CRAN_INCOMING_" = "true"
    )
)
```

You'll need to choose a platform that uses R-devel, and if you hesitate, Windows is the fastest one.

``` r
rhub::check(
  env_vars = c(
    "_R_CHECK_CRAN_INCOMING_REMOTE_" = "true", 
    "_R_CHECK_CRAN_INCOMING_" = "true"
    ),
  platform = "windows-x86_64-devel"
)
```

URL fixes or escaping?
----------------------

What if you can't fix an URL, what if there's a false positive?

-   You could try and have the [provider of the resource fix the URL](https://twitter.com/krlmlr/status/1329042257404698625) (ok, not often a solution);
-   You could add a comment in cran-comments.md (but this will slow a release);
-   You could escape the URL by writing it as plain text; in vignettes you will furthermore need to switch the output format to

``` yaml
output: 
  rmarkdown::html_vignette:
    md_extensions: [ 
      "-autolink_bare_uris" 
    ]
```

if you were using [`rmarkdown::html_vignette()`](https://rdrr.io/pkg/rmarkdown/man/html_vignette.html).

Conclusion
----------

In this post we have summarized why, where and how URLs are stored in the documentation of R packages; how CRAN checks them and how you can reproduce such checks to fix URLs in time. We have also provided resources for dealing with another type of links in package docs: cross-references.

To not have your submission unexpectedly slowed down by an URL invalidity, it is crucial to have CRAN URL checks run on your package before submission, either locally with `R CMD check` or the urlchecker package, or via using WinBuilder.

[^1]: And [parallel, faster](https://github.com/wch/r-source/commit/59db3e1a9204103f779af1f967feaf994003e0c1#diff-8318a1291232951b9164297f88235c18019d1c5a58a2660ee375c570122bf9bf) URL checks.

[^2]: Furthermore, the guidance (and therefore roxygen2 implementation) sometimes change, so it's good to know this could happen to you --- hopefully this won't scare you away for adding cross-references! <a href="https://www.mail-archive.com/r-package-devel@r-project.org/msg05504.html" class="uri">https://www.mail-archive.com/r-package-devel@r-project.org/msg05504.html</a>

