---
slug: rhub2
title: "R-hub v2"
authors:
- Gábor Csárdi
date: "2024-04-11"
tags:
- R-hub
output: hugodown::hugo_document
summary: |
  After eight years, we are retiring the current version of R-hub, in favor
  of a better, faster, modern system.
  We call the new system R-hub v2.
  R-hub v2 runs R package checks on
  [GitHub Actions](https://github.com/features/actions).
  R-hub v2 works best if your R package is in a GitHub repository.
  This post helps you transition to R-hub v2 from the previous version.
rmd_hash: a7b93e9ffbaf3bcb

---

After eight years, we are retiring the current version of R-hub, in favor of a better, faster, modern system. We call the new system R-hub v2. R-hub v2 runs R package checks on [GitHub Actions](https://github.com/features/actions). R-hub v2 works best if your R package is in a GitHub repository. This post helps you transition to R-hub v2 from the previous version.

# TL;DR

**Is your package on GitHub?**

1.  Install or update the rhub package.
2.  Run `rhub::rhub_setup()` to set up R-hub v2 for your package.
3.  Run [`rhub::rhub_check()`](https://r-hub.github.io/rhub/reference/rhub_check.html) to run R-hub checks.

**You don't want to put your package on GitHub?**

1.  Install or update the rhub package.
2.  Run `rhub::rc_submit()` to run R-hub checks.

Do you want to know more? Read on.

# Introduction

R-hub v2 is a completely new check system. To use it you'll need at least version 2.0.0 of the rhub package.

There are two ways to use R-hub v2. Our recommendation is to store your R package in a GitHub repository and use the `rhub::rhub_*()` functions to start checks on GitHub Actions, using your own GitHub account.

Alternatively, if you don't want to store your R package at GitHub, you can use the `rhub::rc_*()` functions to run checks in a shared GitHub organization at <https://github.com/r-hub2>, using the R Consortium runners.

# Transitioning from R-hub v1

In this section we assume that your R package is in a GitHub repository. See "The R Consortium Runners" section below for a different way of using R-hub v2.

## Differences from R-hub v1

-   The check picks up the package from GitHub, so it does not use changes in your local git clone. You need to push the changes to GitHub first. You can use a non-default branch, with the `branch` argument of `rhub_check()`.
-   You'll not get an email about the check results. But you'll receive regular GitHub notifications about check failures, unless you opt out. Github can also turn these into emails if you like.
-   There is no live output from the check at the R console. See the 'Actions' tab of your repository on GitHub for a live check log.
-   Many more specialized platforms are available.
-   Most platforms use binary packages, so checks and in particular installing dependencies is much faster.

### Private repositories

GitHub Actions is free for public repositories. For private repositories you also get some minutes for free, depending on the GitHub subscription you have. See [About billing for GitHub Actions](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions) for pricing and more details.

### Branches

You can run checks on any branch that you push to GitHub, but the R-hub workflow file (`.github/workflows/rhub.yaml` within your repo) must be present in **both** your default branch (usually `main`) and also in the branch you want to run the check on.

## Requirements

-   First, you need a GitHub account.

-   Second, you need to have your R package in a GitHub repository. Make sure that upstream git remote is set to the GitHub repository in your local git clone. Run `git branch -vv` to see your local branches and the upstream branches they are tracking. Example output:

        ❯ git branch -vv
          ...
        * main             87a2066 [origin/main] Avoid fancy quotes in test snapshots
          ...
        ❯ git remote -v
        origin    git@github.com:r-hub/rhub.git (fetch)
        origin    git@github.com:r-hub/rhub.git (push)

    which means that the `main` branch is tracking `origin/main`, and from the second command we can see that `origin` indeed refers to GitHub.

-   Third, you need a GitHub [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) (PAT) and you need to store it in the git credential store on your machine. You can use [`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html) to add the token to the git credential store. If you cannot use the git credential store for some reason (e.g. you are on Linux, and there is no good credential helper available for you), you can also set the `GITHUB_PAT` environment variable to your GitHub PAT in the `~/.Renviron` file.

## Set up R-hub v2

Once you took care of all these requirements, setting up R-hub v2 for your package goes like this.

### STEP 1: install the rhub package

Install the rhub package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"rhub"</span><span class='o'>)</span></span></code></pre>

</div>

### STEP 2: add the R-hub v2 workflow

In your local git clone, switch to your default git branch and call `rhub::rhub_setup()`. This adds a GitHub Actions workflow to your local repository. Push this change to GitHub, into your default git branch.

`rhub::rhub_setup()` guides you through the process:

``` r
rhub::rhub_setup()
```

<div class="highlight">

<div class="asciicast" style="color: #172431;font-family: 'Fira Code',Monaco,Consolas,Menlo,'Bitstream Vera Sans Mono','Powerline Symbols',monospace;line-height: 1.300000">

<pre>
Setting up R-hub v2.                                                            
<span style="color: #859900;">✔</span> Found R package at <span style="color: #268BD2;">/private/tmp/cli</span>.                                          
<span style="color: #859900;">✔</span> Found git repository at <span style="color: #268BD2;">/private/tmp/cli</span>.                                     
<span style="color: #859900;">✔</span> Created workflow file <span style="color: #268BD2;">/private/tmp/cli/.github/workflows/rhub.yaml</span>.           
                                                                                
Notes:                                                                          
<span style="color: #2AA198;">•</span> The workflow file must be added to the <span style="font-style: italic;">default</span> branch of the GitHub           
  repository.                                                                   
<span style="color: #2AA198;">•</span> GitHub actions must be enabled for the repository. They are disabled for      
  forked repositories by default.                                               
                                                                                
Next steps:                                                                     
<span style="color: #2AA198;">•</span> Add the workflow file to git using `git add &lt;filename&gt;`.                      
<span style="color: #2AA198;">•</span> Commit it to git using `git commit`.                                          
<span style="color: #2AA198;">•</span> Push the commit to GitHub using `git push`.                                   
<span style="color: #2AA198;">•</span> Call `rhub::rhub_doctor()` to check that you have set up R-hub correctly.     
<span style="color: #2AA198;">•</span> Call `rhub::rhub_check()` to check your package.                              
</pre>

</div>

</div>

(If you want to run checks on another branch, you need to add this workflow to that branch as well, manually or with `rhub::rhub_setup()`.)

### STEP 3: check your setup

Call `rhub::rhub_doctor()` to check that everything is set up correctly:

``` r
rhub::rhub_doctor()
```

<div class="highlight">

<div class="asciicast" style="color: #172431;font-family: 'Fira Code',Monaco,Consolas,Menlo,'Bitstream Vera Sans Mono','Powerline Symbols',monospace;line-height: 1.300000">

<pre>
<span style="color: #859900;">✔</span> Found R package at <span style="color: #268BD2;">/private/tmp/cli</span>.                                          
<span style="color: #859900;">✔</span> Found git repository at <span style="color: #268BD2;">/private/tmp/cli</span>.                                     
<span style="color: #859900;">✔</span> Found GitHub PAT.                                                             
<span style="color: #859900;">✔</span> Found repository on GitHub at <span style="font-style: italic;color: #268BD2;">&lt;https://github.com/r-lib/cli&gt;</span>.                 
<span style="color: #859900;">✔</span> GitHub PAT has the right scopes.                                              
<span style="color: #859900;">✔</span> Found R-hub workflow in default branch, and it is active.                     
→ WOOT! You are ready to run `rhub::rhub_check()` on this package.              
</pre>

</div>

</div>

### STEP 4: run checks

If `rhub::rhub_doctor()` did not find any issue, then you are ready to run checks with [`rhub::rhub_check()`](https://r-hub.github.io/rhub/reference/rhub_check.html). It goes like this:

``` r
rhub::rhub_check()
```

<div class="highlight">

<div class="asciicast" style="color: #172431;font-family: 'Fira Code',Monaco,Consolas,Menlo,'Bitstream Vera Sans Mono','Powerline Symbols',monospace;line-height: 1.300000">

<pre>
<span style="color: #859900;">✔</span> Found git repository at <span style="color: #268BD2;">/private/tmp/cli</span>.                                     
<span style="color: #859900;">✔</span> Found GitHub PAT.                                                             
                                                                                
Available platforms (see `rhub::rhub_platforms()` for details):                 
                                                                                
 1 [VM] <span style="font-weight: bold;color: #268BD2;">linux</span>          R-* (any version)                ubuntu-latest on GitHub 
 2 [VM] <span style="font-weight: bold;color: #268BD2;">macos</span>          R-* (any version)                macos-latest on GitHub  
 3 [VM] <span style="font-weight: bold;color: #268BD2;">macos-arm64</span>    R-* (any version)                macos-14 on GitHub      
 4 [VM] <span style="font-weight: bold;color: #268BD2;">windows</span>        R-* (any version)                windows-latest on GitHu 
 5 [CT] <span style="font-weight: bold;color: #268BD2;">atlas</span>          R-devel (2024-04-10 r86396)      Fedora Linux 38 (Contai…
 6 [CT] <span style="font-weight: bold;color: #268BD2;">clang-asan</span>     R-devel (2024-04-10 r86396)      Ubuntu 22.04.4 LTS      
 7 [CT] <span style="font-weight: bold;color: #268BD2;">clang16</span>        R-devel (2024-04-09 r86391)      Ubuntu 22.04.4 LTS      
 8 [CT] <span style="font-weight: bold;color: #268BD2;">clang17</span>        R-devel (2024-04-09 r86391)      Ubuntu 22.04.4 LTS      
 9 [CT] <span style="font-weight: bold;color: #268BD2;">clang18</span>        R-devel (2024-04-09 r86391)      Ubuntu 22.04.4 LTS      
10 [CT] <span style="font-weight: bold;color: #268BD2;">donttest</span>       R-devel (2024-04-09 r86391)      Ubuntu 22.04.4 LTS      
11 [CT] <span style="font-weight: bold;color: #268BD2;">gcc13</span>          R-devel (2024-04-10 r86396)      Fedora Linux 38 (Contai…
12 [CT] <span style="font-weight: bold;color: #268BD2;">intel</span>          R-devel (2024-04-10 r86396)      Fedora Linux 38 (Contai…
13 [CT] <span style="font-weight: bold;color: #268BD2;">mkl</span>            R-devel (2024-04-10 r86396)      Fedora Linux 38 (Contai…
14 [CT] <span style="font-weight: bold;color: #268BD2;">nold</span>           R-devel (2024-04-10 r86396)      Ubuntu 22.04.4 LTS      
15 [CT] <span style="font-weight: bold;color: #268BD2;">nosuggests</span>     R-devel (2024-04-10 r86396)      Fedora Linux 38 (Contai…
16 [CT] <span style="font-weight: bold;color: #268BD2;">ubuntu-clang</span>   R-devel (2024-04-10 r86396)      Ubuntu 22.04.4 LTS      
17 [CT] <span style="font-weight: bold;color: #268BD2;">ubuntu-gcc12</span>   R-devel (2024-04-10 r86396)      Ubuntu 22.04.4 LTS      
18 [CT] <span style="font-weight: bold;color: #268BD2;">ubuntu-next</span>    R-4.4.0 beta (2024-04-09 r86391) Ubuntu 22.04.4 LTS      
19 [CT] <span style="font-weight: bold;color: #268BD2;">ubuntu-release</span> R-4.3.3 (2024-02-29)             Ubuntu 22.04.4 LTS      
20 [CT] <span style="font-weight: bold;color: #268BD2;">valgrind</span>       R-devel (2024-04-10 r86396)      Fedora Linux 38 (Contai…
                                                                                
Selection (comma separated numbers, 0 to cancel): 1, 5                          
                                                                                
<span style="color: #859900;">✔</span> Check started: linux, atlas (disillusive-gibbon).                             
  See <span style="font-style: italic;color: #268BD2;">&lt;https://github.com/r-lib/cli/actions&gt;</span> for live output!                   
</pre>

</div>

</div>

# The R Consortium runners

If you don't want to put your package on GitHub, you can still use the rhub package to run package checks on any supported platform using a shared pool of runners in the <https://github.com/r-hub2> GitHub organization, that belong to the R Consortium.

## Set up the RC runners

The process is similar to R-hub v1:

### STEP 1: install the rhub package

``` r
install.packages("rhub")
```

### STEP 2: get an R-hub token

Obtain a token from R-hub, to verify your email address:

    rc_new_token()

You do not need to do this, if you already submitted packages to a previous version of R-hub from the same machine, using the same email address. Call `rc_list_local_tokens()` to see the email addresses that you you already have tokens for on this machine.

### STEP 3: submit a check

Submit a check with

    rc_submit()

Select the platforms you want to use, and follow the instructions and the link provided to see your check results.

## Limitations of the RC runners

Using the R Consortium runners comes with some limitations.

-   You package will be public for the world, and will be stored in the <https://github.com/r-hub2> organization. Your check output and results will be public for anyone with a GitHub account. If you want to keep your package private, you can put it in a private GitHub repository, and use the `rhub_setup()` and `rhub_check()` functions instead of the RC runners.
-   The R Consortium runners are shared among all users, so you might need to wait for your builds to start.
-   You have to wait at least five minutes between submissions with `rc_submit()`.
-   Currently you need to create a GitHub account to see the check logs of your package. You don't need a GitHub account to submit the checks.

To avoid these limitations (except for the need for a GitHub account), put your package in a GitHub repository, and use the `rhub_setup()` and `rhub_check()` functions instead of `rc_submit()` and the R Consortium runners.

# Feedback

We believe that R-hub v2 is already working better than the previous version of R-hub, but you might still run into edge cases.

If you have question about R-hub, please use our [discussions forum on GitHub](https://github.com/r-hub/rhub/discussions).

If you found a bug, then please open an issue at [our issue tracker](https://github.com/r-hub/rhub/issues).

We hope that this resource will be useful for your R work!

