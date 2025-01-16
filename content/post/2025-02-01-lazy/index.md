---
slug: lazy-meanings
title: "Lazy introduction to laziness in R" 
authors: 
- Maëlle Salmon
date: "2025-02-01" 
tags: 
- package development
- programming
output: hugodown::hugo_document
rmd_hash: 84b7a3fc5ab271e6

---

In the programming world, laziness can often be a good thing: it is both a human quality that can motivate automation efforts, and a programming concept that avoids wasting resources such as memory. Now, when reading code or documentation, seeing the word "lazy" can be confusing, because of its polisemy: it carries several meanings. In this post, we will enumerate the different possible definitions of "lazy" in R code.

## Lazy as in lazy evaluation

You might know that R provides **lazy evaluation**: the arguments of a function are only evaluated if they are accessed. In short, you can pass anything as an argument value to a function without any problem as long as the function does not use that value. The contrary of lazy evaluation is **eager evaluation**.

The [Advanced R book by Hadley Wickham](https://adv-r.hadley.nz/functions.html#lazy-evaluation) features a very clear introduction to lazy evaluation.

Note that the workhorse of lazy evaluation in base R is a thing called a **promise** that contains an *expression* (the recipe for getting a value), an *environment* (the ingredients that are around), a *value*. The latter is only computed when accessed, and cached once computed.

### What about {future}?

Maybe you have heard of the [future package](https://future.futureverse.org/index.html) by Henrik Bengtsson. It provides an implementation in R of **futures**, a programming concept. Its homepage state "In programming, a future is an abstraction for a value that may be available at some point in the future. The state of a future can either be unresolved or resolved."

With futures, you create a future, that is associated to a **promise**, which is a **placeholder for a value** and then the value itself (so not the same definition of "promise" as the "promises" used by base R in the context of lazy evaluation). The value can be computed asynchronously, which means in parallel. Therefore, the futures package allows R programmers to take full advantage of their local computing resources: cores, clusters, etc.

Now, to add confusion beyond the different meaning of "promise" in this context, [by default](https://future.futureverse.org/reference/future.html) a future is **not lazy**, it is **eager**. This means that it is computed immediately unless you specify an alternative method (a "plan").

By default, the creation of a future below (`eager_future`) takes as much time as not wrapping the code in a future, because the computation is immediate. Setting `lazy` to `TRUE` makes the future creation much faster (`lazy_future`).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='s'><a href='https://future.futureverse.org'>"future"</a></span><span class='o'>)</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nv'>no_future</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Some expressions had a GC in every iteration; so filtering is disabled.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                         min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                    <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> no_future &lt;- runif(n = 1e+07)    280ms    287ms      3.48    76.3MB     3.48</span></span>
<span></span><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nv'>eager_future</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://future.futureverse.org/reference/future.html'>future</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                             min median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                           <span style='color: #555555; font-style: italic;'>&lt;bch&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> eager_future &lt;- future(runif(n = 1e… 232ms  232ms      4.30    83.1MB     4.30</span></span>
<span></span><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='nv'>lazy_future</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://future.futureverse.org/reference/future.html'>future</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span>, lazy <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                             min median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                           <span style='color: #555555; font-style: italic;'>&lt;bch&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> lazy_future &lt;- future(runif(n = 1e+… 599µs  642µs     <span style='text-decoration: underline;'>1</span>484.    12.8KB     14.5</span></span>
<span></span></code></pre>

</div>

If we do retrieve the value, overall the same time is spent between creating the future and our getting the value:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_seed.html'>local_seed</a></span><span class='o'>(</span><span class='m'>42</span><span class='o'>)</span></span>
<span>  <span class='nv'>a</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span></span>
<span>  <span class='nv'>a</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Some expressions had a GC in every iteration; so filtering is disabled.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                             min median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                           <span style='color: #555555; font-style: italic;'>&lt;bch&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> &#123; withr::local_seed(42) a &lt;- runif(… 290ms  291ms      3.43    76.6MB     3.43</span></span>
<span></span><span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_seed.html'>local_seed</a></span><span class='o'>(</span><span class='m'>42</span><span class='o'>)</span></span>
<span>  <span class='nv'>b</span> <span class='o'>&lt;-</span> <span class='nf'>future</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='nf'>value</span><span class='o'>(</span><span class='nv'>b</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: UNRELIABLE VALUE: Future ('&lt;none&gt;') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".</span></span>
<span></span><span><span class='c'>#&gt; Warning: UNRELIABLE VALUE: Future ('&lt;none&gt;') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".</span></span>
<span></span><span><span class='c'>#&gt; Warning: UNRELIABLE VALUE: Future ('&lt;none&gt;') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                             min median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                           <span style='color: #555555; font-style: italic;'>&lt;bch&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> &#123; withr::local_seed(42) b &lt;- future… 249ms  249ms      4.02    83.3MB     4.02</span></span>
<span></span><span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='http://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span><span class='o'>&#123;</span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_seed.html'>local_seed</a></span><span class='o'>(</span><span class='m'>42</span><span class='o'>)</span></span>
<span>  <span class='nv'>c</span> <span class='o'>&lt;-</span> <span class='nf'>future</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span>, lazy <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='nf'>value</span><span class='o'>(</span><span class='nv'>c</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: UNRELIABLE VALUE: Future ('&lt;none&gt;') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".</span></span>
<span></span><span><span class='c'>#&gt; Warning: UNRELIABLE VALUE: Future ('&lt;none&gt;') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".</span></span>
<span></span><span><span class='c'>#&gt; Warning: UNRELIABLE VALUE: Future ('&lt;none&gt;') unexpectedly generated random numbers without specifying argument 'seed'. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify 'seed=TRUE'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, use 'seed=NULL', or set option 'future.rng.onMisuse' to "ignore".</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 6</span></span></span>
<span><span class='c'>#&gt;   expression                             min median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>                           <span style='color: #555555; font-style: italic;'>&lt;bch&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> &#123; withr::local_seed(42) c &lt;- future… 246ms  246ms      4.07    76.4MB     4.07</span></span>
<span></span></code></pre>

</div>

Therefore, the use of futures and the use of lazy evaluation are orthogonal concepts: you can use future with or without lazy evaluation. The future package is about *how* the value is computed (in parallel or sequentially for instance), lazy evaluation is about *when* the value is computed (right as it is defined, or only when it is needed).

## Lazy as in lazy database operations

In the database world, queries can be lazy: the query is like a TODO list that is only executed (computed, evaluated) when you want to access the resulting table or result. Making the output tangible is called *materialization*.

This is vocabulary we can encounter when using:

-   the [dbplyr package](https://dbplyr.tidyverse.org/), which is the dplyr back-end for databases. "All dplyr calls are evaluated lazily, generating SQL that is only sent to the database when you request the data."
-   the [dtplyr package](https://dtplyr.tidyverse.org/index.html), which is a data.table back-end for dplyr. The ["lazy" data.table objects](https://dtplyr.tidyverse.org/reference/lazy_dt.html) "captures the intent of dplyr verbs, only actually performing computation when requested" (with `collect()` for instance). The manual also explains that this allows dtplyr to make the code more performant by simplifying the data.table calls.
-   the [duckplyr package](https://duckplyr.tidyverse.org/dev/), which is a drop-in replacement for dplyr, powered by DuckDB for fast operation. "Queries on the remote data are executed lazily, and the results are not materialized until explicitly requested."

In the case of the duckplyr package, the behavior can be [switched off](https://duckplyr.tidyverse.org/dev/articles/developers.html?q=lazy#eager-and-lazy-modes) depending on one's preferences around fallbacks to dplyr.

### duckplyr, lazy evaluation and deferred evaluation

The case of the duckplyr package is also interesting in that its implementation [uses ALTREP](https://duckdb.org/2024/04/02/duckplyr.html#eager-vs-lazy-materialization), a powerful R feature that among other things supports **deferred evaluation**.

> ALTREP allows R objects to have different in-memory representations, and for custom code to be executed whenever those objects are accessed.

If the thing accessing the duckplyr data.frame is...

-   not duckplyr, then a special callback is executed, allowing materialization of the data frame.
-   duckplyr, then the operations continue to be lazy (until a call to `collect.duckplyr_df()` for instance).

Therefore, duckplyr can be both lazy (within itself) and not lazy (for the outside world). :zany_face:

## Lazy as in frugal file modifications

The [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html) function, that creates a documentation website for an R package, features a [`lazy` argument](https://pkgdown.r-lib.org/reference/build_site.html#arg-lazy). "If `TRUE`, will only rebuild articles and reference pages if the source is newer than the destination."

It is a much simpler concept of laziness: decide right now whether it is needed to rebuild each page.

The potools package, that provides tools for portability and internationalization of R packages, uses ["lazy" for a similar meaning](https://michaelchirico.github.io/potools/reference/po_update.html?q=lazy#ref-usage).

## Lazy as in lazy quantifiers in regular expressions

In regular expressions you can use [quantifiers](https://blog.djnavarro.net/posts/2024-12-16_regex-backreferences/#quantifiers) to indicate how many times a pattern must appear: the pattern can be optional, appear several times, etc. You can also specify whether the tool should match as many repetitions as possible, or the fewest number of repetitions possible.

Matching the fewest number of repetitions possible is "lazy" (stingy, I made that up). Matching as many repetitions as possible is "eager" (or greedy, actual term).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>string</span> <span class='o'>&lt;-</span> <span class='s'>"aaaaaa"</span></span>
<span><span class='c'># greedy! eager!</span></span>
<span><span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_match.html'>str_match</a></span><span class='o'>(</span><span class='nv'>string</span>, <span class='s'>"a+"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;      [,1]    </span></span>
<span><span class='c'>#&gt; [1,] "aaaaaa"</span></span>
<span></span><span><span class='c'># stringy! lazy!</span></span>
<span><span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_match.html'>str_match</a></span><span class='o'>(</span><span class='nv'>string</span>, <span class='s'>"a+?"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;      [,1]</span></span>
<span><span class='c'>#&gt; [1,] "a"</span></span>
<span></span></code></pre>

</div>

## Conclusion

In the context of lazy evaluation and lazy database operations we can think of lazy as a sort of parcimonious procrastination. In the case of frugal file modifications in pkgdown and potools, no procrastination, an informed decision is made on the spot on whether a computation is needed. In the case of lazy quantifiers in regular expressions, lazy means stingy.

Overall, an user can expect "lazy" means less waste, but it is crucial the documentation of the particular piece of software at hand clarifies the meaning and the potential trade-offs.

