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

If you use the [same code three times](https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming)), write a function. If you write three such related functions, set up a package. But if you write three embarrassingly similar functions... write code to generate their code for you? In this post, we'll deal with source code generation. We'll differentiate scaffolding from generating code, and we'll present various strategies observed in the wild.

_This post was inspired by an [excellent Twitter thread started by Miles McBain](https://twitter.com/MilesMcBain/status/1199451518090395649), from which we gathered examples. Thank you Miles!_

## Introduction

### If you can repeat yourself, you're lucky

When would you need to generate code with code? A possible use case is web API with many, many endpoints that have a predictable structure (parameters, output format) that's well documented ("API specs").

In any case, to be able to generate code, you'll have some sort of underlying data/ontology. Having that data (specs of a web API, of an external tool you're wrapping, list of all your ideas, etc.), and some consistency in the different items, is quite cool, lucky you! Some of us deal with less tidy web APIs. :wink:

### Scope of this post 

In this post, we'll look into _scaffolding_ code (when your output is some sort of skeleton that's still need some human action before being integrated in a package) and _generating_ code (you hit a button and end up with more functions and docs in the package for its users to find). We won't look into packages exporting [function factories](adv-r.hadley.nz/function-factories.html).

## Scaffolding code

> "There was no way I was writing 146 functions from scratch". Bob Rudis, [GitHub comment](https://github.com/rstudio/swagger/issues/1#issuecomment-395627756).

Even without getting to the dream situation of code being cleanly generated, it can help your workflow to create function skeletons based on data.

* The [quote by Bob Rudis above](https://github.com/rstudio/swagger/issues/1#issuecomment-395627756) refers to his work on [`crumpets`](https://github.com/hrbrmstr/crumpets/) where he used the [Swagger](https://en.wikipedia.org/wiki/Swagger_(software)) spec of the Gitea API to generate drafts of many, many functions. The idea was to have following commits edit functions enough to make them work without, as he said, starting from scratch.

* When dealing with a less consistent web API, e.g. the [Hubspot API](https://developers.hubspot.com/docs/overview), a one-off webscraping of the docs can help list endpoints to be implemented and, say, open [tickets in a issue tracker](https://github.com/lockedata/hubspot/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3A%22New+endpoint+%3Around_pushpin%3A%22) with some skeletons in them. One could use [the `projmgr` package by Emily Riederer](https://emilyriederer.github.io/projmgr/index.html) in such a context to open issues/list of tasks.

## Generating code

> "odin works using code generation; the nice thing about this approach is that it never gets bored. So if the generated code has lots of tedious repetitive bits, they're at least likely to be correct (compared with implementing yourself)." Rich FitzJohn, [odin README](https://github.com/mrc-ide/odin).


## Conclusion

In this post we explored different aspects of source code scaffolding and generation in R packages. In the more general context of [automatic programming](https://en.wikipedia.org/wiki/Automatic_programming), one also finds "generative programming", and "low-code applications" (like [tidyblocks](https://tidyblocks.tech/)?). As much as one enjoys writing R code, it's great to be able to write less of it sometimes. 

Do _you_ use source code generation in R? Don't hesitate to add your own use case and setup in the comments below.
