---
slug: input-checking
title: "Checking the inputs of your R functions" 
authors: 
- Hugo Gruson
- Sam Abbott
- Carl Pearson
date: "2021-10-07" 
tags: 
- package development 
- r-package
output: hugodown::hugo_document
rmd_hash: 5ea789cb694eedce

---

Are you, like we were, tired of filling your functions with argument checking code that sometimes ends up being longer that the core of the function itself? Are you trying to find what is the most efficient approach to check inputs easily and without forgetting any edge cases? Read about our exploration into the various ways to check your function inputs in R in this blog post. And please share your own tips and discoveries in the comment section below!

## Introduction: the dangers of not checking function inputs

R functions and R packages are a convenient way to share code with the rest of the world but it is generally not possible to know how, or with what precise aim in mind, others will use your code. For example, they might try to use it on objects that your function was not designed for. Let's imagine we have written a short function to compute the geometric mean:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>geometric_mean</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span>
  
  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/prod.html'>prod</a></span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span><span class='o'>^</span><span class='o'>(</span><span class='m'>1</span><span class='o'>/</span><span class='nf'><a href='https://rdrr.io/r/base/dots.html'>...length</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
  
<span class='o'>&#125;</span></code></pre>

</div>

When you tested the function yourself, everything seemed fine:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>geometric_mean</span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>8</span><span class='o'>)</span>
[1] 4

<span class='nf'>geometric_mean</span><span class='o'>(</span><span class='m'>4</span>, <span class='m'>1</span>, <span class='m'>1</span><span class='o'>/</span><span class='m'>32</span><span class='o'>)</span>
[1] 0.5</code></pre>

</div>

But a different person using your function might expose it to situations it was not prepared to handle, resulting in cryptic errors or undefined behaviour:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Input with factors instead of numerics</span>
<span class='nf'>geometric_mean</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span>, <span class='m'>8</span><span class='o'>)</span>
Error in Summary.factor(structure(1L, .Label = "2", class = "factor"), : 'prod' not meaningful for factors

<span class='c'># Input with negative values</span>
<span class='nf'>geometric_mean</span><span class='o'>(</span><span class='o'>-</span><span class='m'>1</span>, <span class='m'>5</span><span class='o'>)</span>
[1] NaN

<span class='c'># Input with NAs</span>
<span class='nf'>geometric_mean</span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>8</span>, <span class='kc'>NA</span><span class='o'>)</span>
[1] NA</code></pre>

</div>

Or worse, it could give an incorrect output:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>geometric_mean</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>8</span><span class='o'>)</span><span class='o'>)</span>
[1] 16</code></pre>

</div>

Because of this, you need to make sure you return clear errors whenever your functions receives input it was not designed for. In this blog post, we review a range of approaches to help you check your function inputs and discuss some potential future developments.

## Pre-requisite: thoroughly document your argument types

You can notice from the simple example above that it's easy to pass invalid inputs to the `geometric_mean()` function because we didn't provide any documentation on what is or isn't a valid input. We won't go into details here but the [roxygen2](https://roxygen2.r-lib.org/) package provides a convenient way to generate documentation for R functions. Try to be as precise as possible when describing the required format for your inputs [^1].

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#' @param name A character of length one with the name of the person to greet</span>
<span class='nv'>say_hello</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/stopifnot.html'>stopifnot</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/character.html'>is.character</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"Hello"</span>, <span class='nv'>name</span><span class='o'>)</span>
<span class='o'>&#125;</span></code></pre>

</div>

Adding any kind of argument checking in the absence of good documentation would be vain and very frustrating for your users as they would have to figure out what is or isn't valid by trial and error.

## Checking function inputs using base R

### `match.arg()`

If the input can only take specific values, the base function [`match.arg()`](https://rdrr.io/r/base/match.arg.html) can also prove useful:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/match.arg.html'>match.arg</a></span><span class='o'>(</span>arg <span class='o'>=</span> <span class='s'>"R"</span>, choices <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"R"</span>, <span class='s'>"python"</span><span class='o'>)</span><span class='o'>)</span>
[1] "R"

<span class='nf'><a href='https://rdrr.io/r/base/match.arg.html'>match.arg</a></span><span class='o'>(</span>arg <span class='o'>=</span> <span class='s'>"javascript"</span>, choices <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"R"</span>, <span class='s'>"python"</span><span class='o'>)</span><span class='o'>)</span>
Error in match.arg(arg = "javascript", choices = c("R", "python")): 'arg' should be one of "R", "python"</code></pre>

</div>

But the real power of the [`match.arg()`](https://rdrr.io/r/base/match.arg.html) function comes from the fact that `choices` can be automatically obtained in the context of a function. The default choice is then always the first element:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>choose_language</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>language</span> <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"R"</span>, <span class='s'>"python"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
  
  <span class='c'># Equivalent to `match.arg(language, c("R", "python"))</span>
  <span class='nv'>language</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/match.arg.html'>match.arg</a></span><span class='o'>(</span><span class='nv'>language</span><span class='o'>)</span>
  
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"I love"</span>, <span class='nv'>language</span><span class='o'>)</span>
  
<span class='o'>&#125;</span>

<span class='nf'>choose_language</span><span class='o'>(</span><span class='s'>"R"</span><span class='o'>)</span>
[1] "I love R"

<span class='nf'>choose_language</span><span class='o'>(</span><span class='o'>)</span>
[1] "I love R"

<span class='nf'>choose_language</span><span class='o'>(</span><span class='s'>"julia"</span><span class='o'>)</span>
Error in match.arg(language): 'arg' should be one of "R", "python"</code></pre>

</div>

We are getting out of the realm of base R but it is worth mentioning that [`match.arg()`](https://rdrr.io/r/base/match.arg.html) has an equivalent in the tidyverse with a more consistent design and coloured output: [`rlang::arg_match()`](https://rlang.r-lib.org/reference/arg_match.html).

### `stopifnot()`

There is a another, more general, built-in mechanism to check input values in base R: [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html). You can see it [used](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/stats/R/approx.R#L78) [throughout](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/stats/R/cor.R#L36) [R](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/graphics/R/smoothScatter.R#L47) [source](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/base/R/srcfile.R#L23) [code](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/base/R/parse.R#L65). As its name suggests, it will *stop* the function execution *if* an object does *not* pass some tests.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>say_hello</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/stopifnot.html'>stopifnot</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/character.html'>is.character</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"Hello"</span>, <span class='nv'>name</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nf'>say_hello</span><span class='o'>(</span><span class='s'>"Bob"</span><span class='o'>)</span>
[1] "Hello Bob"
<span class='nf'>say_hello</span><span class='o'>(</span><span class='m'>404</span><span class='o'>)</span>
Error in say_hello(404): is.character(name) is not TRUE</code></pre>

</div>

However, as you can see in this example, the error message is not in plain English but contains some code instructions. This can hinder understanding of the issue.

Because of this, [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) was improved in R 4.0.0:

> stopifnot() now allows customizing error messages via argument names, thanks to a patch proposal by Neal Fultz in PR#17688.

This means we can now provide a clearer error message directly in [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) [^2]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>say_hello</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/stopifnot.html'>stopifnot</a></span><span class='o'>(</span><span class='s'>"`name` must be a character."</span> <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>is.character</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"Hello"</span>, <span class='nv'>name</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nf'>say_hello</span><span class='o'>(</span><span class='m'>404</span><span class='o'>)</span>
Error in say_hello(404): `name` must be a character.</code></pre>

</div>

This is clearly a really great improvement to the functionality of base R. However, we can see from this example that we could create the error message programmatically based on the contents of the test. Each time we test if the object is of `class_X` and this is not true, we could throw an error saying something like "x must of a class_X". This way, you don't have to repeat yourself which is generally a good aim [^3]. This becomes necessary when you start having many input checks in your function or in your package.

## Checking function inputs using R packages

### The example of the checkmate package

Although some developers create [their own functions](https://github.com/djnavarro/bs4cards/blob/a021d731a307ec7af692a42364308b60e2bf9827/R/validators.R) to solve this problem [^4], you can also rely on existing packages to make your life easier. One of these packages designed to help you in input checking is [checkmate](https://mllg.github.io/checkmate/). checkmate provides a large number of functions that check that inputs respect a given set of properties, and that return clear error messages when that is not the case:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>say_hello</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='c'># Among other things, check_string() checks that we provide a </span>
  <span class='c'># character object of length one</span>
  <span class='nf'>checkmate</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/checkmate/man/checkString.html'>assert_string</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"Hello"</span>, <span class='nv'>name</span><span class='o'>)</span>
<span class='o'>&#125;</span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>say_hello</span><span class='o'>(</span><span class='m'>404</span><span class='o'>)</span>
Error in say_hello(404): Assertion on 'name' failed: Must be of type 'string', not 'double'.</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>say_hello</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Bob"</span>, <span class='s'>"Alice"</span><span class='o'>)</span><span class='o'>)</span>
Error in say_hello(c("Bob", "Alice")): Assertion on 'name' failed: Must have length 1.</code></pre>

</div>

### Other packages to check function inputs

Because input checking is such an important point task and because it is so difficult to get right, it is not surprising that there are many packages other than checkmate to solve this issue. We will not get into the details of all of the available options here but below is a list of some of them, listed by decreasing number of reverse dependencies. If interested in understanding the various approaches to input taking the documentation for these package is a great place to start.

-   [assertthat](https://github.com/hadley/assertthat)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>assertthat</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/assertthat/man/assert_that.html'>assert_that</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/character.html'>is.character</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
Error: 1 is not a character vector</code></pre>

</div>

-   [assertr](https://docs.ropensci.org/assertr/)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://magrittr.tidyverse.org'>magrittr</a></span><span class='o'>)</span>

<span class='nv'>mtcars</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'>assertr</span><span class='nf'>::</span><span class='nf'><a href='https://docs.ropensci.org/assertr/reference/verify.html'>verify</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>.</span><span class='o'>)</span> <span class='o'>&lt;</span> <span class='m'>10</span><span class='o'>)</span>
verification [nrow(.) < 10] failed! (1 failure)

    verb redux_fn    predicate column index value
1 verify       NA nrow(.) < 10     NA     1    NA
Error: assertr stopped execution</code></pre>

</div>

-   [assertive](https://bitbucket.org/richierocks/assertive)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>assertive</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/assertive/man/is_character.html'>assert_is_a_string</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>
Error in eval(expr, envir, enclos): is_a_string : 1 is not of class 'character'; it has class 'numeric'.</code></pre>

</div>

-   [ensurer](https://github.com/smbache/ensurer)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>ensure_square</span> <span class='o'>&lt;-</span> <span class='nf'>ensurer</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/ensurer/man/ensures_that.html'>ensures_that</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>NCOL</a></span><span class='o'>(</span><span class='nv'>.</span><span class='o'>)</span> <span class='o'>==</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>NROW</a></span><span class='o'>(</span><span class='nv'>.</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'>ensure_square</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/matrix.html'>matrix</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>20</span>, <span class='m'>4</span>, <span class='m'>5</span><span class='o'>)</span><span class='o'>)</span>
Error: conditions failed for call 'rmarkdown::render(" .. ecking/index.Rmd", ':
     * NCOL(.) == NROW(.)</code></pre>

</div>

-   [vetr](https://github.com/brodieG/vetr)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>template</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>numeric</a></span><span class='o'>(</span><span class='m'>1L</span><span class='o'>)</span>

<span class='nf'>vetr</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/vetr/man/vet.html'>vet</a></span><span class='o'>(</span><span class='nv'>template</span>, <span class='m'>42</span><span class='o'>)</span>
[1] TRUE

<span class='nf'>vetr</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/vetr/man/vet.html'>vet</a></span><span class='o'>(</span><span class='nv'>template</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span>
[1] "`length(1:3)` should be 1 (is 3)"

<span class='nf'>vetr</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/vetr/man/vet.html'>vet</a></span><span class='o'>(</span><span class='nv'>template</span>, <span class='s'>"hello"</span><span class='o'>)</span>
[1] "`\"hello\"` should be type \"numeric\" (is \"character\")"</code></pre>

</div>

-   [`vctrs::vec_assert()`](https://vctrs.r-lib.org/reference/vec_assert.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>vctrs</span><span class='nf'>::</span><span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_assert.html'>vec_assert</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span><span class='o'>)</span>, <span class='s'>"character"</span><span class='o'>)</span>
Error in `vctrs::vec_assert()`:
! `c(1, 2)` must be a vector with type <character>.
Instead, it has type <double>.

<span class='nf'>vctrs</span><span class='nf'>::</span><span class='nf'><a href='https://vctrs.r-lib.org/reference/vec_assert.html'>vec_assert</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span><span class='o'>)</span>, size <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>
Error in `stop_vctrs()`:
! `c(1, 2)` must have size 3, not size 2.</code></pre>

</div>

-   [check](https://github.com/moodymudskipper/check) is slightly different because it doesn't provide utilities that work out of the box, but rather tools to assist you in writing your own checking functions

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/moodymudskipper/check'>check</a></span><span class='o'>)</span>

<span class='nf'>check</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/check/man/setup.html'>setup</a></span><span class='o'>(</span><span class='o'>)</span> 

<span class='nf'><a href='https://rdrr.io/pkg/check/man/set_check_fun.html'>set_check_fun</a></span><span class='o'>(</span>
  <span class='s'>"`&#123;var&#125;` must be a &#123;type&#125; vector of length &#123;length&#125;."</span> <span class='o'>=</span> <span class='o'>&#123;</span>
      <span class='nv'>val</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/get.html'>get</a></span><span class='o'>(</span><span class='nv'>var</span>, <span class='nv'>env</span><span class='o'>)</span>
      <span class='nf'><a href='https://rdrr.io/r/base/is.recursive.html'>is.atomic</a></span><span class='o'>(</span><span class='nv'>val</span><span class='o'>)</span> <span class='o'>&amp;&amp;</span> <span class='nf'>is</span><span class='o'>(</span><span class='nv'>val</span>, <span class='nv'>type</span><span class='o'>)</span> <span class='o'>&amp;&amp;</span> <span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>val</span><span class='o'>)</span> <span class='o'>==</span> <span class='nv'>length</span>
  <span class='o'>&#125;</span>
<span class='o'>)</span>

<span class='nv'>say_hello</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/pkg/check/man/check.html'>check</a></span><span class='o'>(</span>
    <span class='s'>"`name` must be a character vector of length 1."</span>
    <span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"hello"</span>, <span class='nv'>name</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nf'>say_hello</span><span class='o'>(</span><span class='s'>"Maria"</span><span class='o'>)</span>
[1] "hello Maria"

<span class='nf'>say_hello</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"Maria"</span>, <span class='s'>"Noelia"</span><span class='o'>)</span><span class='o'>)</span>
Error: `name` must be a character vector of length 1.</code></pre>

</div>

## There is no 'one-size-fits-all'

We have presented here different approaches but it is up to you, the developer, to decide which approach suits your needs best. We do not believe that one choice is intrinsically better than the others. All the workflows presented here can achieve the same result. Your choice may be influenced by several factors we cannot take into consideration here: who is your target audience? Will they be okay with somewhat technical terminology in the error messages? Do you have reasons to try and limit the number of dependencies [^5]? Which framework are you the more comfortable with and will facilitate maintenance in the future? And ultimately, what is your personal preference?

If you would like to hear various point of views and a more in-depth discussion about this, please refer to the [pull request related to this post](https://github.com/r-hub/blog/pull/150).

## What about the future?

In this post, we have discussed some methods to check function inputs, and to generate more informative error messages when doing so. However, this always comes with a performance cost, even though it's often relatively limited. Zero-cost assertions, as found in some other languages, would require some kind of typing system which R does not currently support. Interestingly several other languages have evolved to have typing systems as they have developed. Typescript developed as an extension of JavaScript, and type annotations are now possible in Python. [Will R one day follow suit?](https://blog.q-lang.org/posts/2021-10-16-project/)

[^1]: [Some package developers even developed their own standardized way to document argument types and length](https://github.com/r-lib/withr/commit/42e503092046705f30032cb3a321d64b0e9383d4). But there is currently no standard shared across the R community.

[^2]: Read [the tidyverse style guide](https://style.tidyverse.org/error-messages.html) for more guidance on how to write good error messages.

[^3]: The [Don't Repeat Yourself (DRY) principle of software development](https://en.wikipedia.org/wiki/Don't_repeat_yourself), also mentioned in this post on [caching](https://blog.r-hub.io/2021/07/30/cache/)

[^4]: See [this earlier blog post](https://blog.r-hub.io/2019/12/12/internal-functions/) for more information about why and who you would go with writing internal functions.

[^5]: This is a complex discussion often caricatured, but that has already been treated on some occasions such as [this blog post from Jim Hester](https://www.tidyverse.org/blog/2019/05/itdepends/).

