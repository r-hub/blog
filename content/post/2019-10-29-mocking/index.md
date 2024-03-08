---
title: Mocking is catching
authors:
  - Maëlle Salmon
date: '2019-10-29'
slug: mocking
tags:
  - testing
  - mocking
---

*See also the [more recent update](/2024/03/13/mocking-new-take/).*

When [writing unit tests for a package](https://r-pkgs.org/tests.html), you might find yourself wondering about how to best test the behaviour of your package

-   when the data it's supposed to munge has this or that quirk,

-   when the operating system is Windows,

-   when a package enhancing its functionality is not there,

-   when a web API returns an error;

or you might even wonder how to test at least part of that package of yours that calls a web API or local database... *without accessing the web API or local database during testing*.

In some of these cases, the programming concept you're after is *mocking*, i.e. making a function act *as if* something were a certain way!
In this blog post we shall offer a round-up of resources around mocking, or not mocking, when unit testing an R package.

<!--html_preserve-->{{% tweet "1156754150828498945" %}}<!--/html_preserve-->

Please keep reading, do not flee to Twitter!
:wink: (The talented Sharla did end up using mocking for [her package](https://sharlagelfand.github.io/opendatatoronto/)!)

## Packages for mocking

### General mocking

Nowadays, when using `testthat` for testing, the recommended tool for mocking is the [`mockery` package](https://github.com/r-lib/mockery), *not* `testthat`'s own `with_mock()` function.
To read how they differ in their implementation of mocking, refer to [this issue](https://github.com/r-lib/mockery/issues/8#issuecomment-259005484) and [that section of `mockery` README](https://github.com/r-lib/mockery#comparison-to-with_mock).
In brief, with `mockery` you can stub (i.e. replace) a function in a given environment e.g. the environment of a function.
Let's create a small toy example to illustrate that.

``` r
# a function that says encoding is a pain
# when the OS is Windows
is_encoding_a_pain <- function(){
  if (Sys.info()[["sysname"]] == "Windows"){
    return("YES")
  } else {
    return("no")
  }
}

# The post was rendered on Ubuntu
Sys.info()[["sysname"]]
```

```         
## [1] "Linux"
```

``` r
# So, is encoding a pain?
is_encoding_a_pain()
```

```         
## [1] "no"
```

``` r
# stub/replace Sys.info() in is_encoding_a_pain()
# with a mock that answers "Windows"
mockery::stub(where = is_encoding_a_pain,
              what = "Sys.info", 
              how = c(sysname = "Windows"))

# Different output
is_encoding_a_pain()
```

```         
## [1] "YES"
```

``` r
# NOT changed
Sys.info()[["sysname"]]
```

```         
## [1] "Linux"
```

Let's also look at a real life example, [from `keyring` tests](https://github.com/r-lib/keyring/blob/0cdd366dfd2e8accbf94dd43643531f6f6e1acff/tests/testthat/test-default-backend.R#L56):

``` r
test_that("auto windows", {
  mockery::stub(default_backend_auto, "Sys.info", c(sysname = "Windows"))
  expect_equal(default_backend_auto(), backend_wincred)
})
```

What happens after the call to `mockery::stub()` is that inside the test, when `default_backend_auto()` is called, it won't use the actual `Sys.info()` but instead a mock that returns `c(sysname = "Windows")` so the test can assess what `default_backend_auto()` returns on Windows... without the test being run on a Windows machine.
:sunglasses:

Instead of directly defining the return value as is the case in this example, one could stub the function with a function, [as seen in one of the tests for the `remotes` package](https://github.com/cran/remotes/blob/f1b3e75c162f555dec0c7ab9dba7dbf9faf69444/tests/testthat/test-install-svn.R#L78).

To find more examples of how to use `mockery` in tests, you can use GitHub search in combination with [R-hub's CRAN source code mirror](https://docs.r-hub.io/#cranatgh): <https://github.com/search?l=&q=%22mockery%3A%3Astub%22+user%3Acran&type=Code>

### Web mocking

In the case of a package doing HTTP requests, you might want to test what happens when an error code is received for instance.
To do that, you can use either [`httptest`](https://github.com/nealrichardson/httptest) or [`webmockr`](https://github.com/ropensci/webmockr) (compatible with both `httr` and `crul`).

### Temporarily modify the global state

To test what happens when, say, an environment variable has a particular value, one can set it temporarily within a test using the [`withr` package](https://github.com/r-lib/withr).
You could argue it's not technically mocking, but it's an useful trick.
You can see it in action [in `keyring`'s tests](https://github.com/r-lib/keyring/blob/0cdd366dfd2e8accbf94dd43643531f6f6e1acff/tests/testthat/test-default-backend.R#L18).
*Edit on 2020-04-30: Jenny Bryan wrote an [excellent blog post about "Self-cleaning test fixtures" that explains how and why to use `withr` in tests](https://www.tidyverse.org/blog/2020/04/self-cleaning-test-fixtures/).*

## To mock or... not to mock

Sometimes, you might not need *mocking* and can resort to an alternative approach instead, using the real thing/situation.
You could say it's a less "unit" approach and requires more work.

### Fake input data

For say a plotting or modelling library, you can tailor-make data.
Comparing approaches or packages for creating fake data are beyond the scope of this post, so let's just name a few packages:

-   [`charlatan`](https://docs.ropensci.org/charlatan/),

-   [`fakir`](https://thinkr-open.github.io/fakir/),

-   [`salty`](https://github.com/mdlincoln/salty) (for "salting" clean data i.e. adding errors in it).

### Stored data from a web API / a database

As [explained in this discussion about testing web API packages](https://discuss.ropensci.org/t/best-practices-for-testing-api-packages/460/), when testing a package accessing and munging web data you might want to separate testing of the data access and of the data munging, on the one hand because failures will be easier to trace back to a problem in the web API vs. your code, on the other hand to be able to selectively turn off some tests based on internet connection, the presence of an API key, etc.
Storing and replaying HTTP requests is supported by:

-   [`vcr`](https://github.com/ropensci/vcr) with [`webmockr`](https://github.com/ropensci/webmockr),

-   [`httptest`](https://github.com/nealrichardson/httptest).

What about applying the same idea to packages using a *database* connection?

-   [The test suite of `dbplyr`](https://github.com/tidyverse/dbplyr/tree/master/tests) could be a good inspiration.

-   There is [a nascent package called `dbtest`](https://github.com/jonkeane/dbtest/) that is similar to `httptest`, but for databases.

### Different operating systems

Say you want to be sure your packages builds correctly on another operating system... you can use [R-hub package builder](https://docs.r-hub.io) :grin: or maybe a [continuous integration service](https://devguide.ropensci.org/ci.html).

### Different system configurations or libraries

Regarding the case where you want to test your package when a suggested dependency is or is not installed, you can use the configuration script of a continuous integration service to have at least one build without that dependency:

<!--html_preserve-->{{% tweet "1180175458782076928" %}}<!--/html_preserve-->

## Conclusion

In this post we offered a round-up of resources around mocking when unit testing R packages, as well as around *not* mocking.
To learn about more packages for testing your package, [refer to the list published on Locke Data's blog](https://itsalocke.com/blog/packages-for-testing-your-r-package/).
Now, what if you're not sure about the best approach for that quirky thing you want to test, mocking or not mocking, and how exactly?
Well, you can fall back on two methods: [Reading the source code](/2019/05/14/read-the-source/) of other packages, and [Asking for help](/2019/04/11/r-package-devel/)!
Good luck!
:rocket:
