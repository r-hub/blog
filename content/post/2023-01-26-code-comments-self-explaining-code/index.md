---
slug: code-comments-self-explaining-code
title: "Why comment your code as little (and as well) as possible" 
authors: 
- Maëlle Salmon 
date: "2023-01-26" 
tags: 
- package development
- code style
output: hugodown::hugo_document
rmd_hash: 7e3813f1fa1bacf5

---

When I first started programming, I clearly remember feeling I had to add comments, that would repeat exactly what the code below was doing, as if it were the script for some sort of voice over. I want you to know like I now do that it's not the way to comment one's code. :sweat_smile:

An important goal of good code is to be readable so that future contributors can build with and upon it as needed. Good commenting is part of the toolset for reaching that goal. In this post we shall first present principles of code commenting, and then a few tips.

## Principles for commenting

Comment your code as little as possible. :wink: Now, this does not mean to not care for readability and clarity at all, on the contrary. Pack as much information as possible in the code itself. For instance, naming one variable well can allow you to skip telling the reader what it is.

The tidyverse style guide states ["use comments to explain the"why" not the "what" or "how""](https://style.tidyverse.org/functions.html#comments-1). The what and how should be deduced from your code.

In ["The Art of Readable Code"](https://www.goodreads.com/book/show/8677004-the-art-of-readable-code) by Dustin Boswell and Trevor Foucher, the chapter on knowing what to comment starts with the key idea "The purpose of commenting is to help the reader know as much as the writer did".

Code comments should be viewed as little flags, little alerts. There should be as few of them as possible. Otherwise, your reader will get used to ignoring them. Furthermore, you'll get extremely bored writing them. :zzz:

Example of a recently encountered useful comment:

    # This query can not be done via GraphQL, so have to use v3 REST API

Code comments should not be used as a band-aid for bad code design. If it's very difficult to explain a piece of code, possibly more time should be spent on said code. Or, you could add a comment... "#TODO fix code debt". :innocent:

## Tips for (not) commenting

### Name things well

Using concise but precise names will help make your code readable. In the book [The Programmer Brain](https://www.goodreads.com/book/show/57196550-the-programmer-s-brain), Felienne Hermans presents Feitelson's three-step model for better variable names:

> "- Select the concepts to include in the name." "- Choose the words to represent each concept." "- Construct a name using these words."

Isn't this a life-changing tip?

### Use helper functions or explaining variables

The post ["Explaining variable"](https://blog.thepete.net/blog/2021/06/24/explaining-variable/) by Pete Hodgson (found thanks to a [tweet by Jenny Bryan](https://twitter.com/JennyBryan/status/1412140590842597385)) was truly eye opening for me so I recommend reading it.

The principle is to replace a piece of code with a well named Boolean variable for instance, or a function.

Here's an example with a function. Instead of writing some code à la

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'>if</span> <span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&amp;&amp;</span> <span class='nf'><a href='https://rdrr.io/r/base/nchar.html'>nzchar</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>use_string</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

the idea is to write something like

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>is_non_empty_string</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&amp;&amp;</span> <span class='nf'><a href='https://rdrr.io/r/base/nchar.html'>nzchar</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='kr'>if</span> <span class='o'>(</span><span class='nf'>is_non_empty_string</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>use_string</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span></code></pre>

</div>

where `is_non_empty_string()` could even be defined in a separate R script (called `utils-blabla.R` or so).

### Wrap external functions with a nicer interface

This is very related to the previous tip. Say you want to use a function with an unclear name. Do not hesitate to wrap it in a function with a better name if you think it'll improve readability. (You can also use this technique to switch the argument order.)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># in utils.R</span></span>
<span><span class='nv'>remove_extension</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'>tools</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/tools/fileutils.html'>file_path_sans_ext</a></span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span></span>
<span></span>
<span><span class='c'># in other files</span></span>
<span><span class='nf'>remove_extension</span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span></span></code></pre>

</div>

### Think twice before adding a comment on your own PR

In my own experience, aspects I want to add in a line comment on a GitHub Pull Request are often prime content for actual code comments (or a reason for refactoring my code!). It's not always true, but I try to pay attention to whether the comment should stay in the GitHub history only, or alongside the code.

### Have someone review your code

As much as you try to think about what a collaborator (or future you) would like to know when reading the code, it's handy to have an actual collaborator tell you where a comment might be warranted. The collaborator might not ask for a comment, but they might ask a question whose answer should be tracked in the code.

### Spare no effort on roxygen2 comments

*Thanks to [Mark Padgham](https://mpadge.github.io/) for insisting on this subsection!*

Some comments are special: the [roxygen2](https://roxygen2.r-lib.org/) comments that create documentation! Documentation is good!

Even internal functions can be documented using the same syntax, although you'll want to add the `#' @NoRd` tag for making sure no manual page is created. This convention is encouraged in the [rOpenSci packaging guide](https://devguide.ropensci.org/building.html#roxygen2-use) and in the [Tidyverse style guide](https://style.tidyverse.org/documentation.html#internal-functions).

### Use comments for the script table of contents

In RStudio IDE at least, there's an outline on the right of the script that you can expand to navigate the code. Functions are used for organization, but you can also add comments like

``` r
# header level 1 ----
bla

## header level 2 ----
blop
```

to have "header level 1" and "header level 2" appear in the outline. Having an explicit structure can help code readers.

## Conclusion

In this post, I explained why to comment your code as little (and as well!) as possible, with a few ideas of how to do that. I'd really recommend reading ["The Art of Readable Code"](https://www.goodreads.com/book/show/8677004-the-art-of-readable-code) if you can get your hands on a copy. Furthermore, unsurprisingly, practice helps, I myself need a lot more of it. Feel free to comment :wink: with your own commenting tricks.

