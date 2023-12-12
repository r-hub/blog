---
slug: cliff-notes-about-cli
title: "Cliff notes about the cli package" 
authors: 
- Maëlle Salmon
- Athanasia Mo Mowinckel
date: "2023-11-30" 
tags: 
- package development
- code style
output: hugodown::hugo_document
rmd_hash: 381d73344e8f4ee1

---

We've both coincidentally dipped our toes in the wonderful world of pretty messaging with [cli](https://cli.r-lib.org/).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_alert.html'>cli_alert_success</a></span><span class='o'>(</span><span class='s'>"marvellous package adopted!"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> marvellous package adopted!</span></span>
<span></span></code></pre>

</div>

In this post, we transform the hurdles we encountered in a series of tips so that your own journey might be slightly smoother, and also to encourage you to try out cli in your package!

*This post was featured on the [R Weekly highlights podcast](https://rweekly.fireside.fm/145) hosted by Eric Nantz and Mike Thomas.*

## cli is the thing for package interfaces now!

You can view cli as a domain-specific language (DSL) for command-line interfaces (CLI): Just like tidyverse makes your data pipelines easier to construct and more readable, cli makes your communication producing code simpler to write.

cli deals with pesky details and we package developers only need to use the high-level interface. Mo has previously got lost in the rabbit hole of making prettier outputs, and thinks noone else should ever have to do that! As an example, text is automatically wrapped to the terminal width.

cli is truly feature-rich, for instance allowing you to make URLs in messages clickable and code in messages runnable at a click!

cli is part of the [tidyverse capsule wardrobe](https://github.com/r-lib/usethis/pull/1423/files), which shows how important it's becoming, near other important tools such as withr and rlang.

### What if you were making pretty interfaces with usethis?

Is your package using `usethis::ui_` functions? If you have time for a bit of [upkeep](https://www.tidyverse.org/blog/2023/06/spring-cleaning-2023/), you can do the switch from that to cli by reading and following the [cli article on the topic](https://cli.r-lib.org/articles/usethis-ui.html). Do not discover this article *well after* starting a transition, cough (that's what happened to Maëlle).

## cli formatting: all the curly braces

You'll probably end up calling various cli functions whose names start with `cli_` to create [semantic elements](https://cli.r-lib.org/reference/index.html#semantic-cli-elements): headers, lists, alerts, etc. What do they expect as inputs?

cli has a glue-like syntax: if there's an object called say `thing` and you want to use it in a message, you use `{thing}`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>thing</span> <span class='o'>&lt;-</span> <span class='s'>"a string"</span></span>
<span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_li.html'>cli_li</a></span><span class='o'>(</span><span class='s'>"Hey you provided this text: &#123;thing&#125;!"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; • Hey you provided this text: a string!</span></span>
<span></span></code></pre>

</div>

Then, you can use classes in messages. Classes, like classes in CSS, help format the elements. For instance if `thing` is a variable, we write:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>thing</span> <span class='o'>&lt;-</span> <span class='s'>"a string"</span></span>
<span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_li.html'>cli_li</a></span><span class='o'>(</span><span class='s'>"Hey you provided this text: &#123;thing&#125; (&#123;.var thing&#125;)!"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; • Hey you provided this text: a string (`thing`)!</span></span>
<span></span></code></pre>

</div>

Curly braces can be nested if you are using a class and glue-like syntax at the same time:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>variable_name</span> <span class='o'>&lt;-</span> <span class='s'>"blop"</span></span>
<span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_li.html'>cli_li</a></span><span class='o'>(</span><span class='s'>"Hey you entered &#123;.var &#123;variable_name&#125;&#125;!"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; • Hey you entered `blop`!</span></span>
<span></span></code></pre>

</div>

See the [full list of classes](https://cli.r-lib.org/reference/inline-markup.html#classes) in cli docs. To mention only a few of them (you might notice clickability is a star here...if the terminal supports ANSI hyperlinks to runnable code (for instance, RStudio IDE)):

-   `.run` means that the code in the message will be clickable! Best code hints ever!
-   `.help` will have a clickable link to a help topic.
-   `.file` will have a clickable link to a file.
-   `.obj_type_friendly`, for instance `{.obj_type_friendly {mtcars}}`, prints the object type in, well, a friendly way (thanks to [Jon Harmon](https://github.com/jonthegeek) for reminding us about this one).

It's well worth going through the list of classes at least once.

### What if my string contains curly braces?

If you want to actually communicate something with curly braces, you'll need to [double them to escape them](https://cli.r-lib.org/reference/inline-markup.html#escaping-and-).

### What about plural?

cli has support for [pluralization](https://cli.r-lib.org/reference/pluralization.html) (presumably only for 0/1/more than one, not for [more complex forms of pluralization](https://michaelchirico.github.io/potools/articles/translators.html#plurals)).

### How to add a custom class / theme

How to define a custom class or theme seems to be a bit under-documented at the moment, which is unsurprising as it's an advanced topic. Jenny Bryan [assumes](https://mastodon.social/@jennybryan@fosstodon.org/110675320334403080) adding a custom class needs to happen as part of a theme, which she does in [googlesheets4](https://github.com/tidyverse/googlesheets4/blob/fdb187643b324cd607f71cefa133bf49924f6e49/R/utils-ui.R#L1-L16). Michael McCarthy [recommends](https://mastodon.social/@mccarthymg@fosstodon.org/110673498809652527) looking at what cli itself does.

### What about dark themes?

Together, we cover both sides of having dark (Mo) and light (Maëlle) themes in RStudio. It would be easy to assume that this all would not work well on dark theme, but Mo can tell you that it all works seamlessly. The output colors change to be dark friendly! For that reason, user-overrides of colors can be a tricky thing, as you are no longer relying on the excellent tooling of cli to make sure this works in both light and dark mode.

An user can define their own themes, for instance putting this in their profile to make variables underlined:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'># This goes in your .Rprofile </span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>cli.user_theme <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>.var <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='s'>"text-decoration"</span> <span class='o'>=</span> <span class='s'>"underline"</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span></span>
<span><span class='c'># not needed if the previous line is in your .Rprofile </span></span>
<span><span class='c'># we do this here to expose the effect in this post directly</span></span>
<span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/start_app.html'>start_app</a></span><span class='o'>(</span><span class='o'>)</span> </span>
<span></span>
<span><span class='c'># Code is underlined!</span></span>
<span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_text.html'>cli_text</a></span><span class='o'>(</span><span class='s'>"Don't call a variable &#123;.var variable&#125;!"</span><span class='o'>)</span></span></code></pre>

</div>

### How to turn off colors

cli respects the [nocolor standard](https://cli.r-lib.org/articles/cli-config-user.html?q=no#no_color), therefore an user can set the environment variable `NO_COLOR` to any string in order to not get colored output.

## cli for expressing what?

### Advertise side effects

One of the things the `usethis::` functions do so well, it be very verbose of that they are doing.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>pkg_dir</span> <span class='o'>&lt;-</span> <span class='nf'>withr</span><span class='nf'>::</span><span class='nf'><a href='https://withr.r-lib.org/reference/with_tempfile.html'>local_tempdir</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='nf'>usethis</span><span class='nf'>::</span><span class='nf'><a href='https://usethis.r-lib.org/reference/create_package.html'>create_package</a></span><span class='o'>(</span><span class='nv'>pkg_dir</span>, open <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Setting active project to <span style='color: #0000BB;'>'/tmp/Rtmpll7FtZ/file522e43136aa8'</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Creating <span style='color: #0000BB;'>'R/'</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Writing <span style='color: #0000BB;'>'DESCRIPTION'</span></span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #0000BB;'>Package</span>: file522e43136aa8</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>Title</span>: What the Package Does (One Line, Title Case)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>Version</span>: 0.0.0.9000</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>Authors@R</span> (parsed):</span></span>
<span><span class='c'>#&gt;     * Maëlle Salmon &lt;msmaellesalmon@gmail.com&gt; [cre, aut] (&lt;https://orcid.org/0000-0002-2815-0399&gt;)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>Description</span>: What the package does (one paragraph).</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>License</span>: MIT + file LICENSE</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>Encoding</span>: UTF-8</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>Roxygen</span>: list(markdown = TRUE)</span></span>
<span><span class='c'>#&gt; <span style='color: #0000BB;'>RoxygenNote</span>: 7.2.3</span></span>
<span></span><span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Writing <span style='color: #0000BB;'>'NAMESPACE'</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> Setting active project to <span style='color: #0000BB;'>'&lt;no active project&gt;'</span></span></span>
<span></span></code></pre>

</div>

This is great information so the user can build an understanding of what a function they ran actually does. This is particularly important for functions that do something with a users settings or file system in some persistent way, as it makes it possible to back-track what has been done and alter it at need. See the the [tidy design guide](https://design.tidyverse.org/spooky-action.html?q=cli#advertise-the-side-effects) for more information on this subject.

### Progress

As seen when installing packages with [pak](https://pak.r-lib.org/)! Not only does cli support progress bars, it [documents how to create them in two articles](https://cli.r-lib.org/articles/progress.html)!

#### How does it look in logfiles?

It's likely not what you are after for a logfile, as each new update will create another line. The cli output in non-interactive sessions or to file is discussed in the [article about advanced progress bar topics](https://cli.r-lib.org/articles/progress-advanced.html#non-interactive-r-sessions).

### Error messages

You can use [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html) instead of [`stop()`](https://rdrr.io/r/base/stop.html) for errors, as recommended by the [tidyverse style guide](https://style.tidyverse.org/error-messages.html). Note that using this function necessitates your package importing rlang. A neat thing about this (and companions [`cli::cli_alert()`](https://cli.r-lib.org/reference/cli_alert.html) and [`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)), is that you can construct very complex messages through syntax seen throughout the cli package. For instance, providing a vector of text will create multi-line messages, and giving the elements specific names can turn them into list types.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_abort.html'>cli_abort</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>    <span class='s'>"This is a complex error message."</span>,</span>
<span>    <span class='s'>"The input is missing important things:"</span>,</span>
<span>    <span class='s'>"*"</span> <span class='o'>=</span> <span class='s'>"important thing 1"</span>, <span class='c'># bullet point</span></span>
<span>    <span class='s'>"*"</span> <span class='o'>=</span> <span class='s'>"important thing 2"</span>, <span class='c'># bullet point</span></span>
<span>    <span class='s'>"To learn more about these see the &#123;.url www.online.docs&#125;"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> This is a complex error message.</span></span>
<span><span class='c'>#&gt; The input is missing important things:</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> important thing 1</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> important thing 2</span></span>
<span><span class='c'>#&gt; To learn more about these see the <span style='color: #0000BB; font-style: italic;'>&lt;www.online.docs&gt;</span></span></span>
<span></span></code></pre>

</div>

## How to make cli quiet or not

You can choose to silence/shush/muffle cli messages!

For cli functions whose name starts with `cli_`, see the [docs](https://cli.r-lib.org/articles/semantic-cli.html#cli-messages).

Let's try an example.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_li.html'>cli_li</a></span><span class='o'>(</span><span class='s'>"hello"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; • hello</span></span>
<span></span><span><span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/local_options.html'>local_options</a></span><span class='o'>(</span>cli.default_handler <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>msg</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span><span class='o'>(</span><span class='kc'>NULL</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'>cli</span><span class='nf'>::</span><span class='nf'><a href='https://cli.r-lib.org/reference/cli_li.html'>cli_li</a></span><span class='o'>(</span><span class='s'>"hello"</span><span class='o'>)</span></span></code></pre>

</div>

This can be useful in tests for instance! Who wants to be looking at a wall of cli output when debugging one's tests.

For other functions, probably write your own wrapper and make it responsive to an option (rather than arguments in all functions, see [discussion](https://github.com/ropensci/dev_guide/issues/603)), like what happens in usethis with the `usethis.quiet` option.

Speaking of options, let's remind you about [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html) whose output is controllable via the `rlang_interactive` global option.

### How to test cli output

You should probably look into [snapshot tests](https://testthat.r-lib.org/articles/snapshotting.html), maybe in combination with [`cli::test_that_cli()`](https://cli.r-lib.org/reference/test_that_cli.html).

## Conclusion

In this post we presented what we know about cli: in short, it's a fantastic package for building informative and pretty command-line interfaces, and its docs are extensive!

