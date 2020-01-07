---
slug: cran-error
title: "From Shock to Competence: How Not to Panic When You Receive E-mail from CRAN about Failed Checks"
authors:
  - Julia Romanowska
date: "2020-01-02"
tags:
- package development
output: 
  html_document:
    keep_md: true
---

> This post was contributed by [Julia Romanowska](https://jrom.bitbucket.io/homepage/), Researcher at the University of Bergen, Norway. Thank you, Julia!



<!--
  - how we got to know about it
  - raising an issue on bitbucket(?)
  - installing docker and checking the docs
  - searching for R and docker
  - found r-hub and rocker
  - running r-hub - problems
  - figure out where the problem is (docker images didn't have access to the net)
  - creating a script that runs everything manually, using the image provided by rhub
-->

I'm involved in development of the [Haplin](https://cran.r-project.org/package=Haplin) R package, which enables fast genetic association analyses (very useful for those involved in genetic epidemiology research). We are a team of scientists that have various background, from genetics, through bioinformatics and statistics. Here's a short text about our latest "adventure" with CRAN and how it taught us some useful stuff.

## OMG, CRAN wrote to me!

There will come the time when you check your mailbox and see this dreaded message about a check that your beloved CRAN package failed. Even though the deadline for submitting a fix is quite reasonable, you might imagine yourself sitting long into the night over your laptop just to find out where is this one comma that was the source of the error. However, I need to say we were positively surprised over the level of details of feedback we got from CRAN concerning the error in _our_ package.

Thus, important :sparkles: tip \#1 :sparkles: *read the e-mail from CRAN carefully!*

## Reproducing the error

OK, let's get to work! Firstly, check the "checks" webpage on CRAN. These CRAN checks come in different _flavors_ and hopefully, not all checks failed. In our case, the flavor that produced the error was `r-devel-linux-x86_64-debian-clang` and I had no wish to install the developmental version of R and other packages on my local laptop just to try mimicking this setup. That's when I thought about checking [*docker*](https://www.docker.com/).

Installing `docker` and running a test went well, but what one needs is a VM that would be exactly the same as the platforms CRAN uses for testing. I realized that it would take too much time to re-create it, so again my DuckDuckGo search engine[^1] came to the rescue.

:sparkles: Tip \#2 :sparkles: *search the net!*

## R and docker

<!-- r-hub and rocker - which is good for what -->
There are two services that are worth mentioning:

- [rhub](https://r-hub.github.io/rhub/), which is an R package for using the r-hub,
- and the [Rocker project](https://www.rocker-project.org/), which distributes various docker images useful for R and RStudio testing

If you are a maintainer of an R package and don't want to install docker locally, you will find the `rhub` very useful, as you can push your package to the server for testing with one command! Check out e.g., [this blog post](https://blog.r-hub.io/2019/04/25/r-devel-linux-x86-64-debian-clang/)

If you want to test more locally, and importantly, if you want to test visualizations, GUI, or specific behavior of the code in RStudio, you should take a look on the `Rocker project`. They provide easy-to-run docker images with pre-installed R and RStudio, which you can play with through a browser window.

## R-hub locally

In my case, I am not registered as the main maintainer of Haplin, and I wanted to test locally, so I decided to use one of the `rhub` functions, [`local_check_linux()`](https://r-hub.github.io/rhub/reference/local_check_linux.html). This seemed like a very easy way to run locally tests on a platform that is exactly the same as CRAN uses! And it is... only not in my case ;)

After getting the same error for the nth time, I decided to get help [at the source](https://github.com/r-hub/rhub/issues/322). I tried several things, including digging into the `rhub` code locally, but nothing worked. Long story short - my docker installation by default gave no access to internet to the containers it launched.

:sparkles: Tip \#3 :sparkles: *ask for help other people!* (they don't bite, especially not via e-mails)

## Script for semi-manual checks

Another couple of days and I talked with my husband, who showed me a script he used in one of his projects. [The script](https://bitbucket.org/Grantlab/bio3d/src/master/ver_devel/util/run_dockercheck.sh) uses a local docker installation, fetches one of the images hosted by `rhub`, and runs tests locally. *Bingo!* As this was the second time I tried using docker, I needed some attempts to adjust the script to my purposes, but it finally worked!

## Conclusion

Thanks to `rhub` and other tools available online, it's relatively easy to test a CRAN package.


### _Post scriptum_

While writing this post, I've come upon another R package [dockr](https://cran.r-project.org/package=dockr), which helps creating a docker container with the package one wants to test already available within the container. I haven't tried it yet, but [it seems very promising](http://smaakage85.netlify.com/2019/12/21/dockr-easy-containerization-for-r/)!


> Find Julia on [github](https://github.com/jromanowska), [bitbucket](https://bitbucket.org/jrom/profile/repositories), or [facebook](https://www.facebook.com/julia.romanowska.733)


[^1]: I repeatedly refuse to use google - check out [here](https://spreadprivacy.com/how-to-remove-google/)