---
slug: jarl
title: "Refactoring with Jarl: a coffee chat" 
authors: 
- Hannah Frick
- Maëlle Salmon
date: "2026-06-02" 
tags: 
- package development
- programming
output: hugodown::hugo_document
rmd_hash: 78d1adb373359c68

---

{{< figure src="meme.png" alt="Cute kitten attacked by robots. The text says 'Everytime you use Claude for something a CLI can do, a kitten dies'." >}}

TL;DR, don't let your friends use LLMs for finding useless code in a project! Using [Jarl](https://jarl.etiennebacher.com/) instead is cheaper, more reliable, and won't kill any kitten.

We (Hannah and Maëlle) share an appreciation for the unglamorous maintenance work we call upkeep. So when Claude highlighted some [dead](https://github.com/tidymodels/tune/commit/5b4d63b58bd496e6c2809a5444b6ab119ae14f37) [code](https://github.com/tidymodels/tune/commit/16766b32ae1157425b124a70ec0bd64246e24c7f) in the tune package to Hannah, it was worth a mention during a chat. This led to Maëlle recommending Etienne Bacher's [Jarl](https://jarl.etiennebacher.com/), a fast linter for R written in Rust that can, among other things, detect unused functions.

Motivated by this conversation among other things, Maëlle wrote a [whole blog post](https://ropensci.org/blog/2026/04/02/tree-sitter-overview/) about Jarl and other tooling for R based on tree-sitter, including the above meme.

So naturally, when you get called out in a custom meme, you listen. :smile_cat: So here's the long(er) form of "Use Jarl!", from the following sweep through the [parsnip](https://parsnip.tidymodels.org/) package by Hannah, with commentary from Maëlle.

*Many thanks to [Etienne Bacher](https://www.etiennebacher.com/) for reviewing this post!*

## How Hannah used Jarl

I have the [Jarl extension](https://jarl.etiennebacher.com/howto/editors) installed for my Positron but here I used the command line interface (CLI) of Jarl. I started off with running this [command](https://jarl.etiennebacher.com/by-example#lint-a-directory) in the terminal:

``` sh
jarl check .
```

but that gave me too much output. :sweat_smile:

It did include a helpful hint though, something like:

``` sh
── Summary ──────────────────────────────────────
Found 296 errors.
3 fixable with the `--fix` option.
More than 15 errors reported, use `--statistics` to get the count by rule.
```

So one more time, with the `--statistics` option, to get an overview of what Jarl all flagged. The output (here with made up numbers) looked something like

``` sh
jarl check . --statistics
  132 [ ] implicit_assignment
  109 [ ] internal_function
   34 [ ] vector_logic
   13 [ ] unused_function
    7 [*] numeric_leading_zero
    1 [*] any_is_na

Rules with `[*]` have an automatic fix.
```

Now that gives me a better overall picture. *Maëlle: I really enjoyed learning about this `--statistics` flag, and followed the same strategy when I ran Jarl on the [igraph R package](https://github.com/igraph/rigraph/issues/2652)!*

I could have run `jarl check . --fix` to fix everything with an automatic fix but I wanted to learn a bit more about the rules to see if I wanted to apply them. So I worked my way through one rule at a time, with one git commit at a time. You can [select rules](https://jarl.etiennebacher.com/by-example#select-or-ignore-specific-rules) like so:

``` sh
jarl check . --select any_is_na
```

This separation of changes by rule also made it easier to review changes: one topic per commit. *Maëlle: in igraph, I created one **PR** per rule or group of rules.*

I first went through the ones with automatic fixes, then the ones without. The result of the clean-up: <https://github.com/tidymodels/parsnip/pull/1356> *Maëlle: in igraph, I went through rules starting with the ones with the least violations, ending with the ones that had the most hits.*

parsnip has been around the block a few times and had accumulated a few functions flagged by Jarl as unused. I spotted `release_bullets()` in the list which I know we want to keep.[^1] We use it *for* parsnip in the release process but we don't use it *in* parsnip. I wasn't expecting Jarl to catch onto this difference so I decided to review the list of flagged functions separately and split that off into its own issue (and PR). I ended up keeping one other function that was part of a set of functions provided in a standalone file but I removed the other ones.

No kittens were hurt!

## Why use Jarl for refactoring

Obviously, because we are telling you you should! More seriously: Jarl is fast and free!

And here are a few more reasons beyond our success stories :grin::

### Jarl will find small smelly things

For instance, the [`outer_negation`](https://jarl.etiennebacher.com/rules/outer_negation) rule helps improve readability: `!all(x)` is easier to understand than `any(!x)`. In igraph for example, thanks to that rule we [changed](https://github.com/igraph/rigraph/pull/2666)

``` r
any(!names(options) %in% names(defaults))
```

*Any names of options not in names of defaults* (and actually a tad worse since we do not use `%notin%` yet, new in [R 4.6.0](https://cran.r-project.org/doc/manuals/r-release/NEWS.html))

into

``` r
!all(names(options) %in% names(defaults))
```

*Not all names of options in names of defaults*.

See also the rule in action in [parsnip](https://github.com/tidymodels/parsnip/pull/1356/changes/8029bb8eb9acab8beef75975fd6675e38a70f802).

Generally, Jarl will make the codebase less [smelly](https://github.com/jennybc/code-smells-and-feels).

### Jarl will find unused functions

It's very easy for a package to accumulate functions that are now useless, sort of historical artefacts. And as they're unused you might not even stumble upon them by chance. Jarl will flag them for you!

If Jarl notices such a function, check it is actually unused. If the function is actually useful, you might want to add an [exception comment](https://jarl.etiennebacher.com/howto/suppression-comments) or some [rule-specific configuration](https://jarl.etiennebacher.com/reference/config-file#unused_function).

### Jarl will find duplicated function definitions

Also a problem that happens in a package that wasn't born yesterday! In this case, you need to pick one definition. [Example in parsnip](https://github.com/tidymodels/parsnip/issues/1360). Deleting unused lines is very satisfying.

### Jarl will detect unreachable code

For instance, code that comes after a [`return()`](https://rdrr.io/r/base/function.html) or a [`stop()`](https://rdrr.io/r/base/stop.html) in a function. Sometimes, you can simply delete that code (again, a feel good move!). Other times, the check is an opportunity for [targeted refactoring](https://github.com/tidymodels/parsnip/issues/1359)!

### Jarl can check your testthat code

As a bonus, because these rules are turned off by default, you can run

    jarl check . --select TESTTHAT

This will apply all rules from the [testthat group](https://jarl.etiennebacher.com/rules) that help you use more specific expectations. For instance, `expect_equal(length(x), 2)` should be `expect_length(x, 2)`. All these rules come with automatic fixes!

Example in [parsnip](https://github.com/tidymodels/parsnip/pull/1379), example in [igraph](https://github.com/igraph/rigraph/pull/2670).

Should your package depend on dplyr, there's a group of (currently two) rules for this as well!

## Conclusion

Automatic tools are extremely useful for guiding upkeep work. Thinking *"let me clean up this repo"* can be daunting :scream:, tools like Jarl provide a roadmap! They let you fix obvious problems, and at the same time, they can make you read some dusty corners of your codebase. Hannah's work on parsnip inspired Maëlle to run Jarl on igraph (influencer influenced back!), and she too can confirm it was both useful and satisfying. Thanks Etienne for that cool tool!

Note that you could run Jarl checks manually as we did, or you could tell a LLM to run Jarl. To quote Hannah's colleague [Emil Hvitfeldt](https://emilhvitfeldt.com/post/ast-grep-r-claude-code/), *"When coding or using coding agents, one way to improve your workflow is by using CLI tools with a very clear focus."*. 🫡

What's even better with Jarl is that it is actively developed! The [open PR](https://github.com/etiennebacher/jarl/pull/454) to add a check for unused *function arguments* is very exciting in particular!

[^1]: This inspired an [issue](https://github.com/etiennebacher/jarl/issues/497). As noted there, for this function one should add an [exception as a comment](https://jarl.etiennebacher.com/howto/suppression-comments) or in the [config file](https://jarl.etiennebacher.com/reference/config-file#unused_function).

