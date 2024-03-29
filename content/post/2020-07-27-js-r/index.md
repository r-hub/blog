---
slug: js-r 
title: "JavaScript for the R package developer" 
authors: 
- Maëlle Salmon
- Garrick Aden-Buie
date: "2020-08-25" 
tags: 
- package development 
- JS
output: hugodown::hugo_document
rmd_hash: 10c020e3e5ba25a6
html_dependencies:
- <link href="applause-button-3.3.2/applause-button.css" rel="stylesheet" />
- <script src="applause-button-3.3.2/applause-button.js"></script>
---

JS and R, what a clickbait!
Come for JS, stay for our posts about [Solaris](/2020/05/14/checking-your-r-package-on-solaris/) and [WinBuilder](/2020/04/01/win-builder/).
:wink: No matter how strongly you believe in JavaScript being the language of the future (see below), you might still gain from using it in your R practice, be it back-end or front-end.

In this blog post, [Garrick Aden-Buie](https://www.garrickadenbuie.com) and I share a roundup of resources around JavaScript for R package developers.

## JavaScript in your R package

Why and how you include JavaScript *in* your R package?

### Bundling JavaScript code

JavaScript's being so popular these days, you might want to bundle JavaScript code with your package.
Bundling instead of porting (i.e. translating to R) JavaScript code might be a huge time gain and less error-prone (your port would be hard to keep up-to-date with the original JavaScript library).

The easiest way to interface JavaScript code from an R package is using the [V8 package](https://cran.r-project.org/web/packages/V8/index.html).
From [its docs](https://cran.r-project.org/web/packages/V8/vignettes/v8_intro.html), "*A major advantage over the other foreign language interfaces is that V8 requires no compilers, external executables or other run-time dependencies. The entire engine is contained within a 6MB package (2MB zipped) and works on all major platforms.*" V8 documentation includes a vignette on [how to use JavaScript libraries with V8](https://cran.r-project.org/web/packages/V8/vignettes/npm.html).
Some examples of use include [the js package](https://cran.r-project.org/web/packages/js/index.html), "*A set of utilities for working with JavaScript syntax in R*"; [jsonld](https://cran.r-project.org/web/packages/jsonld/index.html) for working with, well, JSON-LD where LD means Linked Data; [slugify](https://github.com/hrbrmstr/slugify) (not on CRAN) for creating slugs out of strings.

For another approach, depending on a local NodeJS and Node Package Manager (NPM) installation, see [Colin Fay's blog post "How to Write an R Package Wrapping a NodeJS Module"](https://colinfay.me/node-r-package).
An interesting read about NPM and R, even if you end up going the easier V8 route.

### JavaScript for your package documentation

Now, maybe you're not using JavaScript in your R package at all, but you might want to use it to pimp up your documentation!
Here are some examples for inspiration.
Of course, they all only work for the *HTML* documentation, in a PDF you can't be that creative.

#### Manual

The [roxygenlabs package, that is an incubator for experimental roxygen features](https://github.com/gaborcsardi/roxygenlabs#css-and-javascript-themes), includes a way to add JS themes to your documentation.
With its default JS script, your examples gain a copy-paste button!

Noam Ross once described [a way to include a searchable table in reference pages, with DT](https://discuss.ropensci.org/t/searchable-metadata-in-help-files-with-htmlwidgets/1078).

In [writexl docs](https://docs.ropensci.org/writexl/reference/write_xlsx.html), the infamous Clippy makes an appearance.
It triggers [a tweet nearly once a week](https://twitter.com/search?q=clippy%20%23rstats), which might be a way to check people are reading the docs?

For actual analytics in manual pages, it seems [the unknown package](https://github.com/cran/unknownR/blob/9d5cd70c15837b59ef9d215971fad82358f29ff4/man/unk.Rd) found a trick by adding a script from [statcounter](https://github.com/cran/unknownR/blob/9d5cd70c15837b59ef9d215971fad82358f29ff4/man/unk.Rd).

#### Vignettes

In HTML vignettes, you can also use web dependencies.
On a pkgdown website, you might encounter some incompatibilities between your, say, HTML widgets, and Boostrap (that powers pkgdown).

### Web dependency management

#### HTML Dependencies

A third, and most common, way in which you as an R package developer might interact with JavaScript is to repackage web dependencies, such as JavaScript and CSS libraries, that enhance HTML documents and Shiny apps!
For that, you'll want to learn about the [htmltools package](https://cran.r-project.org/web/packages/htmltools/index.html), in particular for its `htmlDependency()` function.

As Hadley Wickham describes in the [Managing JavaScript/CSS dependencies](https://mastering-shiny.org/advanced-ui.html#dependencies) section of [*Mastering Shiny*](https://mastering-shiny.org/), an HTML dependency object describes a single JavaScript/CSS library, which often contains one or more JavaScript and/or CSS files and additional assets.
As an R package author providing reusable web components for Shiny or R Markdown, in Hadley's words, you "absolutely should be using HTML dependency objects rather than calling `tags$link()`, `tags$script()`, `includeCSS()`, or `includeScript()` directly."

#### htmlDependency()

There are two main advantages to using [`htmltools::htmlDependency()`](https://rdrr.io/pkg/htmltools/man/htmlDependency.html).
First, HTML dependencies can be included with HTML generated with htmltools, and htmltools will ensure that the dependencies are loaded only once per page, even if multiple components appear on a page.
Second, if components from different packages depend on the same JavaScript or CSS library, htmltools can detect and resolve conflicts and load only the most recent version of the same dependency.

<div class="highlight">

<!--html_preserve-->
<style>applause-button.clapped .style-root svg, 
    applause-button.clapped .style-root::after { 
      color: #c7254e;
      fill: #c7254e;
      stroke: #c7254e;
      border-color: #c7254e;
    }</style>
<applause-button style="width: 50px; height: 50px;font-size:14px;margin:10px 20px;float:left;" color="#1f52a4"></applause-button><!--/html_preserve-->

</div>

Here's an example from the [applause](https://pkg.garrickadenbuie.com/applause) package.
This package wraps [applause-button](https://applause-button.com/), a *zero-configuration button for adding applause/claps/kudos to web pages and blog posts*.
It was also created to demonstrate how to package a web component in an R package using htmltools.
For a full walk through of the package development process, see the [dev log in the package README](https://github.com/gadenbuie/applause#dev-log).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>html_dependency_applause</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>() {
  <span class='k'>htmltools</span>::<span class='nf'><a href='https://rdrr.io/pkg/htmltools/man/htmlDependency.html'>htmlDependency</a></span>(
    name = <span class='s'>"applause-button"</span>,
    version = <span class='s'>"3.3.2"</span>,
    package = <span class='s'>"applause"</span>,
    src = <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(
      file = <span class='s'>"applause-button"</span>,
      href = <span class='s'>"https://unpkg.com/applause-button@3.3.2/dist"</span>
    ),
    script = <span class='s'>"applause-button.js"</span>,
    stylesheet = <span class='s'>"applause-button.css"</span>
  )
}</code></pre>

</div>

The HTML dependency for `applause-button` is provided in the `html_dependency_applause()` function.
htmltools tracks all of the web dependencies being loaded into a document, and conflicts are determined by the `name` of the dependency where the highest `version` of a dependency will be loaded.
For this reason, it's important for package authors to use the package name as known on [npm](https://www.npmjs.com/package/applause-button) or GitHub and to ensure that the `version` is up to date.

Inside the R package source, the applause button dependencies are stored in [inst/applause-button](https://github.com/gadenbuie/applause/tree/master/inst/applause-button).

```         
applause
└── inst
    └── applause-button
          ├── applause-button.js
          └── applause-button.css
```

The `package`, `src`, and `script` or `stylesheet` arguments work together to locate the dependency's resources: `htmlDependency()` finds the `package`'s installation directory (i.e. `inst/`), then finds the directory specified by `src`, where the `script` (`.js`) and/or `stylesheet` (`.css`) files are located.
The `src` argument can be a named vector or a single character of the directory in your package's `inst` folder.
If `src` is named, the `file` element indicates the directory in the `inst` folder, and the `href` element indicates the URL to the containing folder on a remote server, like a [CDN](https://en.wikipedia.org/wiki/Content_delivery_network).

To ship dependencies in your package, copy the dependencies into a sub-directory of `inst` in your package (but not `inst/src` or `inst/lib`, these are reserved directory names[^1]).
As long as the dependencies are a reasonable size[^2], it's best to include the dependencies in your R package so that an internet connection isn't strictly required
. Users who want to explicitly use the version hosted at a CDN can use [shiny::createWebDependency()](https://shiny.rstudio.com/reference/shiny/1.4.0/createWebDependency.html).

[^1]: Refer to the R packages book by Hadley Wickham and Jenny Bryan [for a full list of reserved directory names](https://r-pkgs.org/inst.html).

[^2]: For instance, remember that [for CRAN](https://cran.r-project.org/web/packages/policies.html), "*neither data nor documentation should exceed 5MB*".

Finally, it's important that the HTML dependency be provided by a *function* and not stored as a variable in your package namespace.
This allows htmltools to correctly locate the dependency's files once the package is installed on a user's computer.
By convention, the function providing the dependency object is typically prefixed with `html_dependency_`.

#### Using an HTML dependency

Functions that provide HTML dependencies like `html_dependency_applause()` aren't typically called by package users.
Instead, package authors provide UI functions that construct the HTML tags required for the component, and the HTML dependency is attached to this, generally by including the UI and the dependency together in an [`htmltools::tagList()`](https://rdrr.io/pkg/htmltools/man/tag.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>applause_button</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>...</span>) {
  <span class='k'>htmltools</span>::<span class='nf'><a href='https://rdrr.io/pkg/htmltools/man/tag.html'>tagList</a></span>(
    <span class='nf'>applause_button_html</span>(<span class='k'>...</span>),
    <span class='nf'>html_dependency_applause</span>()
  )
}</code></pre>

</div>

Note that package authors can and should attach HTML dependencies to any tags produced by package functions that require the web dependencies shipped by the package.
This way, users don't need to worry about having to manually attach dependencies and htmltools will ensure that the web dependency files are added only once to the output.
This way, for instance, to include a button, using the `applause` package an user only needs to type in e.g. their Hugo blog post[^3] or Shiny app:

[^3]: And some setup work to use HTML widgets, see [`hugodown` docs](https://hugodown.r-lib.org/articles/config.html#hugo-1).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>applause</span>::<span class='nf'><a href='https://rdrr.io/pkg/applause/man/button.html'>button</a></span>()
</code></pre>
<!--html_preserve-->
<applause-button style="width: 50px; height: 50px;"></applause-button><!--/html_preserve-->

</div>

Some web dependencies only need to be included in the output document and don't require any HTML tags.
In these cases, the dependency can appear alone in the [`htmltools::tagList()`](https://rdrr.io/pkg/htmltools/man/tag.html), as in [this example](https://github.com/gadenbuie/xaringanExtra/blob/master/R/webcam.R) from [xaringanExtra::use_webcam()](https://pkg.garrickadenbuie.com/xaringanExtra/#/?id=webcam).
The names of these types of functions commonly include the `use_` prefix.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>use_webcam</span> <span class='o'>&lt;-</span> <span class='nf'>function</span>(<span class='k'>width</span> = <span class='m'>200</span>, <span class='k'>height</span> = <span class='m'>200</span>, <span class='k'>margin</span> = <span class='s'>"1em"</span>) {
<span class='k'>htmltools</span>::<span class='nf'><a href='https://rdrr.io/pkg/htmltools/man/tag.html'>tagList</a></span>(
    <span class='nf'>html_dependency_webcam</span>(<span class='k'>width</span>, <span class='k'>height</span>)
  )
}</code></pre>

</div>

### JS and package robustness

How do you test JS code for your package, and how do you test your package that helps managing JS dependencies?
We'll simply offer some food for thought here.
If you bundle or help bundling an existing JS library, be careful to choose dependencies as you would with R packages.
Check the reputation and health of that library (is it tested?).
If you are packaging your own JS code, also make sure you use best practice for JS development.
:wink: Lastly, if you want to check how using your package works in a Shiny app, e.g. how does that applause button turn out, you might find interesting ideas in the [book "Engineering Production-Grade Shiny Apps" by Colin Fay, Sébastien Rochette, Vincent Guyader and Cervan Girard](https://engineering-shiny.org/step-secure.html#testing-the-interactive-logic), in particular the quote "*instead of deliberately clicking on the application interface, you let a program do it for you*".

## Learning and showing JavaScript from R

Now, what if you want to learn JavaScript?
Besides the resources that one would recommend to any JS learner, there are interesting ones just for you as R user!

### Learning materials

The resources for learning we found are mostly related to Shiny, but might be relevant anyway.

-   [Colin Fay's field notes about JS for Shiny](https://connect.thinkr.fr/js4shinyfieldnotes/)

-   [Materials from the RStudio conf 2020 workshop about JS for Shiny lead by Garrick Aden-Buie](https://github.com/rstudio-conf-2020/js-for-shiny)

-   Really only for Shiny, see the documentation about [packaging JavaScript in Shiny apps](https://shiny.rstudio.com/articles/packaging-javascript.html)

### Literate JavaScript programming

As an R user, you might really appreciate literate R programming.
You're lucky, you can actually use JavaScript in R Markdown.

At a basic level, `knitr` includes a [JavaScript chunk engine](https://rmarkdown.rstudio.com/authoring_knitr_engines.html%23sql#JavaScript) that writes the code in JavaScript chunks marked with <code>\`\`\`{js}</code> into a `<script>` tag in the HTML document.
The JS code is then rendered *in the browser* when the reader opens the output document!

Now, what about executing JS code at compile time i.e. when knitting?
For that the experimental [bubble](https://github.com/ColinFay/bubble#knitr) package provides a knitr engines that uses [Node](https://nodejs.org/en/) to run JavaScript chunks and insert the results in the rendered output.

The [js4shiny](https://pkg.js4shiny.com) package blends of the above approaches in [html_document_js()](https://pkg.js4shiny.com/articles/literate-javascript.html), an R Markdown output for [literate JavaScript programming](https://pkg.js4shiny.com/articles/literate-javascript.html).
In this case, JavaScript chunks are run in the reader's browser and console outputs and results are written into output chunks in the page, mimicking R Markdown's R chunks.

#### Different problem, using JS libraries in Rmd documents

More as a side-note let us mention [the htmlwidgets package](https://github.com/ramnathv/htmlwidgets) for adding elements such as leaflet maps to your HTML documents and Shiny apps.

### Playground

When learning a new language, using a playground is great.
Did you know that the js4shiny package provides a [JS playground you can use from RStudio](https://pkg.js4shiny.com/reference/repl.html)?
Less new things at once if you already use RStudio, so more confidence for learning!

And if you'd rather stick to the command line, bubble can [launch a Node terminal](https://github.com/ColinFay/bubble#using-bubble-to-launch-a-nodejs-terminal) where you can interactively run JavaScript, just like the R console.

## R from JavaScript?

Before we jump to the conclusion, let us mention a few ways to go the other way round, calling R from JavaScript...

[Shiny](https://shiny.rstudio.com/), "*an R package that makes it easy to build interactive web apps straight from R.*", and [the golemverse, a set of packages for developing Shiny apps as packages](https://golemverse.org/)

[OpenCPU](https://www.opencpu.org/) is "*An API for Embedded Scientific Computing*" that can allow you to use JS and R together.

If you use [the plumber R package](https://www.rplumber.io/) to make a web API out of R code, you can then [interact with that API from e.g. Node](https://solutions.rstudio.com/examples/rest-apis/clients/nodejs/).

Colin Fay wrote [an experimental Node package for calling R](https://colinfay.me/hello-hordes/).

## Conclusion

In this post we went over some resources useful to R package developers looking to use JavaScript code in the backend or docs of their packages, or to help others use JavaScript dependencies.
Do not hesitate to share more links or experience in the comments below!
