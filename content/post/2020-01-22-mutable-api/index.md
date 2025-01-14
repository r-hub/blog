---
title: Objects that feel mutable in R
authors:
  - Maëlle Salmon
  - Gábor Csardi
date: '2020-01-22'
slug: mutable-api
tags:
  - package development
  - programming
output: 
  html_document:
    keep_md: true
---

In R, most often, to change an object, you need to re-assign its new value to it.
But sometimes, things feel different because objects are mutable or it seems they are, be it in base R code or in the code of packages.
Why and how to provide a mutable API/interface in R code?
In this blog post, we shall explore <s>a few odd examples</s> a few examples to better understand mutable APIs in R.

## Preamble: what do we mean by mutable?

### What is mutable

As explained in the [chapter "Names and values" of the Advanced R book by Hadley Wickham](https://adv-r.hadley.nz/names-values.html), in R, most objects are actually not mutable.
In particular, there's the [copy-on-modify behaviour](https://adv-r.hadley.nz/names-values.html#copy-on-modify).
The book has very clear diagrams showing how an object is bound to a name.
Often, when you think you're modifying an object,

``` r
x <- c(1, 7)
x[2] <- 2
```

a new object with a new value has been created and bound to the initial name.
The original object is unchanged, it's not mutable.
In the "Advanced R" book, a [subsection is dedicated to `tracemem()`](https://adv-r.hadley.nz/names-values.html#tracemem) and explains "Once you call that function with an object, you'll get the object's current address".

``` r
x <- c(1, 7)
tracemem(x)
```

```         
## [1] "<0x55d1fa6f6bb8>"
```

``` r
x[2] <- 2
```

```         
## tracemem[0x55d1fa6f6bb8 -> 0x55d1faa37298]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous>
```

We see that the address of "x" changes, a new object has been bound to that name, it's not the original object with the original address that has been modified.
Environments are one of the R object types that *are* mutable, they can be [modified in place](https://adv-r.hadley.nz/names-values.html#modify-in-place).

### What feels mutable

In this post, we're actually interested in any method or tool that makes something *feel* mutable.

We're used to code such as

``` r
# initial value
x <- 1
# change the value
x <- 2
```

But the code below also changes x without explicitely assigning a value to it!

``` r
x <- 1
length(x) <- 2
x
```

```         
## [1]  1 NA
```

One can say the code above is a bit odd.
This post is a collection of patterns that might feel odd.
:dizzy:

### What's not mutable and doesn't feel mutable either

data.frames are not mutable and one doesn't feel they are, even with `dplyr::mutate()`: you don't write

``` r
dplyr::mutate(df, newcol = 1)
```

to modify `df`, you need to write

``` r
df <- dplyr::mutate(df, newcol = 1)
```

:stuck_out_tongue_winking_eye:

## A replacement function in the urltools package

In the `urltools` package there are a few functions for getting or setting parts of an URL such as the fragment.

``` r
url <- "https://docs.r-hub.io/#package-builder"
urltools::fragment(url)
```

```         
## [1] "package-builder"
```

``` r
urltools::fragment(url) <- "intro"
url
```

```         
## [1] "https://docs.r-hub.io#intro"
```

``` r
urltools::fragment(url) <- NULL
url
```

```         
## [1] "https://docs.r-hub.io"
```

The original url value is not modified.
Below we use the [`tracemem()` function](https://adv-r.hadley.nz/names-values.html#tracemem).

``` r
url <- "https://docs.r-hub.io/#package-builder"
tracemem(url)
```

```         
## [1] "<0x55d1f99d5140>"
```

``` r
urltools::fragment(url) <- "intro"
```

```         
## tracemem[0x55d1f99d5140 -> 0x55d1f9f3a2a8]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous>
```

``` r
url
```

```         
## [1] "https://docs.r-hub.io#intro"
```

So how does the above work, exactly?
What's that `fragment` method?

``` r
getMethod(urltools::"fragment<-")
```

```         
## Method Definition (Class "derivedDefaultMethod"):
## 
## function (x, value) 
## {
##     if (length(value) == 0 && is.null(value)) {
##         return(rm_component_(x, 5))
##     }
##     return(set_component_f(x, 5, value, "#"))
## }
## <bytecode: 0x55d1f970d6a8>
## <environment: namespace:urltools>
## 
## Signatures:
##         x    
## target  "ANY"
## defined "ANY"
```

Actually, reading the source above doesn't help us.
Sure it creates a new string, but how on Earth is it the new string bound to the initial name?
Well, it's because the function is called `fragment<-` with an arrow at the end and has a last argument called `value`, both criteria together make it a **replacement function**.
Replacement functions are presented in [The R Language definition](https://cran.r-project.org/doc/manuals/R-lang.html#Subset-assignment), [this StackOverflow thread](https://stackoverflow.com/questions/11563154/what-are-replacement-functions-in-r) and [in the Advanced R book by Hadley Wickham](https://adv-r.hadley.nz/functions.html#replacement-functions).

Let's create our own replacement function to make sure we got it right!

``` r
x <- 1:5
x
```

```         
## [1] 1 2 3 4 5
```

``` r
# function that will replace all values of x
# with the new value
`replace_all<-` <- function(x, value) {
  x[seq_along(x)] <- value
  x
}

# the argument called value is passed at the right of the arrow
replace_all(x) <- 42
x
```

```         
## [1] 42 42 42 42 42
```

So we've modified x, but not in place, see below the same code with `tracemem()`

``` r
x <- 1:5
tracemem(x)
```

```         
## [1] "<0x55d1f94eb560>"
```

``` r
`replace_all<-` <- function(x, value) {
  x[seq_along(x)] <- value
  x
}
replace_all(x) <- 42
```

```         
## tracemem[0x55d1f94eb560 -> 0x55d1fa6c1e88]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> 
## tracemem[0x55d1fa6c1e88 -> 0x55d1fa9fc2d8]: replace_all<- eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> 
## tracemem[0x55d1fa9fc2d8 -> 0x55d1f79fe648]: replace_all<- eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous>
```

``` r
x
```

```         
## [1] 42 42 42 42 42
```

So replacement functions are a standard way to give a mutable flavour to R code.
Let's move on to another mutable feel.

## Exposing the C API in xml2

With `xml2` you can modify and remove XML nodes from a tree which makes you feel the tree is mutable.

See for instance the code in [our blog post about READMEs](/2019/12/03/readmes/#other-size-indicators):

``` r
xml2::xml_replace(xml2::xml_find_all(xml, "//softbreak"),
                      xml2::read_xml("<text>\n</text>"))
```

That code changes nodes in the `xml` object without our assigning it back to it.

The reasons `xml2` works this way is that the package is a binding to [the C libxml2 API](http://xmlsoft.org/), and the XML objects in the libxml2 C API *are* mutable.
[`xml2` does handle memory management for you](https://xml2.r-lib.org/#compared-to-the-xml-package).

## Interfacing an external process that's actually mutable in ps::ps_handle()

Now, speaking of objects that are actually mutable, the [`ps` package](http://ps.r-lib.org/) offers an interesting example: the [`ps_handle()`](http://ps.r-lib.org/reference/ps_handle.html) function creates an object that's essentially a pointer to a system process.
System processes are of course mutable, they run, then die, can be suspended, etc.

In the example below we launch a process using `processx`, create a `ps_handle` object corresponding to it i.e. just an external pointer with an S3 class, and we query its status using `ps`.
`ps` can't *create* processes but it can query, list and manipulate them.

``` r
p <- processx::process$new("sleep", "0.5")
```

With such a definition, after half a second the process will no longer exist.

``` r
p$get_pid()
```

```         
## [1] 21898
```

``` r
phandle <- p$as_ps_handle()
phandle
```

```         
## <ps::ps_handle> PID=21898, NAME=sleep, AT=2020-05-26 11:58:23
```

``` r
ps::ps_status(phandle)
```

```         
## [1] "sleeping"
```

``` r
Sys.sleep(0.5)
ps::ps_status(phandle)
```

```         
## Error: No such process, pid 21898, ???
```

This example corresponded to an object in R referring to something mutable *outside* of R.
What about an object corresponding to something mutable that can also be *inside* of R and mutable?
An answer is: R6 objects!

## Actually mutable objects with R6

The [R6 class system](https://adv-r.hadley.nz/r6.html), created in R via the [R6 package](https://r6.r-lib.org/), allows to define objects that are mutable.
As written in the preamble, in R, environments are mutable, so R6 actually builds around environments.

An example of a package using R6 is `desc`.
Let's create an object corresponding to the DESCRIPTION of the `rhub` package.

``` r
rhub_desc <- desc::desc(text = readLines("https://raw.githubusercontent.com/r-hub/rhub/master/DESCRIPTION"))
rhub_desc$get_authors()
```

```         
## [1] "Gábor Csárdi <csardi.gabor@gmail.com> [aut, cre]"                                      
## [2] "Maëlle Salmon <maelle.salmon@yahoo.se> [aut] (<https://orcid.org/0000-0002-2815-0399>)"
## [3] "R Consortium [fnd]"
```

``` r
rhub_desc$add_author_gh("testingjerry")
rhub_desc$get_authors()
```

```         
## [1] "Gábor Csárdi <csardi.gabor@gmail.com> [aut, cre]"                                      
## [2] "Maëlle Salmon <maelle.salmon@yahoo.se> [aut] (<https://orcid.org/0000-0002-2815-0399>)"
## [3] "R Consortium [fnd]"                                                                    
## [4] "Testing Jerry [ctb]"
```

There are downsides to using R6 [as presented in the OOP trade-offs chapter of Hadley Wickham's Advanded R book](https://adv-r.hadley.nz/oo-tradeoffs.html):

> " Firstly, if you use R6 it's very easy to create a non-idiomatic API that will feel very odd to native R users, and will have surprising pain points because of the reference semantics."

Yep, the mutable aspect can feel odd, otherwise we wouldn't write a whole post about it.
:wink: (Other aspects of R6 are odd, e.g. the use of `$` to call *methods* on *objects*.)

In the case of `desc` all methods exist both as methods and as functions.
The functions operate on the DESCRIPTION of the current folder which is handy when working on a package.
E.g. say you're working on a package inside its folder and want to add a contributor to DESCRIPTION, you can do

``` r
desc::desc_add_author_gh("<githubhandle>")
```

And the local DESCRIPTION file will be updated.
So what's become mutable is the DESCRIPTION file itself via an object that's written to disk each time it's changed!

To mention another `R6` example and to come back to system processes: `processx` uses R6 and an external pointer, because some of the mutable state is in R.
`ps` uses an external pointer and then all the mutable state is in C or is external.

## Conclusion

In this post we have shown different reasons and ways to provide a mutable *API*/interface to R users.
As a summary, in many cases, when you want a mutable API, setter methods that are in fact **replacement functions** are the way to go, like `urltools`.
If you need to represent an external object, that is mutable itself (e.g system process like processx or database connection, etc.), then external pointers.
If you want to avoid copying for performance or other reasons, then R6.

We recommend consulting the [Advanced R book](https://adv-r.hadley.nz) for further learning.
Don't hesitate to add some cases of objects that feel or are mutable in the comments below!

Thanks to [Peter Meissner](https://petermeissner.de/) whose remark on Twitter *"In #rstats nearly everything is immutable by default, it's the default and makes a lot of stuff very simple."* inspired this post.
