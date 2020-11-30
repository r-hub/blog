---
slug: url-checks
title: "A NOTE on URL checks of your R package" 
authors: 
- Maëlle Salmon 
date: "2020-11-24" 
tags: 
- package development 
- testing
output: hugodown::hugo_document
rmd_hash: 2233423ce7ffb445

---

Have you ever tried submitting your R package to CRAN and gotten the NOTE `Found the following (possibly) invalid URLs:`? In this post, we shall explain where and how CRAN checks URLs validity, and we shall explain how to best prepare your package for this check.

Links where and how?
--------------------

Adding URLs in your documentation (DESCRIPTION, manual pages, README, vignettes) is a good way to provide more information for users of the package.

### Links in DESCRIPTION's Description

We've already made the case for storing URLs to your development repository and package documentation website in [DESCRIPTION](/2019/12/10/urls/). Now, the *Description* part of the DESCRIPTION, that gives a short summary about what your package does, can contain URLs.

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

For adding links to manual pages, it is best to have [roxygen2 docs about linking](https://roxygen2.r-lib.org/articles/rd-formatting.html#links-2) in mind or open in a browser tab.

There are links you add yourself, but also generated links when you want to refer to another topic or function, typeset as code or not. The documentation features useful tables summarizing how to use the syntax `[thing]` and `[text][thing]` to produce the links and look you expect.

And see also... the [`@seealso` roxygen2 tag](https://roxygen2.r-lib.org/articles/rd.html#cross-references)/`\Seealso` section! It is meant especially for storing cross-references and external links, following the syntax of links mentioned before.

The links to documentation topics are not *URLs* but they will be checked by [`roxygen2::roxygenize()`](https://roxygen2.r-lib.org/reference/roxygenize.html) ([`devtools::document()`](https://devtools.r-lib.org//reference/document.html)) and `R CMD check`. roxygen2 will warn `Link to unknown topic` and `R CMD check` will warn too `Missing link or links in documentation object 'foo.Rd'`.

### Links in pkgdown

In the pkgdown website of your package, you will notice links in inline and block code, for which you can thank [downlit](https://github.com/r-lib/downlit#features).

URLs checks by CRAN
-------------------

For URLs in docs to serve this goal, they need to be "valid". Therefore, CRAN submission checks include a check of URLs.

URLs checks locally
-------------------

Conclusion
----------

In this post we have summarized why, where and how URLs are stored in the documentation of R packages; how CRAN checks them and how you can reproduce such checks to fix URLs in time.

