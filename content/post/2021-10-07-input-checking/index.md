---
slug: input-checking
title: "Checking the inputs of your R functions" 
authors: 
- Sam Abbott
- Hugo Gruson
- Carl Pearson
- Tim Taylor
date: "2021-10-07" 
tags: 
- package development 
- r-package
output: hugodown::hugo_document
rmd_hash: 292cf2cbf2d52bd0

---

## Introduction: the dangers of not checking function inputs

R functions and R packages are convenient way to share code with the rest of the world. But you never know how others will try to use your code. They might try to use it on objects that your function was not designed for. Let's imagine we have written a short function to compute the geometric mean:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>geometric_mean</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span>
  
  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/prod.html'>prod</a></span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span><span class='o'>^</span><span class='o'>(</span><span class='m'>1</span><span class='o'>/</span><span class='nf'><a href='https://rdrr.io/r/base/dots.html'>...length</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
  
<span class='o'>&#125;</span></code></pre>

</div>

When you tested the function yourself, anything seemed fine:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>geometric_mean</span><span class='o'>(</span><span class='m'>2</span>, <span class='m'>8</span><span class='o'>)</span>
[1] 4

<span class='nf'>geometric_mean</span><span class='o'>(</span><span class='m'>4</span>, <span class='m'>1</span>, <span class='m'>1</span><span class='o'>/</span><span class='m'>32</span><span class='o'>)</span>
[1] 0.5</code></pre>

</div>

But a different person using your function might expose it the situations it was not prepared to handle, resulting in cryptic errors or undefined behaviour:

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

Because of this, you need to make sure you return clear errors whenever your functions receives input it was not designed for. In this blog post, we will review the diversity of approaches to help you check your function inputs.

## Checking function inputs using base R

There is a built-in mechanism to check input values in base R: [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html). You can see it [used](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/stats/R/approx.R#L78) [throughout](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/stats/R/cor.R#L36) [R](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/graphics/R/smoothScatter.R#L47) [source](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/base/R/srcfile.R#L23) [code](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/src/library/base/R/parse.R#L65). As its name suggests, it will *stop* the function execution *if* an object does *not* pass some tests.

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

Because of this, there was an improvement to [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) in R 4.0.0:

> stopifnot() now allows customizing error messages via argument names, thanks to a patch proposal by Neal Fultz in PR\#17688.

This means we can now provide a clearer error message directly in [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) [^1]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>say_hello</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/stopifnot.html'>stopifnot</a></span><span class='o'>(</span><span class='s'>"`name` must be a character."</span> <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>is.character</a></span><span class='o'>(</span><span class='nv'>name</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"Hello"</span>, <span class='nv'>name</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nf'>say_hello</span><span class='o'>(</span><span class='m'>404</span><span class='o'>)</span>
Error in say_hello(404): `name` must be a character.</code></pre>

</div>

But we can this from this example that we could create the error message programmatically based on the contents of the test. Each time we test if the object is of `class_X` and this is not true, we could throw an error saying something like "x must of a class_X". This way, you don't have to repeat yourself [^2]. This becomes necessary when you start having many input checks in your function or in your package.

## Checking function inputs using R packages

### The example of the checkmate package

But although some developers create [their own functions](https://github.com/djnavarro/bs4cards/blob/a021d731a307ec7af692a42364308b60e2bf9827/R/validators.R) to solve this problem, you can also rely on existing packages to make your life easier. One of these packages designed to help you in input checking is [checkmate](https://mllg.github.io/checkmate/). checkmate provides a large number of function to check that function inputs respect a given set of properties, and returns clear error messages when it's not the case:

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

Because input checking is such an important point and so difficult to get right, it is not surprising that there are many packages other than checkmate to solve this issue. We will not get into the details for all of them here but it is worth mentioning:

-   testthat
-   assertthat
-   check
-   assertr
-   assertive
-   ensurer
-   [`vctrs::vec_assert()`](https://vctrs.r-lib.org/reference/vec_assert.html)

## What about the future?

In this post, we have seen many alternatives to check function inputs more easily, and generate more informative error messages. However, this always comes with a performance cost, even though it's often relatively limited. Zero-cost assertions would require some kind of typing system. It is interesting to note that many other languages followed this evolution (TypeScript as an extension of JavaScript, type annotations in Python). [Will R one day follow suit?](https://blog.q-lang.org/posts/2021-10-16-project/)

[^1]: Read [the tidyverse style guide](https://style.tidyverse.org/error-messages.html) for more guidance on how to write good error messages.

[^2]: The [Don't Repeat Yourself (DRY) principle of software development](https://en.wikipedia.org/wiki/Don't_repeat_yourself), also mentioned in this post on [caching](https://blog.r-hub.io/2021/07/30/cache/)

