---
slug: lazy-meanings
title: "Lazy introduction to laziness in R" 
authors: 
- Maëlle Salmon
- Athanasia Mo Mowinckel
- Hannah Frick
date: "2025-02-08" 
tags: 
- package development
- programming
output: hugodown::hugo_document
rmd_hash: 80862337571d31d9

---

In the programming world, laziness can often be a good thing: it is both a human quality that can motivate automation efforts, and a programming concept that avoids wasting resources such as memory. Now, when reading code or documentation, seeing the word "lazy" can be confusing, because of its polisemy: it carries several meanings. In this post, we will enumerate the different possible definitions of "lazy" in R code.

## Lazy as in lazy evaluation

You might know that R provides **lazy evaluation**: the arguments of a function are only evaluated if they are accessed. In short, you can pass anything as an argument value to a function without any problem as long as the function does not use that value.

For instance, the code below works despite `evaluation`'s not existing, because the definition of the `do_something()` function includes ellipsis, and because the `lazy` argument is actually not used.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>do_something</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>na.rm</span> <span class='o'>=</span> <span class='kc'>TRUE</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span>, na.rm <span class='o'>=</span> <span class='nv'>na.rm</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nf'>do_something</span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span>, lazy <span class='o'>=</span> <span class='nv'>evaluation</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 5.5</span></span>
<span></span></code></pre>

</div>

The contrary of lazy evaluation is **eager evaluation**.

The [Advanced R book by Hadley Wickham](https://adv-r.hadley.nz/functions.html#lazy-evaluation) features a very clear introduction to lazy evaluation.

Note that the workhorse of lazy evaluation in base R is a thing called a **promise** that contains an *expression* (the recipe for getting a value), an *environment* (the ingredients that are around), and a *value*. The latter is only computed when accessed, and cached once computed.

### What about {future}'s promises?

Maybe you have heard the word "promises" in R in the context of the [future package](https://future.futureverse.org/index.html) by Henrik Bengtsson. It provides an implementation in R of **futures**, a programming concept. Its homepage state "In programming, a future is an abstraction for a value that may be available at some point in the future. The state of a future can either be unresolved or resolved."

When using the {future} package, you create a future, that is associated to a **promise**, which is a **placeholder for a value** and then the value itself (so not the same definition of "promise" as the "promises" used by base R in the context of lazy evaluation). The value can be computed asynchronously, which means in parallel. Therefore, the futures package allows R programmers to take full advantage of their local computing resources: cores, clusters, etc.

To come back to laziness, [by default](https://future.futureverse.org/reference/future.html) a future is **not lazy**, it is **eager**. This means that it is computed immediately.

By default, the creation of a future below (`eager_future`) takes as much time as not wrapping the code in a future, because the computation is immediate. Setting `lazy` to `TRUE` makes the future creation much faster (`lazy_future`).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='s'><a href='https://future.futureverse.org'>"future"</a></span><span class='o'>)</span></span>
<span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='https://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  no_future <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  eager_future <span class='o'>=</span> <span class='nf'><a href='https://future.futureverse.org/reference/future.html'>future</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>,</span>
<span>  lazy_future <span class='o'>=</span> <span class='nf'><a href='https://future.futureverse.org/reference/future.html'>future</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span>, lazy <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>,</span>
<span>  check <span class='o'>=</span> <span class='kc'>FALSE</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Some expressions had a GC in every iteration; so filtering is disabled.</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 6</span></span></span>
<span><span class='c'>#&gt;   expression        min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> no_future       235ms    236ms      4.19    76.3MB     2.80</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> eager_future    241ms    242ms      4.06    83.1MB     4.06</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> lazy_future     745µs    977µs    842.      13.8KB    10.0</span></span>
<span></span></code></pre>

</div>

If we do retrieve the value, overall the same time is spent between creating the future and our getting the value:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>bench</span><span class='nf'>::</span><span class='nf'><a href='https://bench.r-lib.org/reference/mark.html'>mark</a></span><span class='o'>(</span></span>
<span>  no_future <span class='o'>=</span> <span class='o'>&#123;</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span><span class='o'>&#125;</span>,</span>
<span>  eager_future <span class='o'>=</span> <span class='o'>&#123;</span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://future.futureverse.org/reference/future.html'>future</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>; <span class='nf'><a href='https://future.futureverse.org/reference/value.html'>value</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>&#125;</span>,</span>
<span>  lazy_future <span class='o'>=</span> <span class='o'>&#123;</span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://future.futureverse.org/reference/future.html'>future</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>10000000</span><span class='o'>)</span><span class='o'>)</span>, lazy <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>; <span class='nf'><a href='https://future.futureverse.org/reference/value.html'>value</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>&#125;</span>,</span>
<span>  check <span class='o'>=</span> <span class='kc'>FALSE</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 6</span></span></span>
<span><span class='c'>#&gt;   expression        min   median `itr/sec` mem_alloc `gc/sec`</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;bch:expr&gt;</span>   <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:tm&gt;</span>     <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;bch:byt&gt;</span>    <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span> no_future       236ms    239ms      4.20    76.3MB     4.20</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span> eager_future    241ms    241ms      4.11    76.6MB     4.11</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span> lazy_future     253ms    254ms      3.94    76.4MB     3.94</span></span>
<span></span></code></pre>

</div>

Therefore, the use of futures and the use of lazy evaluation are orthogonal concepts: you can use future with or without lazy evaluation. The future package is about *how* the value is computed (in parallel or sequentially for instance), lazy evaluation is about *when* the value is computed (right as it is defined, or only when it is needed).

## Lazy as in lazy database operations

In the database world, queries can be lazy: the query is like a TODO list that is only executed (computed, evaluated) when you want to access the resulting table or result. Making the output tangible is called **materialization**.

This is vocabulary we can encounter when using:

-   the [dbplyr package](https://dbplyr.tidyverse.org/) maintained by Hadley Wickham, which is the dplyr back-end for databases. *"All dplyr calls are evaluated lazily, generating SQL that is only sent to the database when you request the data."*

Slightly tweaked from the dbplyr README,

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># load packages</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='s'><a href='https://dbplyr.tidyverse.org/'>"dbplyr"</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'dbplyr'</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:dplyr':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     ident, sql</span></span>
<span></span><span></span>
<span><span class='c'># create the connection and refer to the table</span></span>
<span><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/copy_to.html'>copy_to</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='nv'>mtcars</span><span class='o'>)</span></span>
<span><span class='nv'>mtcars2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/tbl.html'>tbl</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"mtcars"</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># create the query</span></span>
<span><span class='nv'>summary</span> <span class='o'>&lt;-</span> <span class='nv'>mtcars2</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>mpg <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>mpg</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/desc.html'>desc</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># the object is lazy, the value is not computed yet</span></span>
<span><span class='c'># here is what summary looks like at this stage</span></span>
<span><span class='nv'>summary</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Source:     SQL [?? x 2]</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Database:   sqlite 3.47.1 [:memory:]</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Ordered by: desc(mpg)</span></span></span>
<span><span class='c'>#&gt;     cyl   mpg</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     4  26.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     6  19.7</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8  15.1</span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>summary</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span><span></span>
<span><span class='c'># we explicitly request the data, so now it's there</span></span>
<span><span class='nv'>answer</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/compute.html'>collect</a></span><span class='o'>(</span><span class='nv'>summary</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>answer</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 3</span></span>
<span></span></code></pre>

</div>

-   the [dtplyr package](https://dtplyr.tidyverse.org/index.html) also maintained by Hadley Wickham, which is a data.table back-end for dplyr. The ["lazy" data.table objects](https://dtplyr.tidyverse.org/reference/lazy_dt.html) *"captures the intent of dplyr verbs, only actually performing computation when requested"* (with [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) for instance). The manual also explains that this allows dtplyr to make the code more performant by simplifying the data.table calls.

Slightly tweaked from dtplyr README,

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># load packages</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://r-datatable.com'>data.table</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'data.table'</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:dplyr':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     between, first, last</span></span>
<span></span><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dtplyr.tidyverse.org'>dtplyr</a></span><span class='o'>)</span></span>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># create a “lazy” data table that tracks the operations performed on it.</span></span>
<span><span class='nv'>mtcars2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dtplyr.tidyverse.org/reference/lazy_dt.html'>lazy_dt</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># create the query</span></span>
<span><span class='nv'>summary</span> <span class='o'>&lt;-</span> <span class='nv'>mtcars2</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>wt</span> <span class='o'>&lt;</span> <span class='m'>5</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>l100k <span class='o'>=</span> <span class='m'>235.21</span> <span class='o'>/</span> <span class='nv'>mpg</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> <span class='c'># liters / 100 km</span></span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> </span>
<span>  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span><span class='o'>(</span>l100k <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>l100k</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># the object is lazy, the value is not computed yet</span></span>
<span><span class='nv'>summary</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Source: </span>local data table [3 x 2]</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Call:   </span>`_DT1`[wt &lt; 5][, `:=`(l100k = 235.21/mpg)][, .(l100k = mean(l100k)), </span></span>
<span><span class='c'>#&gt;     keyby = .(cyl)]</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     cyl l100k</span></span>
<span><span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>1</span>     4  9.05</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>2</span>     6 12.0 </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>3</span>     8 14.9 </span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'># Use as.data.table()/as.data.frame()/as_tibble() to access results</span></span></span>
<span></span><span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>summary</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span><span></span>
<span><span class='c'># we explictly request the data, so now it's there</span></span>
<span><span class='nv'>answer</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://tibble.tidyverse.org/reference/as_tibble.html'>as_tibble</a></span><span class='o'>(</span><span class='nv'>summary</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>answer</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 3</span></span>
<span></span></code></pre>

</div>

-   [the duckplyr package](https://duckplyr.tidyverse.org/dev/) which deserves its own subsection as its objects are both lazy and eager.

### duckplyr, lazy evaluation and prudence

The duckplyr package is a package that uses DuckDB under the hood but that is also a drop-in replacement for dplyr. These two facts create a tension:

-   When using dplyr, we are not used to explicitly collect results: the data.frames are eager by default. Adding a [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) step by default would confuse users and make "drop-in replacement" an exaggeration. Therefore, duckplyr needs eagerness!

-   The whole advantage of using DuckDB under the hood is letting DuckDB optimize computations, like dtplyr does with data.table. Therefore, duckplyr needs laziness!

As a consequence, duckplyr is lazy on the inside for all DuckDB operations but eager on the outside, thanks to [ALTREP](https://duckdb.org/2024/04/02/duckplyr.html#eager-vs-lazy-materialization), a powerful R feature that among other things supports **deferred evaluation**.

> ALTREP allows R objects to have different in-memory representations, and for custom code to be executed whenever those objects are accessed.

If the thing accessing the duckplyr data.frame is...

-   not duckplyr, then a special callback is executed, allowing materialization of the data frame.
-   duckplyr, then the operations continue to be lazy (until a call to `collect.duckplyr_df()` for instance).

Therefore, duckplyr can be both lazy (within itself) and not lazy (for the outside world). :zany_face:

Now, the default materialization can be problematic if dealing with large data: what if the materialization eats up all memory? Therefore, the duckplyr package has a safeguard called **prudence** (in the current development version of the package) to control automatic materialization. It has three possible settings:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># default: lavish, automatic materialization</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>mpg2 <span class='o'>=</span> <span class='nv'>mpg</span> <span class='o'>+</span> <span class='m'>2</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 32</span></span>
<span></span><span></span>
<span><span class='c'># frugal, no automatic materialization</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span>prudence <span class='o'>=</span> <span class='s'>"frugal"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>mpg2 <span class='o'>=</span> <span class='nv'>mpg</span> <span class='o'>+</span> <span class='m'>2</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error: Materialization would result in 1 rows, which exceeds the limit of 0. Use collect() or as_tibble() to materialize.</span></span>
<span></span><span></span>
<span><span class='c'># thrifty, automatic materialization up to 1 million cells so ok here</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>duckplyr</span><span class='nf'>::</span><span class='nf'><a href='https://duckplyr.tidyverse.org/reference/duckdb_tibble.html'>as_duckdb_tibble</a></span><span class='o'>(</span>prudence <span class='o'>=</span> <span class='s'>"thrifty"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>mpg2 <span class='o'>=</span> <span class='nv'>mpg</span> <span class='o'>+</span> <span class='m'>2</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 32</span></span>
<span></span></code></pre>

</div>

By default,

-   duckplyr frames created with, say, [`duckplyr::as_duckdb_tibble()`](https://duckplyr.tidyverse.org/reference/duckdb_tibble.html) are "lavish",
-   but duckplyr frames created with ingestion functions such as [`duckplyr::read_parquet_duckdb()`](https://duckplyr.tidyverse.org/reference/read_file_duckdb.html) (presumedly large data) are "thrifty".

## Lazy as in lazy loading of data in packages (`LazyData`)

If your R package exports data, and sets the `LazyData` field in `DESCRIPTION` to `true`, then the exported datasets are lazily loaded: they're available without the use of [`data()`](https://rdrr.io/r/utils/data.html), but they're not actually taking up memory until they are accessed.

There's more details on `LazyData` in the [R packages book by Hadley Wickham and Jenny Bryan](https://r-pkgs.org/data.html#sec-data-data) and in [Writing R Extensions](https://cloud.r-project.org/doc/manuals/r-devel/R-exts.html#Data-in-packages).

Note that internal data is always lazily loaded, and that data that is too big[^1] cannot be lazily loaded.

## Lazy as in frugal file modifications

The [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html) function, that creates a documentation website for an R package, features a [`lazy` argument](https://pkgdown.r-lib.org/reference/build_site.html#arg-lazy). "If `TRUE`, will only rebuild articles and reference pages if the source is newer than the destination."

It is a much simpler concept of laziness: decide right now whether it is needed to rebuild each page.

The potools package, that provides tools for portability and internationalization of R packages, uses ["lazy" for a similar meaning](https://michaelchirico.github.io/potools/reference/po_update.html?q=lazy#ref-usage).

## Lazy as in frugal package testing

The [lazytest package](https://lazytest.cynkra.com/) by Kirill Müller saves you time by only re-running tests that failed during the last run:

-   You run all tests once with `lazytest::lazytest_local()` instead of [`devtools::test()`](https://devtools.r-lib.org/reference/test.html). The lazytest package records which tests failed.
-   The next call to `lazytest::lazytest_local()` only runs the tests that had failed.

This way you can iterate on fixing tests until you get a clean run. At which stage it's probably wise to run all tests again to check you didn't break anything else in the meantime. :wink:

## Lazy as in lazy quantifiers in regular expressions

In regular expressions you can use [quantifiers](https://blog.djnavarro.net/posts/2024-12-16_regex-backreferences/#quantifiers) to indicate how many times a pattern must appear: the pattern can be optional, appear several times, etc. You can also specify whether the tool should match as many repetitions as possible, or the fewest number of repetitions possible.

Matching the fewest number of repetitions possible is "lazy" (or stingy). Matching as many repetitions as possible is "eager" (or greedy).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>string</span> <span class='o'>&lt;-</span> <span class='s'>"aaaaaa"</span></span>
<span><span class='c'># greedy! eager!</span></span>
<span><span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_match.html'>str_match</a></span><span class='o'>(</span><span class='nv'>string</span>, <span class='s'>"a+"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;      [,1]    </span></span>
<span><span class='c'>#&gt; [1,] "aaaaaa"</span></span>
<span></span><span><span class='c'># stingy! lazy!</span></span>
<span><span class='nf'>stringr</span><span class='nf'>::</span><span class='nf'><a href='https://stringr.tidyverse.org/reference/str_match.html'>str_match</a></span><span class='o'>(</span><span class='nv'>string</span>, <span class='s'>"a+?"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;      [,1]</span></span>
<span><span class='c'>#&gt; [1,] "a"</span></span>
<span></span></code></pre>

</div>

## Conclusion

In the context of lazy evaluation and lazy database operations we can think of lazy as a sort of parcimonious procrastination. In the case of frugal file modifications in pkgdown and potools or frugal testing with lazytest, lazy means an informed decision is made on the spot on whether a computation is needed. In the case of lazy quantifiers in regular expressions, lazy means stingy.

Overall, an user can expect "lazy" to mean "less waste", but it is crucial that the documentation of the particular piece of software at hand clarifies the meaning and the potential trade-offs.

[^1]: "those which when serialized exceed 2GB, the limit for the format on 32-bit platforms" at the time of writing, in [Writing R Extensions](https://cloud.r-project.org/doc/manuals/r-devel/R-exts.html#Data-in-packages).

