---
slug: code-generation
title: "Code generation in R packages"
authors:
  - Maëlle Salmon
date: "2020-02-04"
tags:
- package development
output: 
  html_document:
    keep_md: true
---

If you use the [same code three times](https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming)), write a function. 
If you write three such related functions, set up a package. 
But if you write three embarrassingly similar functions...
write code to generate their code for you? 
In this post, we'll deal with source code generation. 
We'll differentiate scaffolding from generating code, and we'll present various strategies observed in the wild.

_This post was inspired by an [excellent Twitter thread started by Miles McBain](https://twitter.com/MilesMcBain/status/1199451518090395649), from which we gathered examples. Thank you Miles!_

_Miles furthermore mentioned [Alicia Schep's rstudio::conf talk "Auto-nmagic package development"](https://github.com/vegawidget/vlbuildr#vlbuildr) to us, that was a great watch/read!_

## Introduction

### If you can repeat yourself, you're lucky

When would you need to generate code? A possible use case is wrapping a web API with many, many endpoints that have a predictable structure (parameters, output format) that's well documented ("API specs", "API schema").

In any case, to be able to generate code, you'll have some sort of underlying data/ontology. 
Having that data (specs of a web API, of an external tool you're wrapping, structured list of all your ideas, etc.), and some consistency in the different items, is quite cool, lucky you! 
Some of us deal with less tidy web APIs. :wink:

### Scope of this post 

In this post, we'll look into _scaffolding_ code (when your output is some sort of skeleton that's still need some human action before being integrated in a package) and _generating_ code (you hit a button and end up with more functions and docs in the package for its users to find). 
We won't look into packages exporting [function factories](adv-r.hadley.nz/function-factories.html).

## Scaffolding code

> "There was no way I was writing 146 functions from scratch". Bob Rudis, [GitHub comment](https://github.com/rstudio/swagger/issues/1#issuecomment-395627756).

Even without getting to the dream situation of code being cleanly generated, it can help your workflow to create function skeletons based on data.

* The [quote by Bob Rudis above](https://github.com/rstudio/swagger/issues/1#issuecomment-395627756) refers to his work on [`crumpets`](https://github.com/hrbrmstr/crumpets/) where he used the [Swagger](https://en.wikipedia.org/wiki/Swagger_(software)) spec of the Gitea API to generate drafts of many, many functions. 
The idea was to have following commits edit functions enough to make them work without, as he said, starting from scratch.

* When dealing with a less consistent web API, e.g. the [Hubspot API](https://developers.hubspot.com/docs/overview), a one-off webscraping of the docs can help list endpoints to be implemented and, say, open [tickets in a issue tracker](https://github.com/lockedata/hubspot/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3A%22New+endpoint+%3Around_pushpin%3A%22) with some skeletons in them. 
One could use [the `projmgr` package by Emily Riederer](https://emilyriederer.github.io/projmgr/index.html) in such a context to open issues/list of tasks.

* The experimental [`scaffolder` package](https://terrytangyuan.github.io/scaffolder) by Yuan Tang _"provides a comprehensive set of tools to automate the process of scaffolding interfaces to modules, classes, functions, and documentations written in other programming languages. As initial proof of concept, scaffolding R interfaces to Python packages is supported via reticulate."_. 
The [`scaffold_py_function_wrappe`](https://terrytangyuan.github.io/scaffolder/reference/scaffold_py_function_wrapper.html) takes a Python function as input and generates a R script skeleton (R code, and docs, both of them needing further editing).

In these three cases, what's generated is a template for both R code and the corresponding `roxygen2` docs.

## Generating code

> "odin works using code generation; the nice thing about this approach is that it never gets bored. So if the generated code has lots of tedious repetitive bits, they're at least likely to be correct (compared with implementing yourself)." Rich FitzJohn, [odin README](https://mrc-ide.github.io/odin/articles/odin.html).

Quite convincing, right? But _how_ does one generate code for an R package? 
The first question is _when_ does one generate code.

### Generating code once or once in a while

* For the package whose development prompted him to start the Twitter thread mentioned earlier, Miles McBain used code generation. 
The package creates wrappers around `dplyr` functions, that can in particular automatically `ungroup()` your data. 
Now say Miles decides to wrap a further `dplyr` function. 

    * He updates the [list of wrappers](https://github.com/MilesMcBain/wisegroup/blob/master/group_aware_functions.R)
    * He can then [run a make.R script](https://github.com/MilesMcBain/wisegroup/blob/master/make.R) that will [source a build.R script](https://github.com/MilesMcBain/wisegroup/blob/master/build.R) that creates R files with actual R code and lines with `roxygen2` code, before running `devtools::document()`.
    
Code generating a function

```r

build_fn <- function(fn) {

  fn_name <- name(fn)

  glue::glue("{fn_name} <- function(...) {{\n",
             "  dplyr::ungroup(\n",
             "    {fn}(...)\n",
             "  )\n",
             "}}\n")

}
```

Code generating docs

```r
build_fn_doco <- function(fn) {

  fn_name <- name(fn)

  glue::glue(
    "##' Ungrouping wrapper for {fn_name}\n",
    "##'\n",
    "##' The {PKGNAME} package provides a wrapper for {fn_name} that always returns\n",
    "##' ungrouped data. This avoids mistakes associated with forgetting to call ungroup().\n",
    "##'\n",
    "##' For original documentation see [{fn}()].\n",
    "##'\n",
    "##' Use [{fn_name}...()] to retain groups as per `{fn}`, whilst\n",
    "##' signalling this in your code.\n",
    "##'\n",
    "##' @title {fn_name}\n",
    "##' @param ... parameters for {fn}\n",
    "##' @return an ungrouped dataframe\n",
    "##' @author Miles McBain\n",
    "##' @export\n",
    "##' @seealso {fn}, {fn_name}..."
  )

}

```

    
Voilà, there's an updated `R/` folder, and after running `devtools::document()` an updated `man/` folder and `NAMESPACE`, and it all works. 
You'll have noticed the use of the [`glue` package](https://glue.tidyverse.org/), that Alicia Schep also praised in her rstudio::conf talk, and that we've seen in many of the examples we've collected for this post.
    
* A similar setup is used by Carl Boettiger in [`eml.build` for generating functions based on an XML spec](https://github.com/cboettig/build.eml/blob/master/data-raw/create-functions.R). [Tweet](https://twitter.com/cboettig/status/1199489890527805440).

* A further example is [`redux` by Rich FitzJohn](https://github.com/richfitz/redux/blob/master/extra/generate.R) where code is generated based on [Redis docs](https://github.com/antirez/redis-doc). [Tweet](https://twitter.com/rgfitzjohn/status/1199467409301749762).

* Last example for this post, `xaringanthemer` by Garrick Aden-Buie [generates functions](https://github.com/gadenbuie/xaringanthemer/blob/master/inst/scripts/generate_theme_functions.R) based [on a `tibble`](https://github.com/gadenbuie/xaringanthemer/blob/master/R/theme_settings.R) containing "Function arguments, doc strings and theme-specific defaults " that's also used to generate [a docs page](https://pkg.garrickadenbuie.com/xaringanthemer/articles/template-variables.html). [Tweet](https://twitter.com/grrrck/status/1199483617770115073).

#### Code generator in a dedicated package

All the examples from the previous subsections had some sort of build scripts living in their package repo. 
There's no convention on what to call them and where to store them. 
Now, R developers like their code packaged in package form, and Alicia Schep actually stores a package in the `build/` folder of `vlbuildr`, [`vlmetabuildr`](https://github.com/vegawidget/vlbuildr/tree/master/build/vlmetabuildr), that creates `vlbuildr` anew from the Vegalite schema! 
That's meta indeed! 
Fret not, the `build/` folder also holds a [script called `build.R`](https://github.com/vegawidget/vlbuildr/blob/master/build/build.R) that unleashes the auto-magic. 
_Let us mention [Alicia's rstudio::conf talk again](https://github.com/vegawidget/vlbuildr#vlbuildr)._

#### When to update the package?

We haven't seen any code generating workflow relying on a Makefile or on a hook to an external source, so we assume such packages are updated once in a while when their maintainer amends, or notices an amendment of, the underlying ontology. 
See e.g. [the PR updating `vlbuildr` to support Vegalite 4.0](https://github.com/vegawidget/vlbuildr/pull/43), or [the commit regenerating redis commands for 3.2 in `redux`](https://github.com/richfitz/redux/commit/575e9ccd68b529cacb5bc376ed7cb402392205f2).

### Generating code at build time

In the previous cases of code generation, the R package source was similar to many R package sources out there. 
Now, we've also seen cases where the code is generated when building the package. 
It means that the code generation has to be perfect, since there isn't be any human edit between the code generation and the code use. 
Let's dive into a few examples.

#### Generating icon aliases in `icon`

In `icon`, an R package by Mitchell O'Hara-Wild that allows easy insertion of icons from Font Awesome, Academicons and Ionicons into R Markdown, to insert an archive icon one can type `icon::fa("archive")` or `icon::fa_archive()`, i.e. every possible icon has its own alias function which pairs well with autocompletion e.g. in RStudio when starting to type `icon::fa_`. 
When typing `?icon::fa_archive` one gets a man page entitled "Font awesome alias", the same for all aliases. 
How does it work?

Font files related to the fonts are stored in [`inst/`](https://github.com/ropenscilabs/icon/tree/master/inst/fonts). 
It's the case for all three fonts, but let's focus on what happens for Font Awesome. 
Among the R code (that's executed when building the package), there's [a line reading the icon names from a font file](https://github.com/ropenscilabs/icon/blob/a5bc1cc928b15a5296b06f66faa9e08264ad4064/R/fa.R#L9). 
Further below [are a few very interesting lines](https://github.com/ropenscilabs/icon/blob/master/R/fa.R#L28-L37)

```r
#' @evalRd paste("\\keyword{internal}", paste0('\\alias{fa_', gsub('-', '_', fa_iconList), '}'), collapse = '\n')
#' @name fa-alias
#' @rdname fa-alias
#' @exportPattern ^fa_
fa_constructor <- function(...) fa(name = name, ...)
for (icon in fa_iconList) {
  formals(fa_constructor)$name <- icon
  assign(paste0("fa_", gsub("-", "_", icon)), fa_constructor)
}
rm(fa_constructor)
```

When _documenting_ the package, the man page "fa-alias" is created. 
The `@evalRd` tags ensures aliases for all icons from `fa_iconList` get an `alias{}` line in the ["fa-alias" man page](https://github.com/ropenscilabs/icon/blob/master/man/fa-alias.Rd). 
The `@exportPattern` tag ensures a line [exporting all functions whose starts with `fa_` is added to NAMESPACE](https://github.com/ropenscilabs/icon/blob/a5bc1cc928b15a5296b06f66faa9e08264ad4064/NAMESPACE#L16).
This part happens before building the package, every time the documentation is updated by the package maintainer. 
When are the `fa_` functions created? 
Well, at build time by the for loop. 
The function factory `fa_constructor` is then removed.

The code generation allows an easy update to new Font Awesome versions. 
Its working this way i.e. with functions defined at build time and a single man page for all aliases, allows for a very compact source code. 
Each alias function doesn't need more documentation than the shared man page.

#### Generating an up-to-date API wrapper in `civis`

Another interesting example is provided by [the `civis` package](twitter.com/patr1ck_mil/status/1199456574105882625), an R client for [the Civis platform](https://www.civisanalytics.com/civis-platform/). 
Its [installation instructions](https://github.com/civisanalytics/civis-r#updating) state that when installing the package from source, all functions corresponding to the latest API version will be created. 
_What_ happens exactly when the package is installed from source? 
A configure script is run ([configure](https://github.com/civisanalytics/civis-r/blob/master/configure) or [configure.win](https://github.com/civisanalytics/civis-r/blob/master/configure.win)). 
Such scripts are automatically run when building a package from source. Here's what this script does

```r
"${R_HOME}"/bin/Rscript tools/run_generate_client.R
```

And the script called sources R code from the package that fetches the API spec and writes code and `roxygen2` docs in `R/generated_client.R`. 
When the package is _not_ installed from source, the users get the `R/generated_client.R` that's last been generated by the package maintainer, so if the Civis platform itself was updated in the meantime, the users might find a platform endpoint is missing from the `civis` package.
The approach used by `civis` has the clear advantage of allowing a perfect synchronization between the wrapped platform and the package.

#### Creating functions lists and R6 methods in `minicss`

In [`mimicss`](https://github.com/coolbutuseless/minicss/) by mikefc, ["Lists of CSS property information is turned into function lists and R6 methods."](https://twitter.com/coolbutuseless/status/1199458806092034049). 
See [aaa.R](https://github.com/coolbutuseless/minicss/blob/fe378f6e040405e51fb07cb74fd2f0bac8a85b26/R/aaa.R) and [prop_transform.R](https://github.com/coolbutuseless/minicss/blob/fe378f6e040405e51fb07cb74fd2f0bac8a85b26/R/prop_transform.R). 
As in most examples the code is generated as a string, but in that case it's not written to disk, it becomes code via the use of [`eval()` and `parse()`](http://adv-r.had.co.nz/Expressions.html#parsing-and-deparsing).

### Generating code on-the-fly

One step further, one might generate code on-the-fly, i.e. as users run the package.

* The [`chromote`](https://github.com/rstudio/chromote) package ["generates auto-completable R6 methods at runtime"](https://twitter.com/alandipert/status/1199456564442062848).

* In [`stevedore`](https://richfitz.github.io/stevedore/) by Rich FitzJohn, Docker client for R, functions are generated when one connects to the Docker server via `stevedore::docker_client()`, selecting the most appropriate version based on the server (possible specs are stored in [inst/spec](https://github.com/richfitz/stevedore/tree/master/inst/spec) as compressed YAML files). 
In the author's own words, in this package the approach is "not going through the text representation at all and using things like `as.function` and `call`/`as.call` to build up functions and expressions directly". 
This happens in [swagger_args.R](https://github.com/richfitz/stevedore/blob/c98b0fd24771d6a2e96340fe032896323855de11/R/swagger_args.R). 
_Thanks to Rich for many useful comments on this post._

## Conclusion

In this post we explored different aspects of source code scaffolding and generation in R packages. 
We've mentioned examples of code scaffolding (`gitea`, `hubspot`, `scaffolder`), of code generation by a script (`wisegroup`, `eml.build`, `redux`, `xaringanthemer`) or by a meta package (`vlbuildr` and `vlmetabuildr`) before package shipping, of code generation at build time (`icon`, `civis`, `minicss`) and of code generation at run time (`chromote`, `stevedore`). 
Many of these examples used some form of string manipulation, in base R or with `glue`, to either generate an R script and its `roxygen2` docs **or** code using `eval()` and `parse()` (`minicss`). 
One of them doesn't use any text representation and `as.function` and `call`/`as.call` instead (`stevedore`).

In the more general context of [automatic programming](https://en.wikipedia.org/wiki/Automatic_programming), one also finds "generative programming", and "low-code applications" (like [tidyblocks](https://tidyblocks.tech/)?). 
As much as one enjoys writing R code, it's great to be able to write less of it sometimes, especially when it gets too routine. 

Do _you_ use source code generation in R? 
Don't hesitate to add your own use case and setup in the comments below.
