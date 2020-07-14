---
slug: keep.source 
title: "State of R packages in your library" 
authors: 
- Maëlle Salmon 
date: "2020-07-20" 
tags: 
- package development 
output: hugodown::hugo_document
rmd_hash: 4d155d0804098930

---

Ever wondered where packages go when you run something like [`install.packages()`](https://rdrr.io/r/utils/install.packages.html)? This post is for you!

Where do installed packages live?
---------------------------------

Packages are installed

-   at the path you give as `lib` argument to [`install.packages()`](https://rdrr.io/r/utils/install.packages.html) (or to any `remotes::install_` function, that will pass them on to [`install.packages()`](https://rdrr.io/r/utils/install.packages.html));

-   most often since you won't give any, at the first path returned by [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) that exists and for which the user has the right permissions. There are [several ways to change the paths returned, should you want to do so](https://stackoverflow.com/a/31707983/5489251).[^1]

Now at library loading, the important argument is called `lib.loc`, not `lib`.

{{< tweet 1275366793423523842 >}}

Now how do you know where any of your installed packages was installed? You can use [`find.package()`](https://rdrr.io/r/base/find.package.html) and [`path.package()`](https://rdrr.io/r/base/find.package.html)!

What files are stored locally?
------------------------------

What code format
----------------

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/source.html'>source</a></span>(<span class='s'>"script.R"</span>, keep.source = <span class='kc'>TRUE</span>)
<span class='k'>my_function</span>
<span class='nf'>function</span>() {
  <span class='m'>1</span>
}

<span class='nf'><a href='https://rdrr.io/r/base/source.html'>source</a></span>(<span class='s'>"script.R"</span>, keep.source = <span class='kc'>FALSE</span>)
<span class='k'>my_function</span>
<span class='nf'>function</span> () 
{
    <span class='m'>1</span>
}</code></pre>

</div>

[^1]: Note that if your wish is to isolate packages you are installing for a given project, you might find a better workflow by using Docker or [the `renv` package](https://rstudio.github.io/renv/index.html).

