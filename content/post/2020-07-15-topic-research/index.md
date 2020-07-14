---
slug: topic-research 
title: "Picking and researching blog topics about R package development" 
authors: 
- Maëlle Salmon 
date: "2020-07-15" 
tags: 
- package development 
- documentation
output: hugodown::hugo_document
rmd_hash: 4a571a6a77f105e6

---

An alternative title for this post would be "the very meta one". :wink: In this post we shall present some principles and tips used in preparing posts on this blog, that might be useful for problem solving for R package developers and for blogging here or elsewhere.

Choosing and finding relevant topics
------------------------------------

A topic is relevant if it's related to R package development, and if it's covered extensively elsewhere: unless a blog post can provide more context, presentation of newer tooling, a new perspective, we are not going to duplicate existing content. We are quite lucky that nothing is too niche for the R-hub blog. :grin: There is also no such thing as a too basic or too advanced topic: for [advanced topics](/2020/02/20/processx-blocked-sigchld/), the introduction should make clear it might be of interest to a few readers only; for [supposedly basic topics](/2019/12/12/internal-functions/), we hope there will always be something new to some readers.

Compared to extensive documentation like [Writing R Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html), how-to books like the [R packages book by Hadley Wickham and Jenny Bryan](https://r-pkgs.org/), and the [rOpenSci dev guide](https://devguide.ropensci.org), our blog post have more style and structure freedom, can list tools of various maturity levels since it's expected that blog posts will age and since we are not formulating standards.

Now how do we find inspiration? All authors of posts on this blog develop R packages or spend time helping others do that, therefore they can encounter some tricky problems themselves that can be relevant. Then, reading places where people look for help about package development, namely the [R-package-devel mailing list](https://stat.ethz.ch/mailman/listinfo/r-package-devel), the [R Package Development category of community.rstudio.com](https://community.rstudio.com/c/package-development/11), the [rOpenSci forum](https://discuss.ropensci.org) and Twitter can help uncover interesting questions.

A question can be a post topic on its own, as was the case for [our post about code generation inspired by a tweet of Miles McBain's](/2020/02/10/code-generation/). Or several questions can be put together to knit a post, such as [our post about optimal vignette workflows](/2020/06/03/vignettes/). A question or problem can also just be a pretext for a more general discussion, like in [our post about retries in API packages and reinventing the wheel](/2020/04/07/retry-wheel/).

Researching topics
------------------

How do we prepare content, that's hopefully not wrong? We obviously only rely on our extensive knowledge. :wink: Just kidding, we have many places were to gather ideas from.

First of all, places [where people ask for help](/2019/04/11/r-package-devel/) are also places where other people provide help so it is useful to research old topics. For R-package-devel, the [archive on mail-archive.com](https://www.mail-archive.com/r-package-devel@r-project.org/) is much easier to search than the official archive.

Then, we go back to the usual references. Say we are preparing a post about vignettes, then we read the vignettes chapter in the R packages book, we do "Ctrl+F vignette" in Writing R Extensions[^1] and we re-read the short [CRAN policies](https://cran.r-project.org/web/packages/policies.html).

As a side-note this piecemeal consumption of Writing R Extensions is a good way to learn new concepts and to think about them without being overwhelmed. It is very much in line with the tweet by Julia Evans embedded below.

{{< tweet 1266033708924092417 >}}

Furthermore, we obviously [read source code](/2019/05/14/read-the-source/)! :innocent: We do so on GitHub because it is a handy way to search for occurrences of terms, and because one can then (perma-)link to it. Exploring the [GitHub mirror of R source](https://github.com/wch/r-source) help see [how things actually work](/2020/05/20/rbuildignore/#standard-known-directory-and-files). The [mirror of CRAN packages source maintained by R-hub](https://github.com/cran) can help find examples of things in the wild when we can't think of an example ourselves.

Besides, we use a search engine or [`pkgsearch`](https://r-hub.github.io/pkgsearch/index.html) to look for packages that are relevant to a topic.

Last but not least, our posts are reviewed by a second pair of eyes at least, which helps limit errors and omissions. Thanks also to the commenters who help complete posts. :pray:

Conclusion
----------

In this post we explained how we select and explore topics for the R-hub blog. Our sources of inspiration and information are good to know about for problem solving by package developers in general. Feel free to suggest post ideas and information sources in the comments below or [in a separate issue](https://github.com/r-hub/blog/issues/).

[^1]: Writing R Extensions is only available on one page. [Colin Fay](https://colinfay.me/) had made [a nice bookdown version out of it](https://colinfay.me/writing-r-extensions/creating-r-packages.html) but it is not synced.

