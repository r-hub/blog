---
title:  r-devel-linux-x86_64-debian-clang, or keeping up with CRAN platforms with help from R-hub
date: '2019-04-13'
slug:  r-devel-linux-x86-64-debian-clang
tags:
  - help
  - CRAN
---

**tl;dr: CRAN changed settings on one check platform,  r-devel-linux-x86_64-debian-clang, which revealed bugs in packages. A new platform was added to R-hub package builder to allow package authors to reproduce these bugs online on the platform, or locally via Docker.**

In this post, we shall introduce CRAN checks in general, present the new setting of the r-devel-linux-x86_64-debian-clang CRAN platform, how it was mimicked on one of R-hub platforms, and how to use this new R-hub platform to debug your package.

# CRAN checks 101

All CRAN packages are _R CMD Check_-ed regularly on 12 CRAN platforms, more than at submission. The results of these checks are reported on each package's check results page, cf [e.g. `fpeek`'s one](https://cran.r-project.org/web/checks/check_results_fpeek.html). You might notice your package starts getting NOTE(s)/WARNING(s)/ERROR(s) on one of them by different means:

* You might have set up [some `foghorn` code](https://github.com/fmichonneau/foghorn) in [your .Rprofile](https://www.tidyverse.org/articles/2019/04/usethis-1.5.0/#options-to-set-in-rprofile) to regularly, well, check, your CRAN checks results.  :loudspeaker: :boat:

* Your package repo might exhibit a [CRAN check badge by rOpenSci Scott Chamberlain](https://github.com/ropensci/cchecksapi#badges), and you see a different color whilst landing on your README.  :traffic_light:

* You might receive an email from CRAN itself, informing you some steps are to be taken to avoid your package's being taken down from CRAN.  :email: :scream:

No matter how you noticed the new problems, you'll be interested in solving them leisurely (a small NOTE) or urgently. What if the fix isn't obvious, what if you need to be able to run several checks in the platform before finding or feeling confident in your bug fix? That's where R-hub platforms can help! Our docs indicate [how to find the R-hub platform that's closest to a CRAN platform](https://docs.r-hub.io/#rhub-cran-platforms) and [how to reproduce a bug uncovered by R-hub](https://docs.r-hub.io/#local-debugging) -- locally, you can only run R-hub _Linux_ platforms via Docker. In the rest of the post, we shall use r-devel-linux-x86_64-debian-clang's recent changes as a case study.

[About encoding in R](https://kevinushey.github.io/blog/2018/02/21/string-encoding-and-r/)
