---
slug: keep.source 
title: "State of R packages in your library" 
authors: 
- Maëlle Salmon 
date: "2020-07-20" 
tags: 
- package development 
output: hugodown::hugo_document
rmd_hash: 8a993a52996324f2

---

Ever wondered where packages in general and their code in particular go when you run something like [`install.packages()`](https://rdrr.io/r/utils/install.packages.html)? This post is for you!

Where do installed packages live?
---------------------------------

Packages are installed

-   at the path you give as `lib` argument to [`install.packages()`](https://rdrr.io/r/utils/install.packages.html) (or to any `remotes::install_` function, that will pass them on to [`install.packages()`](https://rdrr.io/r/utils/install.packages.html));

-   most often since you won't give any, at the first path returned by [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) that exists and for which the user has the right permissions. There are [several ways to change the paths returned, should you want to do so](https://stackoverflow.com/a/31707983/5489251).[^1]

Now at library loading, the important argument is called `lib.loc`, not `lib`.

{{< tweet 1275366793423523842 >}}

Now how do you know where any of your installed packages was installed? You can use [`find.package()`](https://rdrr.io/r/base/find.package.html) and [`path.package()`](https://rdrr.io/r/base/find.package.html)!

To check whether a package is installed, it is better to use [`find.package()`](https://rdrr.io/r/base/find.package.html) than [`installed.packages()`](https://rdrr.io/r/utils/installed.packages.html) because the latter, as its docs state, can be slow on some systems. In both cases, it does not mean the package is usable, for that you'd need to use `require()`.

What files are stored locally?
------------------------------

The [R packages book by Hadley Wickham and Jenny Bryan](https://r-pkgs.org/) has [a very neat package called "Package structure and state", including an explanation of the binary state](https://r-pkgs.org/package-structure-state.html#binary-package). It says *"There are no .R files in the R/ directory - instead there are three files that store the parsed functions in an efficient file format. This is basically the result of loading all the R code and then saving the functions with save(). (In the process, this adds a little extra metadata to make things as fast as possible)."*

The installed packages in the library are a decompressed version of the binary state. There are not all the R files, see [ggplot2 source code](https://github.com/tidyverse/ggplot2/) and ggplot2 on my disk

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>fs</span>::<span class='nf'><a href='http://fs.r-lib.org/reference/dir_tree.html'>dir_tree</a></span>(
  <span class='nf'><a href='https://rdrr.io/r/base/file.path.html'>file.path</a></span>(
    <span class='nf'><a href='https://rdrr.io/r/base/find.package.html'>find.package</a></span>(<span class='s'>"ggplot2"</span>),
    <span class='s'>"R"</span>
    )
  )
[01;34m/home/maelle/R/x86_64-pc-linux-gnu-library/4.0/ggplot2/R[0m
├── ggplot2
├── ggplot2.rdb
└── ggplot2.rdx
</code></pre>

</div>

Under the R folder, there are three files that don't even have the dot R extension!

What code format
----------------

Now, regarding the code, let's mention two important things happening to it.

### Byte compilation

Since [R 3.5](https://cran.r-project.org/doc/manuals/r-release/NEWS.3.html), the code is byte-compiled by default which means it is also stored in a format easier for a machine to deal with. You can learn more about byte compilation in the [Efficient R Programming book by Colin Gillespie and Robin Lovelace](https://bookdown.org/csgillespie/efficientR/programming.html#the-byte-compiler), and in [a talk by R Core Member Tomas Kalibera](https://blog.revolutionanalytics.com/2017/08/take-advantage-compiler.html).

### Original formatting and comments?

Then, by default, the source code is stripped of all empty lines and comments because they are useless for code execution and take up space.[^2]

It is similar to CSS, JS, HTML being minified in web development to make websites load faster. Now sometimes you might want to keep code with its comments: as an user for being able to read it locally with all its comments, as a developer for debugging or profiling.

As an user installing packages, you need to look into the `keep.source.pkgs` option in [`options()`](https://rdrr.io/r/base/options.html) that influences the behavior of package installation, or for a specific package you'd write [`install.packages("rhub", INSTALL_opts = "--with-keep.source")`](https://rdrr.io/r/utils/install.packages.html).[^3]

As a developer working on a package, you need to make sure the source is kept as is [when building the package, thanks to the `--with-keep.source` option](https://support.rstudio.com/hc/en-us/articles/205612627-Debugging-with-RStudio#debugging-in-packages), and when loading it (lucky you, the relevant `keep.source` option is `TRUE` by default in interactive sessions :tada:).

As a developer you might also encounter the case where `R CMD check` will tell you about another switch, in an environment variable. It is a switch related to package installation, since `R CMD check` will install your package for checking it . [See the lines below from the R source mirror](https://github.com/wch/r-source/blob/f27cbf1a52a31cd9b9676340394946a22041a4ae/src/library/tools/R/check.R#L5248-L5253):

``` r
                        wrapLog("Information on the location(s)",
                                "of code generating the",
                                paste0(sQuote("Note"), "s"),
                                "can be obtained by re-running with",
                                "environment variable R_KEEP_PKG_SOURCE",
                                "set to 'yes'.\n")
```

Also note that there is also a way for package maintainers to [force the installation of their package to keep the source](https://stat.ethz.ch/pipermail/r-devel/2011-April/060410.html), which seems less useful? Here are [packages that do that](https://github.com/search?q=keepsource+user%3Acran+filename%3ADESCRIPTION&type=Code&ref=advsearch&l=&l=). A potential use case might be to try and hire people [like the web development team at The Guardian seems to do if you view the source of its website](https://www.theguardian.com/international).

Conclusion
----------

In this post we summarized where packages live once installed, in what format, and how their code is processed at installation. An important aspect was the original code formatting and commenting being removed by default, unless one changes some options for building and installing packages. Do you use any of options related to keeping source in your R usage and development?

[^1]: If your wish is to isolate packages you are installing for a given project, you might find a better workflow by using Docker or [the `renv` package](https://rstudio.github.io/renv/index.html).

[^2]: This came to my attention thanks to [a question by Ofek Shilon on RStudio community](https://community.rstudio.com/t/keep-source-pkgs-vs-keep-source-options/69245).

[^3]: When viewing source code you might get a better default experience by [loading `lookup`](https://github.com/jimhester/lookup#default-printing) in your [.Rprofile](https://rstats.wtf/r-startup.html#rprofile).

