---
slug: distribute-data
title: How to distribute data with your R packages
authors: Maëlle Salmon
date: '2020-05-29'
tags:
- package development
- standards
- data
output: hugodown::hugo_document
rmd_hash: da40b6431ee7501d

---





Sometimes you'll want a package of yours to have readily access to some data: to show what a function of yours can accomplish with a dataset, to show how your package can help tidy a messy data format, to test the package, or even to just distribute the data for teaching purposes.
Now, _how_ to provide data with/for your package is a recurring theme in [R package development channels](/2019/04/11/r-package-devel/).
In this post, we shall present various ways to distribute data with/for an R package, depending on the data use case and on its size.

_Thanks to the R connoisseurs [Thomas Vroylandt](https://tvroylandt.netlify.app/), [Sébastien Rochette](https://statnmap.com/) and [Hugo Gruson](https://www.normalesup.org/~hgruson/) for providing some inspiration and resources for this post! :pray: [^grrr]_


## Conclusion

In this post we went over different setups allowing you to distribute data with or for your R package: some standard locations in your package source (`inst/extdata/`, `data/`, `R/sysdata.rda`); locations outside of your package (using `drat`, `git-LFS`, GitHub releases via `piggyback`, a web API you'd build yourself), that your package would know how to access, and potentially save locally (in an app dir, or using a tool like `bowerbird`).
Do _you_ have a "data and R package" setup you'd like to share?
Please comment below!

[^grrr]: In a conversation in the friendly French-speaking R Slack workspace -- where we'd write _connaisseurs_, not _connoisseurs_. If you want to join us, follow [the invitation link](https://github.com/frrrenchies/frrrenchies#cat-chat-et-discussions-instantan%C3%A9es-cat). _À bientôt !_
