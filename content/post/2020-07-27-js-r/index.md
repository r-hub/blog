---
slug: js-r 
title: "JavaScript for the R package developer" 
authors: 
- Maëlle Salmon 
date: "2020-07-27" 
tags: 
- package development 
- JS
output: hugodown::hugo_document
rmd_hash: d57ce0d5d94bd819

---

JS and R, what a clickbait! Come for JS, stay for our posts about [Solaris](/2020/05/14/checking-your-r-package-on-solaris/) and [WinBuilder](/2020/04/01/win-builder/). :wink: No matter how strongly you believe in JavaScript being the language of the future (see below), you might still gain from using it in your R practice, be it back-end or front-end.

{{< tweet 1272595824112029696 >}}

In this blog post, we shall share a roundup of resources around JavaScript for R package developers.

> Let us start by thanking [Garrick Aden-Buie](https://www.garrickadenbuie.com/) who not only develops great materials and tools with R and JavaScript but also took the time to chime in draft notes for this post. :pray:

JavaScript in your R package
----------------------------

Why and how you include JavaScript *in* your R package?

### Bundling JavaScript code

JavaScript's being so popular these days, you might want to bundle JavaScript code with your package. Bundling instead of porting (i.e. translating to R) JavaScript code might be a huge time gain and less error-prone (your port would be hard to keep up-to-date with the original JavaScript library).

The easiest way to interface JavaScript code from an R package is using the [V8 package](https://cran.r-project.org/web/packages/V8/index.html). From [its docs](https://cran.r-project.org/web/packages/V8/vignettes/v8_intro.html), *"A major advantage over the other foreign language interfaces is that V8 requires no compilers, external executables or other run-time dependencies. The entire engine is contained within a 6MB package (2MB zipped) and works on all major platforms."* V8 documentation includes a vignette on [how to use JavaScript libraries with V8](https://cran.r-project.org/web/packages/V8/vignettes/npm.html). Some examples of use include [the js package](https://cran.r-project.org/web/packages/js/index.html), *"A set of utilities for working with JavaScript syntax in R"*; [jsonld](https://cran.r-project.org/web/packages/jsonld/index.html) for working with, well, JSON-LD where LD means Linked Data; [slugify](https://github.com/hrbrmstr/slugify) (not on CRAN) for creating slugs out of strings.

For another approach, depending on a local NodeJS and Node Package Manager (NPM) installation, see [Colin Fay's blog post "How to Write an R Package Wrapping a NodeJS Module"](https://colinfay.me/node-r-package). An interesting read about NPM and R, even if you end up going the easier V8 route.

### JavaScript for your documentation

Now, maybe you're not using JavaScript in your R package at all, but you might want to use it to pimp up your documentation! Here are some examples for inspiration. Of course, they all only work for the *HTML* documentation, in a PDF you can't be that creative.

#### Manual

The [roxygenlabs package, that is an incubator for experimental roxygen features](https://github.com/gaborcsardi/roxygenlabs#css-and-javascript-themes), includes a way to add JS themes to your documentation. With its default JS script, your examples gain a copy-paste button!

Noam Ross once described [a way to include a searchable table in reference pages, with DT](https://discuss.ropensci.org/t/searchable-metadata-in-help-files-with-htmlwidgets/1078).

{{< tweet 1240272226768822272 >}}

In [writexl docs](https://docs.ropensci.org/writexl/reference/write_xlsx.html), the infamous Clippy makes an appeance. It triggers a tweet nearly once a week, which might be a way to check people are reading the docs?

For actual analytics in manual pages, it seems [the unknown package](https://github.com/cran/unknownR/blob/9d5cd70c15837b59ef9d215971fad82358f29ff4/man/unk.Rd) found a trick by adding a script from [statcounter](https://github.com/cran/unknownR/blob/9d5cd70c15837b59ef9d215971fad82358f29ff4/man/unk.Rd).

#### Vignettes

In HTML vignettes, you can also use web dependencies. On a pkgdown website, you might encounter some incompatibilities between your, say, HTML widgets, and Boostrap (that powers pkgdown).

### Web dependency management

A third way in which you as an R package developer might interact with JavaScript is via helping others use and manage web dependencies i.e. in particular JavaScript libraries that enhance HTML documents and Shiny apps! For that, you'll want to learn about the [htmltools package](https://cran.r-project.org/web/packages/htmltools/index.html).

As an example, and using Garrick Aden-Buie's words,

*I'd offer [xaringanExtra](https://github.com/gadenbuie/xaringanExtra) as a better example of a few approaches to web dependency management in R packages:*

-   *[use\_tile\_view()](https://github.com/gadenbuie/xaringanExtra/blob/master/R/tile-view.R) packages custom JavaScript and CSS*
-   *[use\_tachyons()](https://github.com/gadenbuie/xaringanExtra/blob/master/R/tachyons.R) repackages an external dependency*
-   *[use\_editable()](https://github.com/gadenbuie/xaringanExtra/blob/master/R/editable.R) combines custom JavaScript with external dependencies and passes configuration options from R to the code in the rendered document.*
-   *Finally [use\_logo()](https://github.com/gadenbuie/xaringanExtra/blob/master/R/use_logo.R) dynamically writes both the CSS and JS dependency from R and bundles into an `htmlDependency()`.*

Note that an alternative approach to add a JS dependency might be [to use a CDN](https://github.com/feddelegrand7/bubblyr/blob/0d9b49a79e5a4a9825262c08336f3073a6832ad5/R/bubbly.R#L68) which means less maintenance but also more risk.

Learning and showing JavaScript from R
--------------------------------------

Now, what if you want to learn JavaScript? Besides the resources that one would recommend to any JS learner, there are interesting ones just for you as R user!

### Learning materials

The resources for learning we found are mostly related to Shiny, but might be relevant anyway.

-   [Colin Fay's field notes about JS for Shiny](https://connect.thinkr.fr/js4shinyfieldnotes/)

-   [Materials from the RStudio conf 2020 workshop about JS for Shiny lead by Garrick Aden-Buie](https://github.com/rstudio-conf-2020/js-for-shiny)

-   Really only for Shiny, see the documentation about [packaging JavaScript in Shiny apps](https://shiny.rstudio.com/articles/packaging-javascript.html)

### Literate JavaScript programming

As an R user, you might really appreciate literate R programming. You're lucky, you can actually use JavaScript in R Markdown.

A first, maybe less exciting JavaScript / R Markdown integration consists in transforming your JS chunks into scripts embedded in a HTML output so that the *browser* executes the JavaScript code. See [knitr default JS engine](https://rmarkdown.rstudio.com/authoring_knitr_engines.html%23sql#JavaScript), and for more functionality, [js4shiny](https://pkg.js4shiny.com/reference/html_document_js.html).

Now, what about executing JS code at compile time i.e. when knitting? For that there are two experimental packages providing knitr engines both using Node, [bubble](https://github.com/ColinFay/bubble#knitr) and again [js4shiny](https://pkg.js4shiny.com/reference/html_document_js.html).

#### Different problem, using JS libraries in Rmd documents

More as a side-note let us mention [the htmlwidgets package](https://github.com/ramnathv/htmlwidgets) for adding elements such as leaflet maps to your HTML documents and Shiny apps.

### Playground

When learning a new language, using a playground is great. Did you know that the js4shiny package provides a [JS playground you can use from RStudio](https://pkg.js4shiny.com/reference/repl.html)? Less new things at once if you already use RStudio, so more confidence for learning!

R from JavaScript?
------------------

Before we jump to the conclusion, let us mention a few ways to go the other way round, calling R from JavaScript...

[Shiny](https://shiny.rstudio.com/), *"an R package that makes it easy to build interactive web apps straight from R."*, and [the golemverse, a set of packages for developing Shiny apps as packages](https://golemverse.org/)

[OpenCPU](https://www.opencpu.org/) is *"An API for Embedded Scientific Computing"* that can allow you to use JS and R together.

If you use [the plumber R package](https://www.rplumber.io/) to make a web API out of R code, you can then [interact with that API from e.g. Node](https://solutions.rstudio.com/examples/rest-apis/clients/nodejs/).

Colin Fay wrote [an experimental Node package for calling R](https://colinfay.me/hello-hordes/).

Conclusion
----------

In this post we went over some resources useful to R package developers looking to use JavaScript code in the backend or docs of their packages, or to help others use JavaScript dependencies. Do not hesitate to share more links or experience in the comments below!

