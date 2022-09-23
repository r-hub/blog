---
slug: r-dependency
title: "Minimum R version dependency in R packages" 
authors: 
- Hugo Gruson
- Maëlle Salmon
date: "2022-09-12" 
tags: 
- package development 
- r-package
output: hugodown::hugo_document
rmd_hash: 24a86af71fb35669

---

There have been much talk and [many blog posts about R package dependencies](https://www.tidyverse.org/blog/2019/05/itdepends/). Yet, one special dependency is more rarely mentioned, even though all packages include it: the dependency on R itself. The same way you can specify a dependency on a package, and optionally on a specific version, you can add a dependency to a minimum R version in the `DESCRIPTION` file of your package. In this post we shall explain why and how.

# How & why to declare a dependency to a minimum R version?

Although the R project is in a stable state, and prides itself in its solid backward compatibility, it is far from being a dead project. Many exciting new features keep being regularly added to R or some of its base libraries. As a package developer, [you may want to use one of these newly added features (such as `startsWith()`, introduced in R 3.3.0)](https://github.com/yihui/knitr/issues/2100).

In this situation, you should inform users ([as well as automated checks from CRAN](https://www.mail-archive.com/r-package-devel@r-project.org/msg06331.html)) that your package only works for R versions more recent than a given number [^1].

To do so, you should add the required version number to your `DESCRIPTION` file [^2]:

``` yaml
  Depends:
    R (>= 3.5.0)
```

# Which minimum R version your package should depend on?

There are different strategies to choose on which R version your package should depend:

## Conservative approach

Some projects prefer to limit the minimum R version by design, rather than by necessity. This means that their packages *might* work with older R versions, but because they don't or can't test it, they'd rather not take the risk and limit themselves to versions for which they are sure the package is working:

-   this used to be the policy of usethis before 2017 (and therefore, of all packages built with usethis at that time). [In the past, usethis added by default a dependency to the R version used by the developer at the time they created the package](https://github.com/r-lib/usethis/commit/7937594cb4a6adc9f1783839c4ccdd2cdcffaaae).

-   this is the [strategy used by the tidyverse](https://www.tidyverse.org/blog/2019/04/r-version-support/), which explicitly decided to guarantee compatibility with the 5 latest R minor releases, but no further. With the current R release cycle, this corresponds to compatibility with R versions up to 5 years old.

## 'Wide net' approach

On the opposite, other projects consider that packages are by default compatible with all R versions, until they explicitly add a feature associated with a new R version, or until tests prove it otherwise. This is the new policy of usethis (and therefore, of all packages built this usethis). By default, new packages don't have any constraints on the R version. It is the responsibility of the developer to add a minimum required version if necessary.

## Transitive approach

Another approach is to look at your package dependencies. If indirectly, via one of its recursive dependencies, your package already depend on a recent R version, there is no point in going the extra mile to keep working with older versions. So, a strategy could be to compute your package transitive minimum R version with the following function and decide that you can use base R features up to this version:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>find_transitive_minR</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>package</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  </span>
<span>  <span class='nv'>db</span> <span class='o'>&lt;-</span> <span class='nf'>tools</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/tools/CRANtools.html'>CRAN_package_db</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='nv'>recursive_deps</span> <span class='o'>&lt;-</span> <span class='nf'>tools</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/tools/package_dependencies.html'>package_dependencies</a></span><span class='o'>(</span></span>
<span>    <span class='nv'>package</span>, </span>
<span>    recursive <span class='o'>=</span> <span class='kc'>TRUE</span>, </span>
<span>    db <span class='o'>=</span> <span class='nv'>db</span></span>
<span>  <span class='o'>)</span><span class='o'>[[</span><span class='m'>1</span><span class='o'>]</span><span class='o'>]</span></span>
<span>  </span>
<span>  <span class='c'># These code chunks are detailed below in the 'Minimum R dependencies in CRAN </span></span>
<span>  <span class='c'># packages' section</span></span>
<span>  <span class='nv'>r_deps</span> <span class='o'>&lt;-</span> <span class='nv'>db</span> <span class='o'>|&gt;</span> </span>
<span>    <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>Package</span> <span class='o'><a href='https://rdrr.io/r/base/match.html'>%in%</a></span> <span class='nv'>recursive_deps</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>    <span class='c'># We exclude recommended pkgs as they're always shown as depending on R-devel</span></span>
<span>    <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>Priority</span><span class='o'>)</span> <span class='o'>|</span> <span class='nv'>Priority</span> <span class='o'>!=</span> <span class='s'>"recommended"</span><span class='o'>)</span> <span class='o'>|&gt;</span>  </span>
<span>    <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pull.html'>pull</a></span><span class='o'>(</span><span class='nv'>Depends</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/strsplit.html'>strsplit</a></span><span class='o'>(</span>split <span class='o'>=</span> <span class='s'>","</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>    <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>grep</a></span><span class='o'>(</span><span class='s'>"^R "</span>, <span class='nv'>.x</span>, value <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>    <span class='nf'><a href='https://rdrr.io/r/base/unlist.html'>unlist</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='nv'>r_vers</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/trimws.html'>trimws</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/grep.html'>gsub</a></span><span class='o'>(</span><span class='s'>"^R \\(&gt;=?\\s(.+)\\)"</span>, <span class='s'>"\\1"</span>, <span class='nv'>r_deps</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>max</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/numeric_version.html'>package_version</a></span><span class='o'>(</span><span class='nv'>r_vers</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

Let's try this on ggplot2, which depends on R \>= 3.3

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>find_transitive_minR</span><span class='o'>(</span><span class='s'>"ggplot2"</span><span class='o'>)</span></span>[1] '3.4'</code></pre>

</div>

This means that ggplot2 developers could, at no cost, start using features from R 3.4.

However, you should take this as a guideline but not add a transitive minimum R version as the minimum R version of your package unless you add a feature specific to this version. It is important that the minimum R version you state in your package reflects the version required for the code in your package, not in one of its dependencies.

## Which approach should you choose?

There is no intrinsically better choice between these approaches. It is more a matter of world-view and relation of the project with the users.

However, you should always keep in mind that [it may be difficult for users to install or update any piece of software](https://twitter.com/jimhester_/status/1350424047893557253) and you should not force them to upgrade to very recent R versions. A good philosophy is to consider that users cannot upgrade their R version and that you should bump the required R version only when you are sure that all active users are already using this R version or a newer one.

## Minimum R dependencies in CRAN packages

Whenever you are unsure about a completely subjective choice for a R package, or any project in general, it is often good practice to look at what is done in your community.

Let's start by grabbing a snapshot of the current CRAN archive:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>db</span> <span class='o'>&lt;-</span> <span class='nf'>tools</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/tools/CRANtools.html'>CRAN_package_db</a></span><span class='o'>(</span><span class='o'>)</span></span></code></pre>

</div>

We can then isolate the R version dependency declaration:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>r_deps</span> <span class='o'>&lt;-</span> <span class='nv'>db</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='c'># We exclude recommended pkgs as they're always shown as depending on R-devel</span></span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>Priority</span><span class='o'>)</span> <span class='o'>|</span> <span class='nv'>Priority</span> <span class='o'>!=</span> <span class='s'>"recommended"</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/pull.html'>pull</a></span><span class='o'>(</span><span class='nv'>Depends</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/strsplit.html'>strsplit</a></span><span class='o'>(</span>split <span class='o'>=</span> <span class='s'>","</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>purrr</span><span class='nf'>::</span><span class='nf'><a href='https://purrr.tidyverse.org/reference/map.html'>map</a></span><span class='o'>(</span><span class='o'>~</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>grep</a></span><span class='o'>(</span><span class='s'>"^R "</span>, <span class='nv'>.x</span>, value <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/unlist.html'>unlist</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>r_deps</span><span class='o'>)</span></span>[1] 11542
<span><span class='nf'><a href='https://rdrr.io/r/utils/head.html'>tail</a></span><span class='o'>(</span><span class='nv'>r_deps</span><span class='o'>)</span></span>[1] "R (>= 3.5)"    "R (>= 3.1.0)"  "R (>= 2.4.0)"  "R (>= 3.2)"   
[5] "R (>= 3.0.0)"  "R (>= 2.13.0)"</code></pre>

</div>

A first result of our analysis if that 62% of CRAN packages specify a minimum R version.

As mentioned earlier, the minimum required version can be specified with a loose or strict inequality:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='o'>(</span><span class='nv'>r_deps_strict</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/grep.html'>grepl</a></span><span class='o'>(</span><span class='s'>"^R \\(&gt;\\s(.+)\\)"</span>, <span class='nv'>r_deps</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>[1] 10
<span><span class='o'>(</span><span class='nv'>r_deps_loose</span>  <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/grep.html'>grepl</a></span><span class='o'>(</span><span class='s'>"^R \\(&gt;=\\s(.+)\\)"</span>, <span class='nv'>r_deps</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>[1] 11532</code></pre>

</div>

You can see that using a strict inequality is indeed very uncommon (0.09% of the cases).

We can now continue our analysis and extract the version number itself:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>r_deps_ver</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/trimws.html'>trimws</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/grep.html'>gsub</a></span><span class='o'>(</span><span class='s'>"^R \\(&gt;=?\\s(.+)\\)"</span>, <span class='s'>"\\1"</span>, <span class='nv'>r_deps</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>r_deps_ver</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/table.html'>table</a></span><span class='o'>(</span><span class='o'>)</span></span>r_deps_ver
       0.65        0.99         1.1      1.14.0         1.4       1.4.0 
          1           2           1           1           7           2 
      1.4.1       1.5.0       1.6.0       1.6.1       1.6.2         1.7 
          1           6           1           1           1           1 
      1.7.0       1.8.0       1.9.0       1.9.1         2.0       2.0.0 
          3          31          11           1          18          59 
      2.0.1        2.01         2.1       2.1.0       2.1.1      2.1.14 
         13           9           2          16           4           1 
      2.1.4       2.1.5        2.10      2.10.0      2.10.1        2.11 
          1           1        1578         136          22           1 
     2.11.0      2.11.1        2.12      2.12.0      2.12.1        2.13 
         13          10           6          45           1           8 
     2.13.0      2.13.1      2.13.2        2.14      2.14.0      2.14.1 
         37           4           1          38         105          22 
     2.14.2        2.15      2.15.0      2.15.1      2.15.2      2.15.3 
         13          47          87          60           9           9 
       2.16         2.2       2.2.0       2.2.1       2.2.4        2.20 
          1           2          23           9           1           1 
        2.3       2.3.0       2.3.1      2.3.12       2.3.2         2.4 
          2          13           3           1           1           4 
      2.4.0       2.4.1         2.5       2.5.0       2.5.1       2.5.3 
         24           2           3          30           1           1 
       2.50         2.6       2.6.0       2.6.1       2.6.2         2.7 
          2           9          40           3           2           5 
      2.7.0       2.7.2         2.8       2.8.0       2.8.1         2.9 
         27           1           1          23           2           2 
      2.9.0       2.9.1       2.9.2         3.0       3.0-0       3.0-2 
         28           4           3         236           4           1 
      3.0.0       3.0.1       3.0.2       3.0.3       3.0.4        3.00 
        750          94         231          33           1          19 
     3.00.0         3.1       3.1-0       3.1.0       3.1.1       3.1.2 
          1         182           2         583          97         144 
      3.1.3        3.10      3.10.0         3.2       3.2.0       3.2.1 
         33           2           1         134         397          50 
      3.2.2       3.2.3       3.2.4       3.2.5       3.2.6         3.3 
         95         110          27          29           1         141 
      3.3.0       3.3.1       3.3.2       3.3.3         3.4       3.4.0 
        461          63          39          23         181         566 
      3.4.1       3.4.2       3.4.3       3.4.4         3.5       3.5-0 
         12           5           2           9         339           1 
      3.5.0 3.5.0-4.0.2      3.5.00       3.5.1     3.5.1.0       3.5.2 
       2207           1           1           5           1           2 
      3.5.3        3.50         3.6       3.6.0       3.6.2       3.6.3 
          3           7         191         485           3           3 
       3.60       3.7.0         4.0       4.0.0       4.0.3       4.0.4 
          1           1         194         375           1           1 
      4.0.5        4.00         4.1       4.1-0       4.1.0         4.2 
          1           3          54           1         142           8 
      4.2.0 
         31 </code></pre>

</div>

Interestingly, you can notice that some of these version numbers don't match any actual R release. To confirm this, we can use the [rversions package, from R-hub](/2019/04/15/rversions-1-1-0/):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/sets.html'>setdiff</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/unique.html'>unique</a></span><span class='o'>(</span><span class='nv'>r_deps_ver</span><span class='o'>)</span>, <span class='nf'>rversions</span><span class='nf'>::</span><span class='nf'><a href='https://r-hub.github.io/rversions/reference/r_versions.html'>r_versions</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>version</span><span class='o'>)</span></span> [1] "2.10"        "3.0"         "3.6"         "3.5"         "3.4"        
 [6] "3.2"         "3.00"        "4.1"         "2.14"        "3.1"        
[11] "4.0"         "3.3"         "2.13"        "2.3.2"       "3.1-0"      
[16] "2.0"         "2.5"         "2.15"        "4.00"        "3.0-0"      
[21] "1.7"         "2.7"         "2.01"        "2.6"         "2.20"       
[26] "2.2"         "2.2.4"       "3.50"        "4.2"         "3.10.0"     
[31] "2.11"        "2.9"         "3.7.0"       "3.10"        "2.3"        
[36] "1.4.0"       "2.5.3"       "3.60"        "2.50"        "2.1.4"      
[41] "2.4"         "3.0.4"       "2.1"         "2.12"        "3.5.0-4.0.2"
[46] "3.5.1.0"     "2.8"         "3.00.0"      "2.3.12"      "4.1-0"      
[51] "2.16"        "1.14.0"      "2.1.14"      "3.5-0"       "3.5.00"     
[56] "3.0-2"       "2.1.5"       "3.2.6"      </code></pre>

</div>

We can infer the reason for the mismatch for some examples in this list:

-   missing `.` between version components (for instance `2.01`, `2.50`, `3.00`, `3.60`, `4.00`)
-   `.` replaced by `-` in the patch version number (for instance `3.0-0`, `3.0-2`, `3.1-0`, `3.5-0`, `4.1-0`) [^3].
-   missing patch version number (for instance `2.0`, `2.2`, `4.3`)
-   extra patch version number (for instance `1.4.0`)
-   recommended packages depend on a yet-to-be-released R version (`4.3`)

Note that this values are not syntactically wrong, and it might in some cases be intended by the author. They can be read and understood by the relevant function in base R (in particular, [`install.packages()`](https://rdrr.io/r/utils/install.packages.html)), but it is possible they do not correspond to what the package author was expecting, or trying to communicate. For example, in the case of `R (=> 3.60)`: even if the author really intended to depend on `R 3.6.0` as we assume here, the package cannot be installed in versions earlier than 4.0.0.

To visualise the actual minimum R version corresponding to the declared R dependency, we can do the following:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>r_vers</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/numeric_version.html'>package_version</a></span><span class='o'>(</span><span class='nf'>rversions</span><span class='nf'>::</span><span class='nf'><a href='https://r-hub.github.io/rversions/reference/r_versions.html'>r_versions</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>$</span><span class='nv'>version</span><span class='o'>)</span></span>
<span></span>
<span><span class='nv'>normalised_r_deps</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>r_deps_ver</span>, <span class='kr'>function</span><span class='o'>(</span><span class='nv'>ver</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  </span>
<span>  <span class='nv'>ver</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/numeric_version.html'>package_version</a></span><span class='o'>(</span><span class='nv'>ver</span><span class='o'>)</span></span>
<span>  </span>
<span>  <span class='c'># Here, we rely on a somewhat uncommon use of `match()`. When `match()`ing</span></span>
<span>  <span class='c'># `TRUE` to something, the index of the first `TRUE` value will be returned.</span></span>
<span>  <span class='c'># In other words here, we return the first R version that it superior or equal</span></span>
<span>  <span class='c'># to the stated R version dependency</span></span>
<span>  <span class='nv'>min_r_ver</span> <span class='o'>&lt;-</span> <span class='nv'>r_vers</span><span class='o'>[</span><span class='nf'><a href='https://rdrr.io/r/base/match.html'>match</a></span><span class='o'>(</span><span class='kc'>TRUE</span>, <span class='nv'>ver</span> <span class='o'>&lt;=</span> <span class='nv'>r_vers</span><span class='o'>)</span><span class='o'>]</span></span>
<span>  </span>
<span>  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nv'>min_r_ver</span><span class='o'>)</span></span>
<span>  </span>
<span><span class='o'>&#125;</span>, <span class='nf'><a href='https://rdrr.io/r/base/numeric_version.html'>package_version</a></span><span class='o'>(</span><span class='s'>"0.0.0"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/do.call.html'>do.call</a></span><span class='o'>(</span><span class='nv'>rbind</span>, <span class='nv'>normalised_r_deps</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/as.data.frame.html'>as.data.frame</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/rename.html'>rename</a></span><span class='o'>(</span></span>
<span>    major <span class='o'>=</span> <span class='nv'>V1</span>,</span>
<span>    minor <span class='o'>=</span> <span class='nv'>V2</span>,</span>
<span>    patch <span class='o'>=</span> <span class='nv'>V3</span></span>
<span>  <span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>majorminor <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nv'>major</span>, <span class='nv'>minor</span>, sep <span class='o'>=</span> <span class='s'>"."</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> </span>
<span>  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>y <span class='o'>=</span> <span class='nv'>majorminor</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_bar</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span></span>
<span>      x <span class='o'>=</span> <span class='s'>"Number of CRAN packages"</span>,</span>
<span>      y <span class='o'>=</span> <span class='s'>"Minimum required R version"</span>,</span>
<span>      title <span class='o'>=</span> <span class='s'>"Minimum required R version in CRAN packages"</span></span>
<span>    <span class='o'>)</span> <span class='o'>+</span></span>
<span>    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggtheme.html'>theme_minimal</a></span><span class='o'>(</span><span class='o'>)</span></span>{{<figure src="cran-r-version-plot-1.png" >}}</code></pre>

</div>

The peak at R 2.10 might be related to the fact that [it is automatically added when developers embed data in their packages with `usethis::use_date()`](https://github.com/r-lib/usethis/issues/631). You can also notice at peak at R 3.5.0. It is possible that this is linked to [the change in the serialization format used by R](https://github.com/wch/r-source/blob/79298c499218846d14500255efd622b5021c10ec/doc/NEWS.3#L1540-L1550). Data objects embedded in packages developed with R \>= 3.5.0 are by default only compatible with R \>= 3.5.0. However, these are nothing more than educated guesses and only a proper, in-depth, analysis could confirm what made developers switch to a newer R version. This analysis could look at diffs between package versions and see what new R feature packages are using when they bump the R version dependency.

# How to avoid depending on a new version?

For the various reasons presented above, it might not always be desirable to depend on a very recent R version. In this kind of situation, you may want to use the [backports package](https://github.com/r-lib/backports). It reimplements many of the new features from the more recent R version. This way, instead of having to depend on a newer R version, you can simply add a dependency to backports, which is easier to install than a newer R version for users in highly controlled environments.

Backports is not a silver bullet though, as some new features are impossible to reimplement in a package. Notably, this is the case of the native R pipe (`|>`), introduced in R 4.1.0. Roughly speaking, this is because it is not simply a new function, but rather an entire new way to read R code.

# How to test you depend on the correct version?

[It is easy to make a mistake when specifying a minimum R version, and to forget to you use one recent R feature](https://stat.ethz.ch/pipermail/r-package-devel/2021q1/006508.html). For this reason, you should always try to verify that your minimum R version claim is accurate.

The most complete approach is to run your tests, or at least verify that the package can be built without errors, on all older R versions you claim to support. For this, locally, you could use [rig](https://github.com/r-lib/rig), which allows you to install multiple R version on your computer and switch between them with a single command. But a convenient way to do so is to rely on continuous integration platforms, where existing workflows are already set up to run on multiple R versions. For example, if you choose to replicate the tidyverse policy of supporting the 5 latest minor releases of R, your best bet is probably to use [the `check-full.yaml` GitHub Actions workflow](https://github.com/r-lib/actions/blob/v2/examples/check-full.yaml) from [`r-lib/actions`](https://github.com/r-lib/actions/) [^4].

But this extensive test may prove challenging in some cases. In particular, the actions provided by [`r-lib.actions`](https://github.com/r-lib/actions) use [rcmdcheck](https://r-lib.github.io/rcmdcheck/), which itself depends on R 3.3 (via digest). This means that you'll have to write your own workflows if you wish to run `R CMD check` on older R versions. Some packages that place a high value in being compatible with older R versions, such as data.table, have taken this route and developed [their own continuous integration scripts](https://github.com/Rdatatable/data.table/tree/71c7e6d/.ci).

A more lightweight approach (although a little more prone to false-negatives) is to use the [`backport_linter()` function provided by the lintr package](https://lintr.r-lib.org/reference/backport_linter.html). It works by matching your code against a list of functions introduced in more recent R versions. Note that this approach might also produce false positives is you use functions with the same name as recent base R functions.

# Conclusion

As you've seen, there are quite a lot of strategies and subtleties in setting a minimum R dependency for your package: you could adopt the tidyverse approach of supporting the five last R versions, or choose to keep compatibility with older R versions and using backports if necessary. In all cases, you should try to verify that your declared minimum R version is correct: by using the dedicated linter from the lintr package, or by actually running your tests on older R versions. Whatever you end up doing and even if this topic may seem complex, we believe the tips we presented here are specific cases of more software development tips:

-   use automated tools to assist you in your work;
-   try to empathize with your users and minimize the friction necessary to install and use your tool;
-   look at what other developers in the community are doing.

[^1]: Note that there is no mechanism to make your package compatible only with older R versions, and not with the more recent ones. Packages are supposed to work with the latest R versions.

[^2]: In theory, it is not strictly required to use `>=`. You could use a strict inequality (`>`) but as we will see later, this is a very uncommon option so we recommend you use the *de facto* community standard and stick to `>=`.

[^3]: However, it is interesting to note that `package_version("3.5-0") == package_version("3.5.0")`. The use of `-` instead of `.` is purely stylistic.

[^4]: Instead of manually copying this file, you can run [`usethis::use_github_action("check-full")`](https://usethis.r-lib.org/reference/github_actions.html) in your package folder.

