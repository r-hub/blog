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
rmd_hash: b61c1e2c53f30af1

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

To test it no matter the operating system, we need to make our tests believe they are run on a given operating system[^2]. We can, in this day and age, achieve this using mocking tools from testthat itself! Here's our test file:

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

The magic happens in `local_mocked_bindings()` calls such as `local_mocked_bindings(Sys.info = function(...) c(sysname = "Windows"))`. This call indicates what we want the argument `Sys.info`, meaning the mocked function [`Sys.info()`](https://rdrr.io/r/base/Sys.info.html), to return a fake output in the context of this unit test. The fake output we strive for is `c(sysname = "Windows")`. With this spin, our function `is_encoding_a_pain()` will return `TRUE` as if on Windows, even when the test is run on macOS or Ubuntu.

Using testthat's own mocking feels good for three reasons:

-   not needing to add another dependency (and to remember what the mocking packages are called :sweat_smile:\... even if "local_mocked_bindings" is a mouthful!),

-   knowing this mocking implementation is [considered better](https://www.tidyverse.org/blog/2023/10/testthat-3-2-0/#mocking) by testthat authors, and

-   getting a [withr vibe](https://withr.r-lib.org/) from the "local\_" aspect.

Now, there's a catch here because [`Sys.info()`](https://rdrr.io/r/base/Sys.info.html) is a base R function. We had to add this line in the `R/encoding.R` script:

``` r
Sys.info <- NULL
```

This case is documented, as other cases (namespaced calls in particular), in [`testthat::local_mocked_bindings()` manual page](https://testthat.r-lib.org/reference/local_mocked_bindings.html#use).

## Revisiting the escape hatch example

Even the example in a more recent post, on [escape hatches](/2023/01/23/code-switch-escape-hatch-test/), can be easily re-written to use mocking.

``` r
create_package("../mockexample2")
# then from mockexample
use_mit_license()
use_r("internet")
use_package("curl")
use_testthat()
use_test("internet")
# then filling in the script and test file
use_git()
use_github()
# then remember it'd be nice to show it works
use_github_action("check-standard")
# Git add, commit and push
```

Find the example repository on [GitHub](https://github.com/maelle/mockexample2).

The code in `R/internet.R` is:

``` r
is_internet_down <- function() {
  !curl::has_internet()
}

my_complicated_code <- function() {
  if (is_internet_down()) {
    message("No internet! Le sigh")
  }
  # blablablabla
}
```

How to test for the message?

In `tests/testthat/test-internet.R`, we have:

``` r
test_that("my_complicated_code() notes the absence of internet", {
  local_mocked_bindings(is_internet_down = function(...) TRUE)
  expect_message(my_complicated_code(), "No internet")
})
```

Mocking, and its nowadays improved support in testthat, does not completely throw the escape hatch pattern out of the window, but it's still good to keep mocking in mind. That post actually also mentioned mocking so it's all good. :innocent:

## Some real-life examples

A drawback of the previous examples is that they're really simple and... fake.

Through an [advanced GitHub search](https://github.com/search?q=local_mocked_bindings+user%3Acran&type=code&ref=advsearch) we can identify some examples:

-   In the tests of the pool package, mocking allows to [simulate having an old version of dplyr installed](https://github.com/rstudio/pool/blob/7ac5df4faf62323b6e28d36a3ab1576613bcdbc0/tests/testthat/test-dbplyr.R#L95-L99):

``` r
local_mocked_bindings(packageVersion = function(...) "1.0.0")
```

-   In the tests of the downlit package, mocking allows to [pretend rlang isn't installed](https://github.com/r-lib/downlit/blob/c0a8f645e21a03e258b7c1684901f84279cc706a/tests/testthat/test-metadata.R#L13):

``` r
local_mocked_bindings(is_installed = function(...) FALSE)
```

-   In the tests of the httr2 package, mocking is used to [test OAuth functionality](https://github.com/r-lib/httr2/blob/824f142f048489d698673c4d2ada149b4e4c80c7/tests/testthat/test-oauth.R#L46-L48):

``` r
local_mocked_bindings(
  oauth_client_get_token = function(...) oauth_token("789")
)
```

-   In the tests of the usethis package, mocking is applied to get a [fake GitHub URL for a project](https://github.com/r-lib/usethis/blob/9e64daf13ac1636187d59e6446d9526a414d8ba6/tests/testthat/test-github.R#L7-L9),

``` r
local_mocked_bindings(
  github_url_from_git_remotes = function() "https://github.com/OWNER/REPO"
)
```

Hopefully those are more convincing examples than the earlier demos!

## Conclusion

In this post, we corrected the [someone who was (somehow) wrong on the internet](https://xkcd.com/386/) years ago. In summary, nowadays you can use mocking tools from testthat itself, when you decide mocking is more a help than a hindrance in your testing suite. Let's see how the ecosystem looks like in the next decade. :smile_cat:

[^1]: The three chapters on testing are definitely worth a read!

[^2]: We can actually test our package on different operating system using [continuous integration](https://devguide.ropensci.org/pkg_ci.html), however it's not the topic here.

