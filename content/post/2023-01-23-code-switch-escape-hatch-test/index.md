---
slug: code-switch-escape-hatch-test
title: "A testing pattern: adding switches to your code" 
authors: 
- Maëlle Salmon 
date: "2023-01-23" 
tags: 
- package development 
output: hugodown::hugo_document
rmd_hash: b369dc2da323b0f0

---

Sometimes, testing [gets hard](https://r-pkgs.org/testing-advanced.html#when-testing-gets-hard). For instance, you'd like to test for the behavior of your function in the absence of an internet connection, or in an interactive session, without actually cutting off the internet, or from the safety of a definitely non interactive R session for tests. In this post we shall present a not too involved pattern to avoid very complicated infrastructure, as a complement to [mocking](/2019/10/29/mocking/) in your toolbelt.

*Many thanks to [Hugo Gruson](/authors/hugo-gruson/) for very useful feedback on this post, and to [Mark Padgham](https://mpadge.github.io/) for his words of encouragement!*

## The pattern

Say my package code displays a message "No internet! Le sigh" when there's no internet, and I want to test for that message.

First, I create a function called `is_internet_down()`. It could simply call [`curl::has_internet()`](https://rdrr.io/pkg/curl/man/nslookup.html). I will use it from my code.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>is_internet_down</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='o'>!</span><span class='nf'>curl</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/curl/man/nslookup.html'>has_internet</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>my_complicated_code</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='kr'>if</span> <span class='o'>(</span><span class='nf'>is_internet_down</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/message.html'>message</a></span><span class='o'>(</span><span class='s'>"No internet! Le sigh"</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span></span>
<span>  <span class='c'># blablablabla</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Now in tests, I can't catch the message if there is internet.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>test_that</span><span class='o'>(</span><span class='s'>"my_complicated_code() notes the absence of internet"</span>, <span class='o'>&#123;</span></span>
<span>  <span class='nf'>expect_message</span><span class='o'>(</span><span class='nf'>my_complicated_code</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"No internet"</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

This is where I add a switch to my code!

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>is_internet_down</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span></span>
<span>  <span class='kr'>if</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/nchar.html'>nzchar</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/Sys.getenv.html'>Sys.getenv</a></span><span class='o'>(</span><span class='s'>"TESTPKG.NOINTERNET"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='kc'>TRUE</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span></span>
<span></span>
<span>  <span class='o'>!</span><span class='nf'>curl</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/curl/man/nslookup.html'>has_internet</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='nv'>my_complicated_code</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='kr'>if</span> <span class='o'>(</span><span class='nf'>is_internet_down</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/message.html'>message</a></span><span class='o'>(</span><span class='s'>"No internet! Le sigh"</span><span class='o'>)</span></span>
<span>  <span class='o'>&#125;</span></span>
<span>  <span class='c'># blablablabla</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Now, when the environment variable "TESTPKG.NOINTERNET" is set to something, anything, my function `is_internet_down()` will return `TRUE` and my code will show the message. Note that I tried to name the code switch to something readable.

In the tests, I add a call to withr[^1] to set that environment variable for the test only.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>test_that</span><span class='o'>(</span><span class='s'>"my_complicated_code() notes the absence of internet"</span>, <span class='o'>&#123;</span></span>
<span>  <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_envvar.html'>local_envvar</a></span><span class='o'>(</span><span class='s'>"TESTPKG.NOINTERNET"</span> <span class='o'>=</span> <span class='s'>"blop"</span><span class='o'>)</span></span>
<span>  <span class='nf'>expect_message</span><span class='o'>(</span><span class='nf'>my_complicated_code</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"No internet"</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

That's all there is to the pattern. You could use an option and [`withr::local_options()`](https://withr.r-lib.org/reference/with_options.html) instead.

## Use of the pattern in the wild

A popular example of a function with an [escape hatch](https://twitter.com/JennyBryan/status/1613976157501927424) is [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html).

Interactivity/internet connection are two obvious use cases, but you could use the pattern to "mock" many other things.

You could also use it as a complement or alternative to the `transform` argument of [`testthat::expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html), for instance tweaking your code to never show something random when run inside testthat.

## What about mocking instead?

Mocking consists in modifying the behavior of a function *from outside*, replacing it with a mock (`how` in [`mockery::stub()`](https://rdrr.io/pkg/mockery/man/stub.html)) for a given context (`where` [`mockery::stub()`](https://rdrr.io/pkg/mockery/man/stub.html)).

For our previous example we would use:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>mockery</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/mockery/man/stub.html'>stub</a></span><span class='o'>(</span></span>
<span>  where <span class='o'>=</span> <span class='nv'>my_complicated_code</span>,</span>
<span>  what <span class='o'>=</span> <span class='s'>"is_internet_down"</span>, </span>
<span>  how <span class='o'>=</span> <span class='kc'>TRUE</span></span>
<span><span class='o'>)</span></span>
<span><span class='nf'>is_internet_down</span><span class='o'>(</span><span class='o'>)</span></span>[1] FALSE
<span><span class='nf'>my_complicated_code</span><span class='o'>(</span><span class='o'>)</span></span>No internet! Le sigh</code></pre>

</div>

How to choose between escape hatches and mocking? On the one hand, mocking feels tidier as the code does not need to be modified for the tests. On the other hand, mocking can very quickly get cumbersome and hard to reason about (what function has been replaced? where?) -- for you now, for you in a few days, for external collaborators; that could make your codebase harder to work with.

In summary, you can pick whichever strategy you want, but don't be afraid to choose the simpler pattern.

## Conclusion

In this post we presented a solution where, to simplify testing, you add an escape hatch to your code. It might feel a bit like cheating but can sometimes be useful! Do you use this pattern? Do you have other testing "tricks" to report?

[^1]: You can choose to use either the [`withr::with_`](https://withr.r-lib.org/reference/with_.html) or [`withr::local_`](https://withr.r-lib.org/reference/with_.html) functions. Note that the [`withr::with_`](https://withr.r-lib.org/reference/with_.html) functions will take up more space and add more nesting, though.

