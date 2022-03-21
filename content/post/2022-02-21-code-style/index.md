---
slug: code-style
title: "Coding style, coding etiquette" 
authors: 
- Maëlle Salmon 
- Christophe Dervieux
date: "2022-03-21" 
tags: 
- package development 
output: hugodown::hugo_document
rmd_hash: 075070453b28bada

---

Do you indent your code with [one tab, two spaces](https://www.youtube.com/watch?v=SsoOG6ZeyUI), or eight spaces? Do you feel strongly about the location of the curly brace closing a function definition? Do you have naming preferences? You probably have picked up some habits along the way. In any case, having some sort of consistency in coding style will help those who read the code to understand, fix or enhance it. In this post, we shall share some resources about coding style, useful tools, and some remarks on etiquette.

## What *is* coding style?

Coding style is a set of rules about well, aesthetics (aligning and code spacing) but also naming (of variables, functions, etc.), commenting, structuring (e.g. avoiding complex logic), etc. These rules help with better code clarity and collaboration.

Sometimes somes rules are enforced by the language (indentation in python), sometimes the language is quite loose, like... R where you can add a lot of spaces, and so in that case more style guides exist.

Coding style has an universal goal: making your code easier to understand and maintain, for you later and for your code collaborator. Having a team/company style guide is common practice. Major Tech Companies have style guides, e.g. [Google](https://google.github.io/styleguide/)[^1].

However there is no "right" coding style as the "correct" choice depends on personal preferences, and the [constraints at hand](https://www.heltweg.org/posts/who-wrote-this-shit/).

## Resources

One way to develop a sense of coding style is to read a lot of code, but where to learn about coding style explicitly?

### Specific R resources

The most popular, or at least most documented style guide out there is the [tidyverse style guide](https://style.tidyverse.org).

Some other style preferences include

-   [Mark Padgham's spacing preferences](https://docs.ropensci.org/pkgcheck/CONTRIBUTING.html#development-guidelines);
-   [Roger Peng's 8-space indentations](https://simplystatistics.org/posts/2018-07-27-why-i-indent-my-code-8-spaces/);
-   Yihui Xie's preference for equal sign assignments (as presented in this [issue comment](https://github.com/Robinlovelace/geocompr/issues/319#issuecomment-427376764));
-   [Google R Style guide](https://google.github.io/styleguide/Rguide.html), a fork of Tidyverse style guide but with variations e.g. a preference for BigCamelCase for function names.
-   [The style guide of the mlr organziation (for machine learning in R)](https://github.com/mlr-org/mlr3/wiki/Style-Guide).
-   Your own preferences? Yes it's fine to have some as long as your team agrees. :wink: Feel free to mention your preferences in the comments. This is a non-judgmental space (or indent :grin:).

Most style guides will have some preferences regarding code spacing, or "breathing".

{{< tweet 1504499938302046214 >}}
{{< tweet 1486396341542481922 >}}

Another excellent resource is [Jenny Bryan's useR! 2018 keynote *"Code Smells and Feels"*](https://github.com/jennybc/code-smells-and-feels). It's more focused on code structure and commenting.

### General resources

The resources listed below are books without a free version online. Hopefully libraries and used book stores can help.

{{< tweet 951152160435310592 >}}

-   [The Art of Readable Code by Dustin Boswell, Trevor Foucher](https://www.goodreads.com/book/show/8677004-the-art-of-readable-code) can be (even for those who do not view it as a beach read :cocktail:), a short, light and actionable read.

-   [Refactoring by Martin Fowler](https://www.goodreads.com/book/show/44936.Refactoring) is an inspiration for the aforementioned keynote talk by Jenny Bryan. It defines code smells and refactoring techniques. See also the blogpost ["Explaining Variable" by Pete Hodgson](https://blog.thepete.net/blog/2021/06/24/explaining-variable/) (heard of via [Jenny Bryan](https://twitter.com/JennyBryan/status/1412140590842597385)).

-   [The Programmer's Brain by Felienne Hermans](https://www.goodreads.com/book/show/57196550-the-programmer-s-brain) gives a perspective on e.g. how code smells or bad naming influence cognitive load. It is full of practical tips.

## Tools

To begin with the most important, or basic, tool here is probably to use an IDE, integrated development environment, like RStudio IDE or VSCODE, as IDEs come with, or easily support, code diagnostic tools.

### Diagnostic tools

#### lintr

Linting tools will indicate errors and potentially style preference violations.

The [lintr R package by Jim Hester](https://github.com/r-lib/lintr) has a lot of useful linters such as whether code is commented, whether lines are too long etc.

It is pretty common to find *linting tools* in all editors (VSCODE and others) and for most languages. To set up lintr with your code editor refer to [its docs](https://github.com/r-lib/lintr#editors-setup). Unless you have RStudio IDE and linting is the one included already in the IDE (for errors mainly only, not style preference). If you use VSCODE, [vscode-R](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r) extension includes diagnostic tool - see <https://github.com/REditorSupport/vscode-R/wiki/R-Language-Service#diagnostics>.

Some teams likes to run diagnostic tools as part of their Continuous Integration (CI) workflow. lintr can be used in this context as part of tests suits with testthat - see [`expect_lint()`](https://rdrr.io/cran/lintr/man/expect_lint.html)

#### pkgcheck

One of the aspects checked by rOpenSci Mark Padgham's [pkgcheck package](https://docs.ropensci.org/pkgcheck/index.html) is *"Left-assign operators must be used consistently throughout all code (so either all = or all \<-, but not a mixture of both)."*.

### Fixing tools

<div class="alert alert-primary">

With fixing tools, your original source code will be modified. It is really advised to use version control with your project. If you're nervous about getting started refer to

-   ["Excuse me, do you have a moment to talk about version control?" by Jenny Bryan](https://peerj.com/preprints/3159/);
-   ["Reflections on 4 months of GitHub: my advice to beginners" by Suzan Baert](https://suzan.rbind.io/2018/03/reflections-4-months-of-github/);
-   ["Happy Git and GitHub for the useR"](https://happygitwithr.com/) by Jenny Bryan, the STAT 545 TAs, Jim Hester.

</div>

#### RStudio IDE shortcut for code indentation

In RStudio IDE selecting code and hitting `Ctrl + I` will re-indent code for you!

#### styler

The [styler R package](https://styler.r-lib.org) automatically reformats code. Its documentation includes a handy vignette on [customizing styler](https://styler.r-lib.org/articles/customizing_styler.html), for when preferences differ from the default. Examples:

-   the [tiny spaceout R package](https://github.com/ropensci-review-tools/spaceout) that adds spaces between code references.
-   the [grkstyle R package](https://github.com/gadenbuie/grkstyle) holding Garrick Aden-Buie's personal preferences.
-   the [styler.mlr R package](https://github.com/mlr-org/styler.mlr) implementing the mlr style guide.

The styler package documents some [third-part integration](https://styler.r-lib.org/articles/third-party-integrations.html): you don't have to remember to run styler manually. In particular, to use styler on its own CI workflow on GitHub Actions: <https://github.com/r-lib/actions/tree/v2-branch/examples#style-package>

#### formatr R package

The [formatr R package](https://yihui.org/formatr/) formats R code automatically too, but with less customization possibilities.

For more tools helping with code improvements, refer to the [R-hub blog post "Workflow automation tools for package developers"](/2020/04/29/maintenance/) including tips on *when* to use such tools.

#### Other languages

For Python there's [black](https://pypi.org/project/black/).

## A special note on ( R ) Markdown styling

When writing this post in Markdown we hit return after each sentence or even more regularly. This does not influence how the resulting post looks like but it makes reviewing easier as GitHub PR comments and change suggestions are by line! See more [rationale about this](https://cirosantilli.com/markdown-style-guide/#line-wrapping).

The new [Visual Editor in RStudio](https://rstudio.github.io/visual-markdown-editing/) is a way to enforce a common style in Markdown file. It can be configured, e.g. regarding one line per sentence, so the the IDE automatically modifies source files which insure in collaboration than everyone will write the same.

The tools for styling in R can be used in R Markdown document thanks to [**knitr** `format` option which support **formatR** and **styler**](https://bookdown.org/yihui/rmarkdown-cookbook/opts-tidy.html).

## Etiquette

If you are a contributor to a codebase, you'll probably have to adapt your style to the maintainer's or maintainers' preferences. These preferences might be implicit (seen by reading existing code) or explicit (in a contributing guide). Now, depending on your relation to the maintainers (e.g. is it your first contribution), you might start a discussion about changing some of the conventions, perhaps changing their mind or reaching a compromise (assigning with `=`, but with spaces before and after each equal sign).

If you are the maintainer of a codebase, you'll need to be forgiving when stating your preferences and explaining how to implement them; or you might even want to take matters in your own hands and do some [restyling yourself](https://yihui.org/en/2018/11/cosmetic-changes/).

## Conclusion

In this post we shared documentation of and tooling for coding style. We hope it can help you write or advocate for more readable code. Practice makes perfect, so go forth and participate in code production and reviews. :wink:

[^1]: Note that the Google R style guide first inspired the tidyverse styleguide but now Google R style guide is derived from the tidyverse style guide. 

