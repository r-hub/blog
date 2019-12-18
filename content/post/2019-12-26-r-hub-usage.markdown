---
title: R-hub usage in a few figures
date: '2019-12-26'
slug: r-hub-usage
---




Earlier this year when launching this blog we [explained why R package developers should care about R-hub](/2019/03/26/why-care/). So, does anyone care? :wink: Yes! Let's summarize R-hub usage.

## Usage data

As specified in our [use terms](https://builder.r-hub.io/terms.html) we do not store user data. However we do store some usage data. In the table loaded below, emails and packages are unidentified -- but you can know whether an email or package comes up several times. 




```r
builds <- readRDS(my_not_portable_path)
builds <- dplyr::mutate_at(builds, c("submitted", "started"), anytime::anytime)
str(builds)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	80681 obs. of  8 variables:
##  $ email     : chr  "84157fcacbd507a47eaa4b6372d9c6c34857c9e106ebc0580b2fbd152ae9da6e" "84157fcacbd507a47eaa4b6372d9c6c34857c9e106ebc0580b2fbd152ae9da6e" "84157fcacbd507a47eaa4b6372d9c6c34857c9e106ebc0580b2fbd152ae9da6e" "84157fcacbd507a47eaa4b6372d9c6c34857c9e106ebc0580b2fbd152ae9da6e" ...
##  $ package   : chr  "9ea9109344df4f3fe561e18025b5b22ed6051cd3c53d2d60a14679bb7bf95a70" "9ea9109344df4f3fe561e18025b5b22ed6051cd3c53d2d60a14679bb7bf95a70" "9ea9109344df4f3fe561e18025b5b22ed6051cd3c53d2d60a14679bb7bf95a70" "9ea9109344df4f3fe561e18025b5b22ed6051cd3c53d2d60a14679bb7bf95a70" ...
##  $ platform  : chr  "windows-x86_64-release" "macos-elcapitan-release" "debian-gcc-release" "windows-x86_64-release" ...
##  $ status    : chr  "error" "ok" "ok" "ok" ...
##  $ submitted : POSIXct, format: "2018-03-15 07:23:17" "2018-03-16 05:44:39" ...
##  $ started   : POSIXct, format: NA "2018-03-16 05:44:43" ...
##  $ build_time: num  1.52e+12 1.45e+05 8.78e+05 1.52e+12 1.79e+06 ...
##  $ ui        : chr  NA NA NA NA ...
```

## A recent increase in usage

### Towards 1,000 builds a week? 


```r
library("ggplot2")
library("magrittr")
dplyr::mutate(builds, 
             week = as.Date(cut(submitted, "week"))) %>%
  dplyr::count(week) %>%
ggplot(aes(week, n)) +
  geom_point() +
  geom_smooth() +
  ylab("No. of buids") +
  xlab("Time (weeks)") +
  hrbrthemes::theme_ipsum(base_size = 16,
                          axis_title_size = 16)
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<div class="figure">
<img src="/post/2019-12-26-r-hub-usage_files/figure-html/usage-week-1.png" alt="Weekly count of builds on R-hub package builder, showing an slow increase until mid 2018 then a steeper increase to a little less than 1,000 builds a week" width="672" />
<p class="caption">Figure 1: Weekly count of builds on R-hub package builder, showing an slow increase until mid 2018 then a steeper increase to a little less than 1,000 builds a week</p>
</div>

When plotting the weekly count of builds as below, it is quite clear that usage stepped up at the end of last year. A delayed effect of the [RStudio webinar about R-hub](https://resources.rstudio.com/the-essentials-of-data-science/r-hub-overview-ga-bor-csa-rdi)?

### Number of packages built per week


```r
dplyr::mutate(builds, 
             week = as.Date(cut(submitted, "week"))) %>%
  dplyr::group_by(week) %>%
  dplyr::summarise(n = length(unique(package))) %>%
ggplot(aes(week, n)) +
  geom_point() +
  ylab("No. of packages built") +
  xlab("Time (weeks)")  +
  geom_smooth() +
  hrbrthemes::theme_ipsum(base_size = 16,
                          axis_title_size = 16)
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<div class="figure">
<img src="/post/2019-12-26-r-hub-usage_files/figure-html/usage-week-pkg-1.png" alt="Weekly count of builds on R-hub package builder, showing an increase, then a stagnation in 2018, then a steeper increase since the end of 2018, to about 125 packages a week. WHAT TO SAY ABOUT THE HIGH NUMBER OF PACKAGES SOME WEEKS IN 2017?" width="672" />
<p class="caption">Figure 2: Weekly count of builds on R-hub package builder, showing an increase, then a stagnation in 2018, then a steeper increase since the end of 2018, to about 125 packages a week. WHAT TO SAY ABOUT THE HIGH NUMBER OF PACKAGES SOME WEEKS IN 2017?</p>
</div>

The number of packages built mostly follow the number of builds apart from a stagnation last year.

### Number of unique users per week

What about the number of users?


```r
dplyr::mutate(builds, 
             week = as.Date(cut(submitted, "week"))) %>%
  dplyr::group_by(week) %>%
  dplyr::summarise(n = length(unique(email))) %>%
ggplot(aes(week, n)) +
  geom_point() +
  geom_smooth() +
  ylab("No. of distinct email addresses") +
  xlab("Time (weeks)") +
  hrbrthemes::theme_ipsum(base_size = 16,
                          axis_title_size = 16)
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<div class="figure">
<img src="/post/2019-12-26-r-hub-usage_files/figure-html/usage-week-user-1.png" alt="Weekly count of builds on R-hub package builder, showing an slow increase until mid 2018 then a steeper increase to a bit more than 100 users a week" width="672" />
<p class="caption">Figure 3: Weekly count of builds on R-hub package builder, showing an slow increase until mid 2018 then a steeper increase to a bit more than 100 users a week</p>
</div>

So all in all, the R-hub package builder is serving more and more users and packages.

## Platform usage

Choosing a platform or platforms for your package check might seem daunting. Luckily we've written up [some guidance in our docs](https://docs.r-hub.io/#which-platform)!

### Platform age

When was each platform added to the pool?


```r
builds %>%
  dplyr::group_by(platform) %>%
  dplyr::summarise(first = as.Date(min(submitted)),
                   last = as.Date(max(submitted))) %>%
  dplyr::arrange(first) %>%
  knitr::kable()
```



|platform                      |first      |last       |
|:-----------------------------|:----------|:----------|
|debian-gcc-devel              |2016-10-10 |2019-11-26 |
|windows-x86_64-release        |2016-10-10 |2019-11-26 |
|debian-gcc-release            |2016-10-11 |2019-11-26 |
|fedora-clang-devel            |2016-10-11 |2019-11-26 |
|fedora-gcc-devel              |2016-10-11 |2019-11-25 |
|linux-x86_64-centos6-epel     |2016-10-11 |2019-11-25 |
|ubuntu-gcc-devel              |2016-10-11 |2019-11-25 |
|ubuntu-gcc-release            |2016-10-11 |2019-11-26 |
|windows-x86_64-devel          |2016-10-11 |2019-11-26 |
|linux-x86_64-rocker-gcc-san   |2016-10-14 |2019-11-26 |
|windows-x86_64-oldrel         |2016-10-14 |2019-11-26 |
|windows-x86_64-patched        |2016-10-14 |2019-11-23 |
|linux-x86_64-centos6-epel-rdt |2016-10-17 |2019-11-25 |
|debian-gcc-patched            |2016-10-18 |2019-11-23 |
|macos-mavericks-release       |2017-01-31 |2017-07-01 |
|macos-elcapitan-devel         |2017-03-01 |2017-03-01 |
|macos-elcapitan-release       |2017-07-01 |2019-11-25 |
|macos-mavericks-oldrel        |2017-07-01 |2019-06-14 |
|ubuntu-rchk                   |2017-07-02 |2019-11-26 |
|solaris-x86-patched           |2017-07-24 |2019-11-25 |
|windows-x86_64-devel-rtools4  |2019-03-01 |2019-11-25 |
|debian-clang-devel            |2019-04-12 |2019-11-26 |
|debian-gcc-devel-nold         |2019-05-16 |2019-11-24 |

The youngest platforms include [r-devel-linux-x86_64-debian-clang and its special encoding](/2019/04/25/r-devel-linux-x86-64-debian-clang/), [a noLD platform](/2019/05/21/nold/), [the experimental Windows Rtools4.0 platform](https://twitter.com/rhub_/status/1102510360337268737). Most platforms are still up today, with the exception of macos-mavericks-release and macos-elcapitan-devel.

### Most frequently used platforms


```r
builds %>%
  dplyr::count(platform, sort = TRUE) %>%
  head(n = 7) %>%
  knitr::kable()
```



|platform                    |     n|
|:---------------------------|-----:|
|ubuntu-gcc-release          | 18554|
|windows-x86_64-devel        | 15890|
|fedora-clang-devel          | 15220|
|linux-x86_64-rocker-gcc-san |  5778|
|debian-gcc-devel            |  4083|
|windows-x86_64-release      |  4008|
|macos-elcapitan-release     |  2942|

The most frequently used platforms reflect the default platforms (from R, `rhub::platforms()[1,1]` which is debian-clang-devel, from the web interface ubuntu-gcc-release), including the default platforms mix for `rhub::check_for_cran()` (windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel and if the package needs compilation linux-x86_64-rocker-gcc-san).

## Conclusion

in this post we presented a few figures underlining the growth in R-hub usage, and the variety of platforms used for checking packages -- one of [R-hub's selling points](https://deploy-preview-53--admiring-allen-9a00b2.netlify.com/2019/03/26/why-care/#so-many-platforms). In total, over time, the R-hub package builder has been used by 2405 users for 4255 packages. For comparison at the time of writing there are 15347 packages on CRAN. 

We hope to keep helping package developers check their packages and debug issues, in particular thanks to the package builder, [its docs](https://docs.r-hub.io/), and this blog. Thanks to all users who notified problems and suggested enhancements via [GitHub](https://docs.r-hub.io/#pkg-dev-help) or [gitter](https://gitter.im/r-hub/community), keep your feedback and questions coming!
