---
date: "2019-06-05"
title: R-hub blog's privacy policy
---

This blog is deployed via [Netlify](https://www.netlify.com/gdpr/).

We use [Google Analytics](https://analytics.google.com/analytics/web/) to log data and ultimately improve the blog. Below are the [Hugo privacy settings](https://gohugo.io/about/hugo-and-gdpr/#googleanalytics) we use for Google Analytics, within [the Hugo config file for this blog](https://github.com/r-hub/blog/blob/master/config.toml).

```yaml
  [privacy.googleAnalytics]
    anonymizeIP = true
    disable = false
    respectDoNotTrack = true
    useSessionStorage = true
```

This means

* IP addresses are anonymized within Google Analytics,

* The GA templates respect the “Do Not Track” HTTP header,

* The use of Cookies is disabled, instead Session Storage to Store the GA Client ID is used.

For more information, contact <admin@rhub.io>.
