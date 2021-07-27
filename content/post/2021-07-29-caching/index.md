---
slug: cache
title: "Caching the results of functions of your R package" 
authors: 
- Maëlle Salmon 
- Christophe Dervieux
date: "2021-07-29" 
tags: 
- package development 
output: hugodown::hugo_document
rmd_hash: ae6b09d1ceb043ce

---

One principle of programming that's often encountered is "DRY", "Don't Repeat Yourself", that encourages e.g. the use of functions over duplicated (read: copy-pasted and slightly amended) code. You could also interpret it as don't let the machine repeat its calculations if useless. How about for a function with the same inputs (or with no argument!), we only run it once e.g. per R session, and save the results for later? In this post, we shall go over ways to cache results of R functions, so that you don't need to burden machines and humans.

## Caching: what is it and why use it?

Caching means that if you call a function several times with the exact same input, the function is only actually run the first time. The result is stored in a cache of some sort (more practical details later!). Every other time the function is called with the same input, the result is retrieved from the cache unless [invalidated](https://yihui.org/en/2018/06/cache-invalidation/). You will often think of caching as something valid in only one R session, but we'll see it can be persistent across sessions via storage on disk.

Now, *why* use caching?

-   It might help save *time*.

-   It might help save *other resources of users such as money*: e.g. if the function calls a web API whose pricing depends on the number of hits. :sweat_smile:

-   It might be *more polite*. That's similar to the second item but from the perspective of e.g. a web API you keep hitting when you could have saved the result. The [polite package](https://dmi3kno.github.io/polite/) for polite webscraping caches results.

Caching can be about results of functions but also some user *inputs* that won't change for the session and you don't want to ask every time you need it (being *polite*!). It could be per session caching but also persistent caching. As an example, **reticulate** will ask you once if you want to install miniconda by storing your answer locally if you say no and not ask again. (See internal [`miniconda_install_prompt()`](https://github.com/rstudio/reticulate/blob/edc22999925fd47e47c89e7196001446aec23806/R/miniconda.R#L284)).

## Tools for caching in R

Here's a roundup of some ways to cache results of functions in R.

### The memoise package

The [memoise package](https://memoise.r-lib.org/) by Jim Hester is easy to use. Say we want to cache a function that only sleeps.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>.sleep</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/Sys.sleep.html'>Sys.sleep</a></span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span>
  <span class='s'>"Rested now!"</span>
<span class='o'>&#125;</span>

<span class='nv'>sleep</span> <span class='o'>&lt;-</span> <span class='nf'>memoise</span><span class='nf'>::</span><span class='nf'><a href='https://memoise.r-lib.org/reference/memoise.html'>memoise</a></span><span class='o'>(</span><span class='nv'>.sleep</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/datasets/sleep.html'>sleep</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
utilisateur     système      écoulé 
      0.001       0.000       3.003 
<span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/datasets/sleep.html'>sleep</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
utilisateur     système      écoulé 
      0.036       0.001       0.036 </code></pre>

</div>

The second call to [`sleep()`](https://rdrr.io/r/datasets/sleep.html) is much quicker because, well, it does not call the `.sleep()` function so there's no sleep.

The memoise package also lets you

-   choose the duration of validity of the cache;

-   [cache on disk](#storing-on-disk).

If you use the memoise package in a package, do not forget to add

``` r
@importFrom memoise memoise
```

in one of your R scripts (thanks [Mark Padgham](https://mpadge.github.io/) for this tip!) otherwise you will get a R CMD Check NOTE. This is because R will look for package usage in function bodies, whereas the call to memoise is at the top-level.

    Result: NOTE
        Namespace in Imports field not imported from: ‘memoise’
         All declared Imports should be used.

### Function factory

Now what if you want simple memoization and no dependency on the memoise package? In that case you might be interested in creating some sort of function factory. See the example below, with `who_am_i_impl()` the function factory. We use it to create the `who_am_i()` function whose results are then stored for the session.

``` r
who_am_i_impl <- function() {
    name <- NULL
    function() {
        if (is.null(name)) {
            name <<- readline("I don't know you. Can you tell me your name ? ")
            message("Welcome ", name, "!")
        } else {
            message("I know you! You are ", name, ". Hello again!")
        }
        invisible(name)
    }
}
who_am_i <- who_am_i_impl()
who_am_i()
#> I don't know you. Can you tell me your name ? cderv
#> Welcome cderv!
who_am_i()
#> I know you! You are cderv. Hello again!
```

In the whoami package by Gábor Csárdi, there is an internal function `lookup_gh_username()` that calls the GitHub API. It is memoized without the memoise package.

-   In [`.onLoad()`](https://github.com/r-lib/whoami/blob/40999c9945104f740d0fe13ed07288879aec14c6/R/whoami.R#L2) the memoization function is called

``` r
.onLoad <- function(libname, pkgname) {
  lookup_gh_username <<- memoize_first(lookup_gh_username)
}
```

-   What's the [memoization function](https://github.com/r-lib/whoami/blob/40999c9945104f740d0fe13ed07288879aec14c6/R/whoami.R#L10), you ask?

``` r
memoize_first <- function(fun) {
  fun
  cache <- list()
  dec <- function(arg, ...) {
    if (!is_string(arg)) return(fun(arg, ...))
    if (is.null(cache[[arg]])) cache[[arg]] <<- fun(arg, ...)
    cache[[arg]]
  }
  dec
}
```

This function is a closure (a [function creating a function](https://adv-r.hadley.nz/function-factories.html?q=closure#function-factories)). It caches results in a list from where they are retrieved in the function gets called a second time with the same argument.

In the [Advanced R book](https://adv-r.hadley.nz/function-factories.html?q=closure#stateful-funs) by Hadley Wickham such function factories are called *stateful functions* that "allow you to maintain state across function invocations". It also has a warning on not abusing them.

> "Stateful functions are best used in moderation. As soon as your function starts managing the state of multiple variables, it's better to switch to R6, the topic of Chapter 14."

### Saving results in an environment

This is well suited for package development where

-   You create an environment internal to your package where you store a value
-   You can then store in it any computed value for the current R session where the package is loaded.

Here's an example with only base R functions

``` r
cache_env <- new.env(parent = emptyenv())
who_am_i <- function() {
  if (is.null(cache_env$name)) {
    cache_env$name <- readline("I don't know you. Can you tell me your name ? ")
  }
  message("Welcome ", cache_env$name, "!")
  invisible(cache_env$name)
}
get_current_name <- function() {
  cache_env$name
}
who_am_i()
#> I don't know you. Can you tell me your name ? cderv
#> Welcome cderv!
who_am_i()
#> Welcome cderv!
```

This example would be simpler if using [`rlang::env_cache()`](https://rlang.r-lib.org/reference/env_cache.html) by Lionel Henry (in the development version of [rlang](https://rlang.r-lib.org/) at the time of writing).

``` r
cache_env <- rlang::new_environment()
who_am_i <- function() {
  name <- rlang::env_cache(
    env = cache_env, nm = "name", 
    default = readline("I don't know you. Can you tell me your name ? ")
  )
  message("Welcome ", name, "!")
  invisible(name)
}
get_current_name <- function() {
  cache_env$name
}
who_am_i()
#> I don't know you. Can you tell me your name ? cderv
#> Welcome cderv!
who_am_i()
#> Welcome cderv!
```

### Storing on disk?

For persistent caching across R sessions you will need to store function results on disk. On that topic see also the R-hub blog post on [persistent data and config for R packages](/2020/03/12/user-preferences/)

*Where* to store results on disk? Best practice is to use user data dir via the rappdirs package or [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html) from R version 4.0. You might see some local caching e.g. what [`httr::oauth2.0_token()`](https://httr.r-lib.org/reference/oauth2.0_token.html) does, in that case with editing of the `.gitignore` file as the cached result is a secret!

*How* to store results on disk? Text files are great for short string values. Writing compressed RDS files is also an option. In any case, cache storage should usually be small for internal use in the package (as opposed to the huge computation caching a package like [targets](https://books.ropensci.org/targets/) supports).

## Caching documentation

If your package use caching,

-   document that;
-   and also provide ways to clear the cache (see e.g. [opencage docs](https://docs.ropensci.org/opencage/articles/opencage.html#caching-1)); this is especially crucial for persistent caching as it would be fine to simply say the user has to restart the R session.

## When not to cache in an R session

We can't end this post with a few words of caution.

Here are three cases when it'd be bad to cache:

-   *The gains in time and other resources are not worth the increased complexity*. You decide what's worth it. Think of future collaborators, some of whom might encounter caching for the first time.

-   *The results of a function with the same input might change*. E.g. the function you call gives you the current time. Or you call a web API whose data is updated very regularly (although in that case rather than not caching you might want to look into the validity time of your cache).

-   *The function should not be called several times to begin with*. I.e., do not use caching as a band-aid for bad code design.

E.g.

``` r
name <- "Beyonce"

capitalize_name <- function(name) {
  toupper(name)
}

say_hello <- function(name) {
  name <- tolower(name)
  sprintf("Hello %s", capitalize_name(name))
}

say_goodbye <- function(name) {
  name <- tolower(name)
  sprintf("Goodbye %s", capitalize_name(name))
}

say_hello(name)
say_goodbye(name)
```

You could cache `capitalize_name()` but it'd make more sense to call it only once before calling `say_hello()` and `say_goodbye()`. This is a very simple not optimal example but the idea of not using caching is brought to you by recent experience of one of the authors. :wink: Amending the structure and logic of your code so that a function does not get called twice with the exact same input might help save time, and might make the code easier to follow, but if it actually makes the code more complicated, maybe don't do that.

Note that as a package author, you do not know how the users will call a function. If you provide a package whose functions call a [geocoding API whose data is updated only daily](https://docs.ropensci.org/opencage/), you might hope your users do some sort of grouping before calling the API. But because you know they won't necessarily do that, you can add caching!

## Conclusion

In this post we summarized tools and tips on how to cache results in R code.

We have not covered other types of caching relevant for R users: [caching for R Markdown](https://bookdown.org/yihui/rmarkdown-cookbook/cache.html), [caching for Shiny](https://shiny.rstudio.com/articles/caching.html), caching in projects via the use of [the targets package](https://books.ropensci.org/targets/) (or its superseded predecessor [drake](https://books.ropensci.org/drake/)). Lots to explore based on your use case! :wink:

Have you used caching in one of your packages or scripts? What tool did you use?

