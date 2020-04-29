---
slug: pkg-news
title: "Why and how maintain a NEWS file for your R package?"
authors:
  - Maëlle Salmon
date: "2020-05-06"
tags:
- package development
- news
output: 
  html_document:
    keep_md: true
---





Your R package is doomed to evolve as you had new features and bug fixes.
How to inform users of changes?
NEWS files are a key instrument in documenting changes.
In this post, we shall go through why keeping track of changes, how to create and maintain a changelog, advocating for the NEWS.md format.

# Why cultivate a changelog?

You will probably change stuff in your package.
Discussing package evolutions is beyond the scope of this post, refer to e.g. [this chapter of the rOpenSci dev guide](https://devguide.ropensci.org/evolution.html).
This post is about _documenting_ changes.
Even with a very clear version control history[^gitflow], having a text version of changes can be useful:

* to you and other developers, when looking back;

* to contributors, if you acknowledge their user name;

* to users, when updating the package or wondering when something changed;

* to you and other communicators, when drafting content (blog post, tweet, email) about a release.

```r 
news(package = "knitr")
```

```
                       Changes in version 999.999                       

    o   This NEWS file is only a placeholder. The version 999.999 does
	not really exist. Please read the NEWS on Github: <URL:
	https://github.com/yihui/knitr/releases>
```

How to write such a changelog, in practice?
We shall discuss format in the next section.
As regards contents, beside referring to the changelogs you like, [the NEWs chapter of the tidyverse style guide](https://style.tidyverse.org/news.html) is a very useful read.


# Why write the changelog as NEWS.md?

There are several possible formats for maintaining an R package changelog, according to the documentation of `util::news()`: inst/NEWS.Rd formatted like other Rd files, a Markdown NEWS.md, plain-text NEWS or inst/NEWS.

The actually serious [CRAN package `ouch`](https://kingaa.github.io/ouch/) uses inst/NEWS.Rd, like [134 other packages at the time of writing](https://github.com/search?l=&o=desc&q=org%3Acran+path%3A%2Finst%2F+filename%3ANEWS.Rd&s=indexed&type=Code).
In the case of `ouch`, inst/NEWS.Rd is actually [created from a plain-text inst/NEWS using `R CMD Rdconv`](https://github.com/kingaa/ouch/blob/8a2f39b895f97b7c8e8677f4052c42bbf16055c4/Makefile#L53-L54).
As regards plain-text NEWS files, when preparing this post I found [413 inst/NEWS](https://github.com/search?q=org%3Acran+path%3A%2Finst%2F+filename%3ANEWS&type=Code) and [1,055 NEWS](https://github.com/search?l=Text&q=org%3Acran+path%3A%2F+filename%3ANEWS&type=Code) in CRAN packages.
Last but not least, at the time of writing there were [1,174 packages with a NEWS.md file](https://github.com/search?l=Markdown&q=org%3Acran+path%3A%2F+filename%3ANEWS&type=Code)

Now, why do I think NEWS.md is the best format?



* A caveat is the `util::news()` function. If the user uses that and doesn't have `commonmark` and `xml2` installed, it will fail


```r 
withr::with_temp_libpaths(
  action = "replace",
  {
  # no commonmark
  # print(find.package("commonmark", quiet = TRUE))
  # make xml2 available

  dir.create(file.path(.libPaths()[1], "xml2"))
  file.copy(
    "/home/maelle/R/x86_64-pc-linux-gnu-library/3.6/xml2",
    file.path(.libPaths()[1]),
    recursive = TRUE
    )

  xml2::xml2_example()
  news(grepl("fix", Category, ignore.case=TRUE), package = "xml2")
  })
```

```
Error in loadNamespace(name): there is no package called 'commonmark'
```



```r 
withr::with_temp_libpaths(
  action = "suffix",
  {
  # yay commonmark
  print(find.package("commonmark", quiet = TRUE))

  news(grepl("fix", Category, ignore.case=TRUE), package = "xml2")
  })
```

```
[1] "/home/maelle/R/x86_64-pc-linux-gnu-library/3.6/commonmark"
```

```
                        Changes in version 1.2.1                        

Bugfixes and Miscellaneous features

  - Generic xml2 error are now forwarded as R errors. Previously these
    errors were output to stderr, so could not be suppressed (#209).

  - Fix for ICU 59+ defaulting to use char16_t, which is only available
    in C++11 (#231)

  - No longer uses the C connections API

  - Better error message when trying to run download_xml() without the
    curl package installed (#262)

  - xml2 classes are now registered for use with S4 by calling
    setOldClass() (#248)

  - Nodes with nested data type definition entities now work without
    crashing (#241)

  - Test failure fixed due to behavior change with relative paths in
    libxml2 2.9.9 (#245).

  - read_xml() now has a better error message when given zero length
    character inputs (#212).

  - read_xml() and read_html() now automatically check if the response
    succeeded before trying to read from a HTTP response (#255).

  - xml_root() can now create root nodes with namespaces (#239)

  - xml_set_attr() no longer crashes if you try to set the same
    namespace on the same node multiple times (#253).

  - xml_set_attr() now recycles the values if needed (#221)

  - xml_structure() gains a file argument, to support writing to a file
    rather than the console (#244).

                        Changes in version 1.2.0                        

Bugfixes

  - xml_find_first() no longer de-duplicates results, so the results are
    always the same length as the inputs (as documented) (#194).

  - xml2 can now build using libxml2 2.7.0

  - Use Rcpp symbol registration and visibility to prevent symbol
    conflicts on Linux

  - xml_add_child() now requires less resources to insert a node when
    called with .where = 0L (@heckendorfc, #175).

  - Fixed failing examples due to a change in an external resource.

                        Changes in version 1.1.0                        

Bugfixes

  - xml_new_document() now explicitly sets the encoding (default UTF-8)
    (#142)

  - Document formatting options for write_xml() (#132)

  - Add missing methods for xml_missing objects. (#134)

  - Bugfix for xml_length.xml_nodeset that caused it to fail
    unconditionally. (#140)

  - is.na() now returns TRUE for xml_missing objects. (#139)

  - Trim non-breaking spaces in xml_text(trim = TRUE) (#151).

  - Allow setting non-character attributes (values are coerced to
    characters). (@sjp, #117, #122).

  - Fixed return value in call to vapply in xml_integer.xml_nodeset.
    (@ddiez, #146, #147).

  - Allow docs missing a root element to be created and printed. (@sjp,
    #126, #121).

  - xml_add_* methods now return invisibly. (@sjp, #124)

  - as_list() now preserves element names when attributes exist, and
    escapes XML attributes that conflict with special R attributes
    (@peterfoley, #115).
```

Thankfully in an interactive session when not finding any result to the query `news()` will open the entire changelog that the user could e.g. browse and search in RStudio.

Note that whilst R uses `commonmark` and `xml2` to build the news database from NEWS.md, it uses a workaround without these packages to extract URLs from NEWS.md.

# How and when to update the changelog

<!--html_preserve-->{{% tweet "1236738064850051074" %}}<!--/html_preserve-->

Now, in terms of workflow, you could

* update the changelog for each contribution;

* only update the changelog before releases;

* use [`fledge`](https://github.com/krlmlr/fledge).

In all cases you'll probably want to polish the changelog before releases, as [e.g. `usethis` would remind you](https://github.com/r-lib/usethis/blob/582a3fa886c042fe6c91376a6e4332df09a3db2a/R/release.R#L68).

# Conclusion

In this post we made the case for maintaining a changelog for your package, and for doing it in a NEWS.md file.

[^gitflow]: A good way to achieve one is adopting [git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow). You can make many stupid commits in a branch, and then squash and merge to master! It can also be wise to learn about [rewriting history](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History).
