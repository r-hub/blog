---
date: "2019-03-26"
title: R package developers, why should you care about R-hub?
authors:
  - Maëlle Salmon
slug: why-care
tags:
  - promotion
---

**tl;dr: You should care about R-hub if you care about `R CMD check`, on all operating systems, for free, and don't ever want to leave R.**

So, why use the R-hub package builder?

## It is useful

As an R package developer, you probably regularly use [`R CMD check`](http://r-pkgs.had.co.nz/check.html) to detect common problems in your package, and you might even [_love that command_](https://juliasilge.com/blog/how-i-stopped/). You might run it locally, or on a [continuous integration platform](https://juliasilge.com/blog/beginners-guide-to-travis/) such as Travis (Linux, macOS) or Appveyor (Windows). That's great! 

Now, how can you add a platform to your arsenal once in a while, or make sure your package will behave correctly on CRAN's platforms? No need to borrow someone's machine or to tweak your machine or a continuous integration config file: the R-hub package builder is there for you! `R CMD check` as a service on all operating systems, with platforms corresponding to different settings. 

## You do not need to leave R

There is an R client, `rhub`, allowing to manage your package builds on R-hub platforms from your R console! By default, you can follow along how your package build is going:

{{< figure src="check-output.gif" alt="check log in the R console" >}}


Here's how you'd prepare a CRAN submission by submitting your package to all 3 recommended platforms, before getting a summary of results ready to be copy-pasted into your `cran-comments.md` file.

```r
chk <- check_for_cran()
# wait a bit
chk$cran_summary()
#> Updating status...
#> ## Test environments
#> - R-hub fedora-clang-devel (r-devel)
#>  - R-hub windows-x86_64-devel (r-devel)
#>  - R-hub ubuntu-gcc-release (r-release)
#> 
#> ## R CMD check results
#> ❯ On fedora-clang-devel (r-devel), windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release)
#>   checking CRAN incoming feasibility ... NOTE
#>   Maintainer: ‘Maëlle Salmon <maelle.salmon@yahoo.se>’
#>   
#>   New submission
#>   
#>   The Description field contains
#>     <http://http://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file>
#>   Please enclose URLs in angle brackets (<...>).
#>   
#>   The Date field is over a month old.
#> 
#> ❯ On fedora-clang-devel (r-devel), windows-x86_64-devel (r-devel), ubuntu-gcc-release (r-release)
#>   checking R code for possible problems ... NOTE
#>   .bello: no visible global function definition for ‘tail’
#>   Undefined global functions or variables:
#>     tail
#>   Consider adding
#>     importFrom("utils", "tail")
#>   to your NAMESPACE file.
#> 
#> 0 errors ✔ | 0 warnings ✔ | 2 notes ✖
```

[Find out more about `rhub`](https://r-hub.github.io/rhub/)!

## So many platforms!

Here is a view of R-hub platforms at the moment of writing. 
``` r
knitr::kable(rhub::platforms(), row.names = FALSE)
```
<details>
<summary>Click to see a huge table.</summary>
<table>
<thead>
<tr class="header">
<th style="text-align: left;">name</th>
<th style="text-align: left;">description</th>
<th style="text-align: left;">cran-name</th>
<th style="text-align: left;">rversion</th>
<th style="text-align: left;">os-type</th>
<th style="text-align: left;">cpu-type</th>
<th style="text-align: left;">os-info</th>
<th style="text-align: left;">compilers</th>
<th style="text-align: left;">docker-image</th>
<th style="text-align: left;">sysreqs-platform</th>
<th style="text-align: left;">categories</th>
<th style="text-align: left;">node-labels</th>
<th style="text-align: left;">output-parser</th>
<th style="text-align: left;">macos-version</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">debian-gcc-devel</td>
<td style="text-align: left;">Debian Linux, R-devel, GCC</td>
<td style="text-align: left;">r-devel-linux-x86_64-debian-gcc</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Debian GNU/Linux testing</td>
<td style="text-align: left;">GCC 6.2.0 (Debian 6.2.0-6)</td>
<td style="text-align: left;">debian-gcc-devel</td>
<td style="text-align: left;">linux-x86_64-debian-gcc</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">debian-gcc-patched</td>
<td style="text-align: left;">Debian Linux, R-patched, GCC</td>
<td style="text-align: left;">r-patched-linux-x86_64</td>
<td style="text-align: left;">r-patched</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Debian GNU/Linux testing</td>
<td style="text-align: left;">GCC 6.2.0 (Debian 6.2.0-6)</td>
<td style="text-align: left;">debian-gcc-patched</td>
<td style="text-align: left;">linux-x86_64-debian-gcc</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">debian-gcc-release</td>
<td style="text-align: left;">Debian Linux, R-release, GCC</td>
<td style="text-align: left;">r-release-linux-x86_64</td>
<td style="text-align: left;">r-release</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Debian GNU/Linux testing</td>
<td style="text-align: left;">GCC 6.2.0 (Debian 6.2.0-6)</td>
<td style="text-align: left;">debian-gcc-release</td>
<td style="text-align: left;">linux-x86_64-debian-gcc</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">fedora-clang-devel</td>
<td style="text-align: left;">Fedora Linux, R-devel, clang, gfortran</td>
<td style="text-align: left;">r-devel-linux-x86_64-fedora-clang</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Fedora 24</td>
<td style="text-align: left;">clang version 3.8.0; GNU Fortran 6.1.1</td>
<td style="text-align: left;">fedora-clang-devel</td>
<td style="text-align: left;">linux-x86_64-fedora-clang</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">fedora-gcc-devel</td>
<td style="text-align: left;">Fedora Linux, R-devel, GCC</td>
<td style="text-align: left;">r-devel-linux-x86_64-fedora-gcc</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Fedora 24</td>
<td style="text-align: left;">GCC 6.1.1</td>
<td style="text-align: left;">fedora-gcc-devel</td>
<td style="text-align: left;">linux-x86_64-fedora-gcc</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">linux-x86_64-centos6-epel</td>
<td style="text-align: left;">CentOS 6, stock R from EPEL</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-release</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">CentOS 6</td>
<td style="text-align: left;">GCC 4.4.x</td>
<td style="text-align: left;">centos6-epel</td>
<td style="text-align: left;">linux-x86_64-centos6-epel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">linux-x86_64-centos6-epel-rdt</td>
<td style="text-align: left;">CentOS 6 with Redhat Developer Toolset, R from EPEL</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-release</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">CentOS 6</td>
<td style="text-align: left;">GCC 5.2.1</td>
<td style="text-align: left;">centos6-epel-rdt</td>
<td style="text-align: left;">linux-x86_64-centos6-epel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">linux-x86_64-rocker-gcc-san</td>
<td style="text-align: left;">Debian Linux, R-devel, GCC ASAN/UBSAN</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Debian GNU/Linux testing</td>
<td style="text-align: left;">GCC 5.4.0 (Debian 5.4.0-4)</td>
<td style="text-align: left;">rocker-gcc-san</td>
<td style="text-align: left;">linux-x86_64-debian-gcc</td>
<td style="text-align: left;">Checks for compiled code</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">sanitizers</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">macos-elcapitan-release</td>
<td style="text-align: left;">macOS 10.11 El Capitan, R-release (experimental)</td>
<td style="text-align: left;">r-release-osx-x86_64</td>
<td style="text-align: left;">r-release</td>
<td style="text-align: left;">macOS</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Mac OS X 10.11.6 15G1217</td>
<td style="text-align: left;">Apple LLVM version 8.0 (clang-800.0.42.1); GNU Fortran 4.2.3</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">osx-x86_64-clang</td>
<td style="text-align: left;">macOS</td>
<td style="text-align: left;">c(“macos”, “elcapitan”, “r-release”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">elcapitan</td>
</tr>
<tr class="even">
<td style="text-align: left;">macos-mavericks-oldrel</td>
<td style="text-align: left;">macOS 10.9 Mavericks, R-oldrel (experimental)</td>
<td style="text-align: left;">r-oldrel-osx-x86_64</td>
<td style="text-align: left;">r-oldrel</td>
<td style="text-align: left;">macOS</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Mac OS X 10.9.5 13F1911</td>
<td style="text-align: left;">Apple LLVM version 6.0 (clang-600.0.57); GNU Fortran 4.2.3</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">osx-x86_64-clang</td>
<td style="text-align: left;">macOS</td>
<td style="text-align: left;">c(“macos”, “mavericks”, “r-oldrel”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">mavericks</td>
</tr>
<tr class="odd">
<td style="text-align: left;">solaris-x86-patched</td>
<td style="text-align: left;">Oracle Solaris 10, x86, 32 bit, R-patched (experimental)</td>
<td style="text-align: left;">r-patched-solaris-x86</td>
<td style="text-align: left;">r-patched</td>
<td style="text-align: left;">Solaris</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">SunOS 5.10 Generic_147148-26 i86pc i386 i86pc</td>
<td style="text-align: left;">GCC 5.2.0</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">solaris-10</td>
<td style="text-align: left;">Solaris</td>
<td style="text-align: left;">solaris</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">ubuntu-gcc-devel</td>
<td style="text-align: left;">Ubuntu Linux 16.04 LTS, R-devel, GCC</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Ubuntu 16.04 LTS</td>
<td style="text-align: left;">GCC 5.3.1</td>
<td style="text-align: left;">ubuntu-gcc-devel</td>
<td style="text-align: left;">linux-x86_64-ubuntu-gcc</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ubuntu-gcc-release</td>
<td style="text-align: left;">Ubuntu Linux 16.04 LTS, R-release, GCC</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-release</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Ubuntu 16.04 LTS</td>
<td style="text-align: left;">GCC 5.3.1</td>
<td style="text-align: left;">ubuntu-gcc-release</td>
<td style="text-align: left;">linux-x86_64-ubuntu-gcc</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">ubuntu-rchk</td>
<td style="text-align: left;">Ubuntu Linux 16.04 LTS, R-devel with rchk</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Linux</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Ubuntu 16.04 LTS</td>
<td style="text-align: left;">clang 3.8.0-2ubuntu4</td>
<td style="text-align: left;">ubuntu-rchk</td>
<td style="text-align: left;">linux-x86_64-ubuntu-gcc</td>
<td style="text-align: left;">Checks for compiled code</td>
<td style="text-align: left;">linux</td>
<td style="text-align: left;">rchk</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">windows-x86_64-devel</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1, R-devel, 32/64 bit</td>
<td style="text-align: left;">r-devel-windows-ix86+x86_64</td>
<td style="text-align: left;">r-devel</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1</td>
<td style="text-align: left;">GCC 4.9.3, Rtools 3.4</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">windows-2008</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">c(“windows”, “rtools3”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">windows-x86_64-devel-rtools4</td>
<td style="text-align: left;">Windows Server 2012, R-devel, Rtools4.0, 32/64 bit (experimental)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-testing</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Windows Server 2012</td>
<td style="text-align: left;">Rtools 4.0</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">windows-2012</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">c(“windows”, “rtools4.0”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">windows-x86_64-oldrel</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1, R-oldrel, 32/64 bit</td>
<td style="text-align: left;">r-oldrel-windows-ix86+x86_64</td>
<td style="text-align: left;">r-oldrel</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1</td>
<td style="text-align: left;">GCC 4.6.3, Rtools 3.3</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">windows-2008</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">c(“windows”, “rtools3”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="even">
<td style="text-align: left;">windows-x86_64-patched</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1, R-patched, 32/64 bit</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">r-patched</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1</td>
<td style="text-align: left;">GCC 4.9.3, Rtools 3.4</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">windows-2008</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">c(“windows”, “rtools3”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
<tr class="odd">
<td style="text-align: left;">windows-x86_64-release</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1, R-release, 32/64 bit</td>
<td style="text-align: left;">r-release-windows-ix86+x86_64</td>
<td style="text-align: left;">r-release</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">x86_64</td>
<td style="text-align: left;">Windows Server 2008 R2 SP1</td>
<td style="text-align: left;">GCC 4.9.3, Rtools 3.4</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">windows-2008</td>
<td style="text-align: left;">Windows</td>
<td style="text-align: left;">c(“windows”, “rtools3”)</td>
<td style="text-align: left;">NA</td>
<td style="text-align: left;">NA</td>
</tr>
</tbody>
</table>
</details>

Noteworthy is the presence of

* 4 operating systems;

* platforms [mimicking CRAN platforms as well as possible](https://docs.r-hub.io/#rhub-cran-platforms);

* sanitizers for compiled code!

If you feel overwhelmed now (19 platforms!), fear not, we've written some guidance [about choosing one R-hub platform](https://docs.r-hub.io/#which-platform).

## It is free and open-source

Most of R-hub's components are open-source, check out [our GitHub organization](https://github.com/r-hub/)! And all of it is accessible _for free_ for all members of the community. 

## There is more (to come)

At the moment, you'd be forgiven for thinking R-hub == R-hub package builder, but stay tuned, because there's more to come for R-hub, and for [its documentation](https://docs.r-hub.io/)! To mention a further feature that's already at your disposal, R-hub Linux Docker images [are available](https://github.com/r-hub/rhub-linux-builders#rhub-linux-builders) for you to check your package with locally... [without leaving R, once again](https://r-hub.github.io/rhub/reference#local).

# Now what?

We hope you care about R-hub, and now what? Well please keep using the service, provide feedback about user experience, bugs, docs, etc. [in `rhub` repo](https://github.com/r-hub/rhub) and ask questions on [gitter](https://gitter.im/r-hub/community). R-hub is a project for the R community, let's keep improving it together!