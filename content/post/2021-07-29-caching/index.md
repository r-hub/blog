---
slug: cache
title: "How to cache results in R code" 
authors: 
- Maëlle Salmon 
- Christophe Dervieux
date: "2021-07-29" 
tags: 
- package development 
output: hugodown::hugo_document
rmd_hash: e9c856927d26f786

---

One principle of programming that's often encountered is "DRY", "Don't Repeat Yourself", that encourages e.g. the use of functions other duplicated (read: copy-pasted and slightly amended) code. You could also interpret it as don't let the machine repeat its calculations if useless. How about for a piece of code (function) with the same inputs, we only run it once per R session, and save the results for later? In this post, we shall go over ways to cache results in an R session, so that you don't need to burden machines. We will not cover [caching for R Markdown](https://bookdown.org/yihui/rmarkdown-cookbook/cache.html).

## Caching: what is it and why use it?

Caching means that if you call a function several times with the exact same input, the function is only actually run the first time. The result is stored in a cache of some sort (more practical details later!). Every other time the function is called with the same input, the result is retrieved from the cache. You will often think of caching as something valid in only one R session, but we'll see it can last longer via storage on disk.

Now, *why* use caching?

-   It might help save *time*.

-   It might help save *other resources of users such as money*: e.g. if the function calls a web API whose pricing depends on the number of hits. :sweat_smile:

-   It might be *more polite*. That's similar to the second item but from the perspective of e.g. a web API you keep hitting when you could have saved the result. The [polite package](https://dmi3kno.github.io/polite/) for polite webscraping caches results.

## Tools for caching in R

Here's a roundup of ways to cache code in R.

### The memoise package

The [memoise package](https://memoise.r-lib.org/) by Jim Hester is easy to use. Say I want to cache a function that only sleeps.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>.sleep</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/Sys.sleep.html'>Sys.sleep</a></span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span>
  <span class='s'>"Rested now!"</span>
<span class='o'>&#125;</span>

<span class='nv'>sleep</span> <span class='o'>&lt;-</span> <span class='nf'>memoise</span><span class='nf'>::</span><span class='nf'><a href='https://memoise.r-lib.org/reference/memoise.html'>memoise</a></span><span class='o'>(</span><span class='nv'>.sleep</span><span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/datasets/sleep.html'>sleep</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
utilisateur     système      écoulé 
      0.001       0.000       3.004 
<span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/datasets/sleep.html'>sleep</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
utilisateur     système      écoulé 
      0.037       0.000       0.038 </code></pre>

</div>

The second call to [`sleep()`](https://rdrr.io/r/datasets/sleep.html) is much quicker because, well, it does not call the `.sleep()` function so there's no sleep.

The memoise package also lets you

-   choose the duration of validity of the cache;

-   cache on disk -- on that topic see the R-hub blog post on [persistent data and config for R packages](/2020/03/12/user-preferences/).

If you use the memoise package in a package, do not forget to add

``` r
@importFrom memoise memoise
```

in one of your R scripts (thanks [Mark Padgham](https://mpadge.github.io/) for this tip!) otherwise you will get a R CMD Check NOTE.

### Saving results in an environment

This idea is more light-weight.

Using e.g. [`rlang::env_cache()`](https://rlang.r-lib.org/reference/env_cache.html) by Lionel Henry (in the development version of `{rlang}` at the time of writing).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># create an environment for storing results</span>
<span class='nv'>cache_env</span> <span class='o'>&lt;-</span> <span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/env.html'>new_environment</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'># the sleep function again, not memoised</span>
<span class='nv'>sleep</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/Sys.sleep.html'>Sys.sleep</a></span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span>
  <span class='s'>"Rested now!"</span>
<span class='o'>&#125;</span>

<span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='nv'>message</span> <span class='o'>&lt;-</span> <span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/env_cache.html'>env_cache</a></span><span class='o'>(</span><span class='nv'>cache_env</span>, <span class='s'>"message"</span>, <span class='nf'><a href='https://rdrr.io/r/datasets/sleep.html'>sleep</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
utilisateur     système      écoulé 
      0.001       0.000       3.003 
<span class='nf'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='o'>(</span><span class='nv'>message2</span> <span class='o'>&lt;-</span> <span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/env_cache.html'>env_cache</a></span><span class='o'>(</span><span class='nv'>cache_env</span>, <span class='s'>"message"</span>, <span class='nf'><a href='https://rdrr.io/r/datasets/sleep.html'>sleep</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
utilisateur     système      écoulé 
          0           0           0 

<span class='nv'>message</span>
[1] "Rested now!"
<span class='nv'>message2</span>
[1] "Rested now!"</code></pre>

</div>

### Stateful functions

This is not caching per se, but good to know! The [Advanced R book](https://adv-r.hadley.nz/function-factories.html?q=closure#stateful-funs) by Hadley Wickham presents *stateful functions* that "allow you to maintain state across function invocations". It also has a warning on not abusing them.

> "Stateful functions are best used in moderation. As soon as your function starts managing the state of multiple variables, it's better to switch to R6, the topic of Chapter 14."

## Caching best practice in packages

If your package use caching,

-   document that;
-   and also provide ways to clear the cache (see e.g. [opencage docs](https://docs.ropensci.org/opencage/articles/opencage.html#caching-1)).

## When not to cache in an R session

We can't end this post with a few words of caution.

Here are three cases when it'd be bad to cache:

-   *The gains in time are not worth the increased complexity*. You decide what's worth it. Think of future collaborators, some of whom might encounter caching for the first time.

-   *The results of a function with the same input might change*. E.g. the function you call gives you the current time. Or you call a web API whose data is updated very regularly (although in that case rather than not caching you might want to look into the duration of your).

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

In this post we summarized tools and tips on how to cache results in R code. Have you used caching in one of your packages or scripts? What tool did you use?

