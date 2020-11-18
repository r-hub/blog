---
slug: testthat-utility-belt
title: "Helper code and files for your testthat tests" 
authors: 
- Maëlle Salmon 
date: "2020-11-18" 
tags: 
- package development 
- testing
output: hugodown::hugo_document
rmd_hash: 583417d9b4628a12

---

If your package uses testthat for unit testing, as [many packages on CRAN](https://www.tidyverse.org/blog/2019/11/testthat-2-3-0/), you might have wondered at least once about where to put "things" you wished to use in several tests: a function generating a random string, an example image, etc. In this blog post, we shall offer a round-up of how to use such code and files when testing your package.

Code called in your tests
-------------------------

Remember our post about [internal functions in R packages](/2019/12/12/internal-functions/)? What about internal functions in *unit tests* of R packages? And code that needs to be run for tests?

Where to put your code and function depends on where you'll want to use them.

-   It's best not to touch `tests/testthat.R`.
-   R scripts under `tests/testthat/` whose name starts with `setup` are loaded before tests are run but not with [`devtools::load_all()`](https://devtools.r-lib.org//reference/load_all.html). This can be important: it means the code in test setup files is *not* available when you try debugging a test error (or developping a new test) by running [`devtools::load_all()`](https://devtools.r-lib.org//reference/load_all.html) then the code of your test.[^1] And yes, you'll be interactively debugging tests more often than you wish. :wink:

<!-- -->

-   R scripts under `tests/testthat/` whose name start with `helper` are loaded with [`devtools::load_all()`](https://devtools.r-lib.org//reference/load_all.html)[^2] so they are available for both tests and interactive debugging. Just like... R scripts under `R/` so you might put your testthat helpers in the R directory instead, as recommended in testthat docs. So instead of living in `tests/testthat/helper.R` they'd live in e.g. `R/testthat-helpers.R` (the name is not important in the R directory). However, it also means they are installed with the package which might (slightly!) increase its size, and that they are with the rest of your package code which might [put you off](https://community.rstudio.com/t/why-are-tests-testthat-helper-files-discouraged-in-testthat/85253).

To summarize,

| File                           | Run before tests | Loaded via `load_all()` | Installed with the package[^3] | Testable[^4] |
|--------------------------------|------------------|-------------------------|--------------------------------|--------------|
| tests/testthat/setup\*.R       | ✔️               | \-                      | \-                             | \-           |
| tests/testthat/helper\*.R      | ✔️               | ✔️                      | \-                             | \-           |
| R/any-name.R                   | ✔️               | ✔️                      | ✔️                             | ✔️           |
| tests/testthat/anything-else.R | \-               | \-                      | \-                             | \-           |

`tests/testthat/helper*.R` are [no longer recommended in testthat](https://testthat.r-lib.org/reference/test_dir.html#special-files) but they are still supported. :relieved:

In practice,

-   In `tests/testthat/setup.R` you might do something like loading a package that helps your unit testing like `{vcr}`, `{httptest}` or `{presser}` if you're [testing an API client](https://books.ropensci.org/http-testing/).
-   In a helper like `tests/testthat/helper.R` or `R/test-helpers.R` you might define variables and functions that you'll use throughout your tests, even [custom skippers](https://testthat.r-lib.org/articles/skipping.html#helpers). To choose between the two locations, refer to the table above and your own needs and preferences. Note that if someone wanted to study testthat "utility belts" à la [Bob Rudis](https://rud.is/b/2018/04/08/dissecting-r-package-utility-belts/), they would probably only identify helper files like `tests/testthat/helper.R`.

You'll notice testthat no longer recommends having a file with code to be run after tests... So how do you clean up after tests? Well, use [withr](https://withr.r-lib.org/index.html)'s various helper functions for deferring clean-up. So basically it means the code for cleaning lives near the code for making a mess. To learn more about this, read [the "self-cleaning text fixtures" vignette in testthat](https://testthat.r-lib.org/articles/test-fixtures.html) that includes examples.

Files called from your tests
----------------------------

Say your package deals with files in some way or the other. To test it you can use two strategies, depending on your needs.

### Create fake folders and text files from your tests

If the functionality under scrutiny depends on files that are fairly simple to generate with code, the best strategy might be to create them before running tests, and to delete them after running them. So you'll need to (re-)read [the "self-cleaning text fixtures" vignette in testthat](https://testthat.r-lib.org/articles/test-fixtures.html). In the [words of Jenny Bryan](https://github.com/hadley/r-pkgs/issues/483#issuecomment-691319934)

> I have basically come to the opinion that any file system work done in tests should happen below the temp directory anyway. So, if you need to stand up a directory, then do stuff to or in it, the affected test(s) should create such a directory explicitly, below tempdir, for themselves (and delete it when they're done).

It might seem easier to have the fake folders live under the `testthat/` directory but this might bite you later, so better make the effort to create self-cleaning text fixtures, especially as, as mentioned earlier, this is a skill you'll need often.

### Use other files in your tests

Now, there are files that might be harder to re-create from your tests, like images, or even some text files with a ton of information in them. If you look at [usethis `testthat/` folder](https://github.com/r-lib/usethis/tree/master/tests/testthat/) you'll notice a `ref` folder for instance, with zip files used in tests. You are free to organize files under `testthat/` as you wish, they do not even need to be in a subdirectory, but sorting them in different folders might help you.

All files under `testthat/` and its subfolders are available to your tests so you can read from them, source them if they are R scripts, copy them to a temp dir, etc.

Now, to refer to these files in your tests, use [`testthat::test_path()`](https://testthat.r-lib.org/reference/test_path.html), this way you will get a filepath that works "both interactively and during tests". E.g. if you create a file under `tests/testthat/examples/image.png` in your tests you'll have to write [`testthat::test_path("examples", "image.png")`](https://testthat.r-lib.org/reference/test_path.html).

Conclusion
----------

In this post we offered a roundup around helper code and example files for your testthat unit tests. As often it was inspired by [a help thread](https://community.rstudio.com/t/why-are-tests-testthat-helper-files-discouraged-in-testthat/85253), on RStudio community. If you have some wisdom from your own testthat bag of tricks, please share it in the comments below!

[^1]: If you use something like [`browser()`](https://rdrr.io/r/base/browser.html), [`debug()`](https://rdrr.io/r/base/debug.html) etc. somewhere in your code and run the tests, the setup file will have been loaded.

[^2]: Actually you can choose to have [`devtools::load_all()`](https://devtools.r-lib.org//reference/load_all.html) *not* load the testthat helpers by using its `helpers` argument (`TRUE` by default).

[^3]: Installed with the package, and [run at package installation time](https://github.com/r-lib/testthat/issues/1206#issuecomment-713519962).

[^4]: Yes, you could [test the code supporting your tests](https://github.com/r-lib/testthat/issues/1206#issuecomment-713583205).

