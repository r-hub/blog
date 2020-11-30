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
rmd_hash: 05cdd8a59946de83

---

Have you ever tried submitting your R package to CRAN and gotten the NOTE `Found the following (possibly) invalid URLs:`? In this post, we shall explain where and how CRAN checks URLs validity, and we shall explain how to best prepare your package for this check.

URLs where and how?
-------------------

Adding URLs in your documentation (DESCRIPTION, manual pages, README, vignettes) is a good way to provide more information for users of the package.

### URLs in DESCRIPTION's Description

We've already made the case for storing URLs to your development repository and package documentation website in DESCRIPTION. Now, the *Description* part of the DESCRIPTION, that gives a short summary about what your package does, can contain URLs.

-   URL to the [data source your package is wrapping](https://devguide.ropensci.org/building.html#general), if relevant (not the API URL, an human facing website instead);

-   URL to a reference. CRAN policies have a [format preferrence](https://cran.r-project.org/web/packages/policies.html) for those ([source](https://github.com/ropensci/roweb3/issues/56#issuecomment-706947606) for the example below):

<!-- -->

    Please write references in the description of the DESCRIPTION file in the form
    authors (year) <doi:...>
    authors (year) <arXiv:...>
    authors (year, ISBN:...)
    or if those are not available: authors (year) <https:...>
    with no space after 'doi:', 'arXiv:', 'https:' and angle brackets for auto-linking.

The auto-linking (i.e. from `<doi:10.21105/joss.01857>` to `<a href="https://doi.org/10.21105/joss.01857">doi:10.21105/joss.01857</a>`) happens when building the package, via regular expressions.

URLs checks by CRAN
-------------------

For URLs in docs to serve this goal, they need to be "valid". Therefore, CRAN submission checks include a check of URLs.

URLs checks locally
-------------------

Conclusion
----------

In this post we have summarized why, where and how URLs are stored in the documentation of R packages; how CRAN checks them and how you can reproduce such checks to fix URLs in time.

