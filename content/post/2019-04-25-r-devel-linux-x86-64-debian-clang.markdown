---
title:  How to handle CRAN checks with help from R-hub
date: '2019-04-25'
slug:  r-devel-linux-x86-64-debian-clang
tags:
  - help
  - CRAN
---

In this post, we shall introduce CRAN checks in general and use the recent changes of the r-devel-linux-x86_64-debian-clang CRAN platform as a case study of how R-hub can help you, package developers, handle CRAN checks and keep up with CRAN platforms.

# CRAN checks 101

All CRAN packages are _R CMD Check_-ed regularly on 12 CRAN platforms called [_CRAN Package Check Flavors_](https://cran.r-project.org/web/checks/check_flavors.htmlac), more platforms than at submission. The results of these checks are reported on each package's check results page, cf [e.g. `fpeek`'s one](https://cran.r-project.org/web/checks/check_results_fpeek.html). 

## CRAN checks failure

Your package might get NOTE(s)/WARNING(s)/ERROR(s)

* right after it was accepted on CRAN, revealing issues the CRAN platforms used at submission hadn't uncovered. 

* later, 
    * if one of your package's dependencies changes, 
    * if your package e.g. wraps a web service that evolved or broke,
    * if the CRAN check flavors changed a bit.

## CRAN checks surveillance

You might notice your package starts getting NOTE(s)/WARNING(s)/ERROR(s) on one CRAN check platform by different means:

* You might have set up [some `foghorn` code](https://github.com/fmichonneau/foghorn) by François Michonneau in [your .Rprofile](https://www.tidyverse.org/articles/2019/04/usethis-1.5.0/#options-to-set-in-rprofile) to regularly, well, check, your CRAN checks results.  :loudspeaker: :boat:

* Your package repo might exhibit a [CRAN check badge by rOpenSci's Scott Chamberlain](https://github.com/ropensci/cchecksapi#badges), and you see a different color whilst landing on your README.  :traffic_light:

* You might receive an email from CRAN itself, informing you some steps are to be taken to avoid your package's being taken down from CRAN.  :email: :scream:

No matter how you noticed the new problems, you'll be interested in solving them leisurely (a small NOTE) or urgently. What if the fix isn't obvious, what if you need to be able to run several checks in the platform before finding or feeling confident in your bug fix? That's where R-hub platforms can help! Our docs indicate [how to find the R-hub platform that's closest to a CRAN platform](https://docs.r-hub.io/#rhub-cran-platforms) and [how to reproduce a bug uncovered by R-hub](https://docs.r-hub.io/#local-debugging) -- locally, you can only run R-hub _Linux_ platforms via Docker. 

In the rest of the post, we shall use r-devel-linux-x86_64-debian-clang's recent changes as a case study.

# r-devel-linux-x86_64-debian-clang

The name above is clearly not an ice-cream flavor, it's a CRAN check flavor that recently underwent a small but crucial change of an :fire: encoding option :fire:. Discussing encoding in R is beyond the scope of this post, refer e.g. to [Kevin Ushey's write-up "String Encoding and R"](https://kevinushey.github.io/blog/2018/02/21/string-encoding-and-r/). There's to our knowledge no changelog of CRAN platform evolutions, but package authors noticed their CRAN checks results changed, and wondered whether the change was intentional, as shown by e.g. [David Gohel's post to R-package-devel](https://stat.ethz.ch/pipermail/r-package-devel/2019q2/003750.html). This unusual charset choice from UTF-8 to ISO8859-15, was indeed intentional, since authors of failing packages received an email from CRAN. Now, how to fix the issues and check the fixes, given that there was, at the time, no equivalent R-hub platform? 

Luckily, a new R-hub platform was promptly added to mimick the r-devel-linux-x86_64-debian-clang CRAN flavor and in particular its [spicy encoding](https://github.com/r-hub/rhub-linux-builders/blob/2de434eaf22f1d9f9b45dad1dbdf506d3e2a89c0/debian-clang-devel/Dockerfile#L21): **debian-clang-devel**. You can find its [Docker configuration in the R-hub Linux builders repository](https://github.com/r-hub/rhub-linux-builders), as well as links to the corresponding Docker hub image. Deploying the newly minted R-hub platform also involved updating R-hub builder itself, [its web interface](https://github.com/r-hub/rhub-frontend) and [the system used by R-hub to install system requirements of packages on Linux platforms](https://github.com/r-hub/sysreqsdb). The [`rhub` documentation website](https://r-hub.github.io/rhub/) was also updated via a build trigger on Travis, so that the two vignettes might mention the new platform.

Now, as a package author whose package failed on the r-devel-linux-x86_64-debian-clang CRAN platform, you can test your package fix by [selecting "debian-clang-devel" on the web platform](https://builder.r-hub.io/advanced) or, [even better](https://docs.r-hub.io/#pkg-vs-web), in R via

```r
rhub::check(<package-file>, platform = "debian-clang-devel")
```

which will submit your package to the new platform. If you need a complete traceback, have a look at the artifacts, either via the link in the email you'll get with the results, or via [the `rhub` package](/2019/04/08/rhub-1.1.1/#find-your-checks-and-their-artifacts-on-the-web).

Or you can run

```r
rhub::local_check_linux(<package-file>, image = "rhub/debian-clang-devel")
```

in order to have the check happen locally, unless you use Windows on which local R-hub checks are not supported yet.

Or you can download [the Docker image](https://hub.docker.com/r/rhub/debian-clang-devel) and play with it at your leisure.

# Conclusion

In this post, we explained what CRAN checks are, how to keep track of their results, and how to use R-hub platforms to reproduce bugs and check fixes. We used the recent changes of the r-devel-linux-x86_64-debian-clang CRAN platform, and the corresponding addition of an R-hub platform, as case study of how R-hub can help package developers keep up with CRAN platforms.

We hope you find the solution to your package failures on if you're one of the lucky maintainers impacted by r-devel-linux-x86_64-debian-clang's changes. :crying_cat_face: See e.g. [David Gohel's fix for `ggiraph`](https://github.com/davidgohel/ggiraph/commit/ac43f3b849a1f730b02e77671b354712b12415d0) in the C code, and his fix for [`fpeek` where tests are now selectively run](https://github.com/davidgohel/fpeek/blob/2fe6e41f5eb90583ba3393e07c8508b77e28d2ed/tests/testthat/test-iconv.R#L7).

Now, in any case, if you still need some guidance, we'd recommend [referring to the section of our docs explaining where to get help with R package development](https://docs.r-hub.io/#pkg-dev-help).
