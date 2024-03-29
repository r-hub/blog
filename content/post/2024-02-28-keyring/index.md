---
slug: key-advantages-of-using-keyring
title: "Key advantages of using the keyring package" 
authors: 
- Maëlle Salmon
date: "2024-02-28" 
tags: 
- package development
output: hugodown::hugo_document
rmd_hash: 01d7d32857428287

---

Does your package need the user to provide secrets, like API tokens, to work? Have you considered telling your package users about the keyring package, or even forcing them to use it?

The [keyring](https://keyring.r-lib.org/) package maintained by Gábor Csárdi is a package that accesses the **system credential store** from R: each operating system has a special place for storing secrets securely, that keyring knows how to interact with. The credential store can hold several **keyrings**, each **keyring** can be protected by a specific password and can hold several **keys** which are the **secrets**.

Why would one use keyring?

## A simple example

Let's exemplify the usage of keyring with the example of `mypkg::my_fun()` that needs an API key to work and expects it to be available as `Sys.getenv("MYSECRET")`. This is already a more secure approach that having the API key as an argument, which could lead to users writing their secret in their script, and from there maybe inadvertently sharing the script thus the secret.

### Without using keyring

1.  The user set an environment variable `MYSECRET="super-secret"`
    -   in a project-specific [`.Renviron`](https://rstats.wtf/r-startup#renviron), hopefully [.gitignored](https://usethis.r-lib.org/reference/use_git_ignore.html);
    -   or in the user `.Renviron`;
    -   or types `Sys.setenv(MYSECRET="super-secret")` in the console, hopefully not saving, not sharing `.Rhistory`.
2.  The package retrieves the secret with `Sys.getenv("MYSECRET")`.

### With keyring

1.  The user stores the secret, once and for all per computer, using `keyring::key_set("MYSECRET")`, typing interactively so nothing is recorded in `.Rhistory`.
2.  The user sets an environment variable with `Sys.setenv(MYSECRET = keyring::key_get("MYSECRET"))` in a script for instance.
3.  The package retrieves the secret with `Sys.getenv("MYSECRET")`.

Or, if you want the package users to be forced to use keyring, for instance like in the [ecmwfr package maintained by Koen Hufkens](https://bluegreen-labs.github.io/ecmwfr/#setup),

1.  The user stores the secret, once and for all per computer, using `keyring::key_set("MYSECRET")` (or a function of your package that wraps keyring calls), typing interactively so nothing is recorded in `.Rhistory`.
2.  The package retrieves the secret using keyring.

## Advantages of keyring

When storing a secret with keyring rather than in `.Renviron`, the secret has less chances to end up in the Git history, or screen-shared.

The keyring package works on Linux (desktop), Windows, macOS, and falls back to secret environment variables on [GitHub Actions](https://keyring.r-lib.org/#github).

A keyring can be locked and protected by a password, which might be one more barrier of protection. Otherwise, someone who logged into your computer session has access to your keyring secrets.

Using keyring to store secrets, rather than writing them in plain text somewhere, feels closer to using a [password manager](https://guide.rladies.org/organization/tech/security/#use-a-personal-password-manager)[^1], so might promote good habits more generally.

## Why mention keyring in your package docs?

Because otherwise, how will package users know about it? The keyring package is both rather low-level and... aimed at users, which is a weird spot. Package users do not necessarily trawl through repositories of the r-lib organization. :wink:

Examples of package docs mentioning the keyring package include the [opencage package](https://docs.ropensci.org/opencage/reference/oc_config.html#set-your-opencage-api-key) and the [babeldown package](https://docs.ropensci.org/babeldown/#api-key).

As mentioned earlier, you can even bake keyring calls into your package, as was done in the [ecmwfr package](https://bluegreen-labs.github.io/ecmwfr/), whose setup documentation explains how to save the necessary secret in a keyring. If your package provides a helper function for registering the secret, the user does not need to call keyring themselves directly.

## Related package: gitcreds

For storing Git credentials such as a GitHub PAT, see

-   [gitcreds](https://gitcreds.r-lib.org/) also maintained by Gábor Csárdi, which the GitHub API client [gh](https://gh.r-lib.org/) therefore [usethis](https://usethis.r-lib.org/) use.

-   [credentials](https://docs.ropensci.org/credentials/) maintained by Jeroen Ooms, which the Git client [gert](https://docs.ropensci.org/gert/) therefore usethis use.

## Conclusion

In this post we presented the keyring package, that allows to save secrets securely and then access them, all from R. If you are looking for more resources related to security and package development, refer to the ["Package Development Security Best Practices" chapter of the rOpenSci dev guide](https://devguide.ropensci.org/pkg_security.html).

Do you use keyring yourself? Do you recommend it to users of your packages?

[^1]: The keyring package does not interact with password managers, but there is an open issue related to [interacting with 1Password](https://github.com/r-lib/keyring/issues/123).

