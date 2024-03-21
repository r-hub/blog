---
slug: mocking-new-take
title: "Update on mocking for testing R packages" 
authors: 
- Maëlle Salmon
date: "2024-03-21" 
tags: 
- package development
- testing
- mocking
output: hugodown::hugo_document
rmd_hash: 7f0e3b027c938744

---

This blog featured a [post on mocking, the art of replacing a function with whatever fake we need for testing](/2019/10/29/mocking/), years ago. Since then, we've entered a new decade, the second edition of Hadley Wickham's and Jenny Bryan's [R packages book](https://r-pkgs.org) was published, and mocking returned to testthat, so it's time for a new take/resources roundup!

*Thanks a lot to [Hannah Frick](https://www.frick.ws/) for useful feedback on this post!*

## Mocking yay or nay

The R packages book by Hadley Wickham and Jenny Bryan contains an insightful paragraph on [test coverage](https://r-pkgs.org/testing-design.html#sec-testing-design-coverage)[^1], including those lines:

> "In many cases, that last 10% or 1% often requires some awkward gymnastics to cover. Sometimes this forces you to introduce mocking or some other new complexity. Don't sacrifice the maintainability of your test suite in the name of covering some weird edge case that hasn't yet proven to be a problem."

This is definitely good to keep in mind whilst diving into the world of mocking. Not that mocking needs to be especially complex though!

Beside, sometimes, testing is complex because your code is begging to be refactored :wink:: on this topic we can quote from the same book:

> "Code that is well designed tends to be easy to test and you can turn this to your advantage. If you are struggling to write tests, consider if the problem is actually the design of your function(s). The process of writing tests is a great way to get free, private, and personalized feedback on how well-factored your code is."

Now on to mocking...

## Revisiting the general mocking example

We can re-write [example of general mocking](/2019/10/29/mocking/#general-mocking) in the post from 2019 to take advantage of the new mocking functionality that was [announced as no longer experimental in October 2023](https://www.tidyverse.org/blog/2023/10/testthat-3-2-0/#mocking).

Now, using testthat's mocking means the best demo includes an actual package... which thankfully can be created in a few [usethis](https://usethis.r-lib.org) function calls, and writing a few code lines (well, copy-pasting them from the old post!).

``` r
create_package("../mockexample")
# then from mockexample
use_mit_license()
use_r("encoding")
use_testthat()
use_test("encoding")
# then filling in the script and test file
use_git()
use_github()
# then remember it'd be nice to show it works
use_github_action("check-standard")
# Git add, commit and push
```

Find the example repository on [GitHub](https://github.com/maelle/mockexample).

The mockexample package has a function called `is_encoding_a_pain()`:

``` r
is_encoding_a_pain <- function(){
  if (Sys.info()[["sysname"]] == "Windows"){
    return(TRUE)
  }

  FALSE
}
```

The function returns `TRUE` on Windows, `FALSE` on other operating systems.

To test it no matter the operating system, we need to make our tests believe they are run on a given operating system. We can in this day and age achieve this using mocking tools from testthat itself! Here's our test file:

``` r
test_that("is_encoding_a_pain() works on Linux", {
  local_mocked_bindings(Sys.info = function(...) c(sysname = "Linux"))
  expect_false(is_encoding_a_pain())
})

test_that("is_encoding_a_pain() works on Windows", {
  local_mocked_bindings(Sys.info = function(...) c(sysname = "Windows"))
  expect_true(is_encoding_a_pain())
})
```

The magic happens in `local_mocked_bindings()` calls such as `local_mocked_bindings(Sys.info = function(...) c(sysname = "Windows"))`, that indicates what we want the mocked function, [`Sys.info()`](https://rdrr.io/r/base/Sys.info.html), to return in this environment. Using testthat's own mocking feels good for three reasons: not needing to add another dependency (and to remember what the mocking packages are called :sweat_smile:), knowing this mocking implementation is [considered better](https://www.tidyverse.org/blog/2023/10/testthat-3-2-0/#mocking) by testthat authors, and getting a [withr vibe](https://withr.r-lib.org/) from the "local\_" aspect.

Now, there's a catch here because [`Sys.info()`](https://rdrr.io/r/base/Sys.info.html) is a base R function. We had to add this line in the `R/encoding.R` script:

``` r
Sys.info <- NULL
```

This case is documented, as other cases (namespaced calls in particular), in [`testthat::local_mocked_bindings()` manual page](https://testthat.r-lib.org/reference/local_mocked_bindings.html#use).

TODO: example from keyring?

## Revisiting the escape hatch example

Even the example in a more recent post, on [escape hatches](/2023/01/23/code-switch-escape-hatch-test/), can be easily re-written to use mocking: we'd use `local_mocked_bindings(is_internet_down = function(...) TRUE)`.

Mocking, and its nowadays improved support in testthat, does not completely throw the escape hatch pattern out of the window, but it's still good to keep mocking in mind. That post actually also mentioned mocking so it's all good. :innocent:

## Conclusion

In this post, we corrected the [someone who was wrong on the internet](https://xkcd.com/386/) years ago. In summary, nowadays you can use mocking tools from testthat itself, when you decide mocking is more a help than a hindrance in your testing suite, and when you do not need to turn to specific packages such as [httptest2](https://enpiar.com/httptest2/), [vcr](https://docs.ropensci.org/vcr/) (for HTTP calls), [dittodb](https://docs.ropensci.org/dittodb/) (for database calls). Let's see how the ecosystem looks like in the next decade. :smile_cat:

[^1]: The three chapters on testing are definitely worth a read!
