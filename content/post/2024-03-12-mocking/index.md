---
slug: mocking-new-take
title: "Update on mocking for testing R packages" 
authors: 
- Maëlle Salmon
date: "2024-03-13" 
tags: 
- package development
- testing
- mocking
output: hugodown::hugo_document
rmd_hash: b0f65d3ce2820b8f

---

This blog featured a [post on mocking](/2019/10/29/mocking/) years ago. Since then, we've entered a new decade, the second edition of Hadley Wickham's and Jenny Bryan's R packages book was published, and mocking came back to testthat, so it's time for a new take/resources roundup!

## Mocking yay or nay

The R packages book by Hadley Wickham and Jenny Bryan contains an insightful paragraph on [test coverage](https://r-pkgs.org/testing-design.html#sec-testing-design-coverage), including those lines:

> "In many cases, that last 10% or 1% often requires some awkward gymnastics to cover. Sometimes this forces you to introduce mocking or some other new complexity. Don't sacrifice the maintainability of your test suite in the name of covering some weird edge case that hasn't yet proven to be a problem."

This is definitely good to keep in mind whilst diving into the world of mocking. Not that mocking needs to be especially complex!

## Revisiting the general mocking example

The [example of general mocking](/2019/10/29/mocking/#general-mocking) in the post from 2019 can be rewritten to take advantage of the new mocking functionality that was [announced as no longer experimental in October 2023](https://www.tidyverse.org/blog/2023/10/testthat-3-2-0/#mocking).

