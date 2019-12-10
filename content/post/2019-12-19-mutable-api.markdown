---
title: Objects that feel mutable in R
date: '2019-12-26'
slug: mutable-api
tags:
  - package development
---

In R, most often, to change an object, you need to re-assign its new value to it. But sometimes, things feel different because objects are mutable or it seems they are, be it in base R code or in the code of packages. Why and how provide a mutable API/interface in R code? In this blog post, we shall explore a few examples to better understand mutable APIs in R.

## Preamble: what do we mean by mutable?

### What is mutable

As explained in the [chapter "Names and values" of the Advanced R book by Hadley Wickham](https://adv-r.hadley.nz/names-values.html), in R objects are actually not mutable, because of the [copy-on-modify behaviour](https://adv-r.hadley.nz/names-values.html#copy-on-modify). The book has very clear diagrams showing how a name is bound to a binding corresponding to an object. When you think you're modifying an object, a new object with a new value has been created and bound to the initial name. The original object is unchanged, it's not mutable.

Environments are mutable, they can be [modified in place](https://adv-r.hadley.nz/names-values.html#modify-in-place). 

### What feels mutable

In this post, we're actually interested in any hack or tool that makes something _feel_ mutable.

We're used to code such as


```r
# initial value
x <- 1
# change the value
x <- 2
```

But the code below also changes x without explicitely assigning a value to it!


```r
x <- 1
length(x) <- 2
x
```

```
## [1]  1 NA
```

One can say the code above is a bit odd. This post is a collection of patterns that might feel odd. :dizzy:

### What's not mutable and doesn't feel mutable either

data.frames are not mutable and one doesn't feel they are, even with `dplyr::mutate()`: you don't write `dplyr::mutate(df, newcol = 1)` to modify `df`, you need to write `df <- dplyr::mutate(df, newcol = 1)`. :stuck_out_tongue_winking_eye:

## A replacement function in the urltools package

In the `urltools` package there are a few functions for getting or setting parts of an URL such as the fragment.


```r
url <- "https://docs.r-hub.io/#package-builder"
urltools::fragment(url)
```

```
## [1] "package-builder"
```

```r
urltools::fragment(url) <- "intro"
url
```

```
## [1] "https://docs.r-hub.io#intro"
```

```r
urltools::fragment(url) <- NULL
url
```

```
## [1] "https://docs.r-hub.io"
```

The original url value is not modified, the url name is bound to a new binding. Below we use the [`tracemem()` function](https://adv-r.hadley.nz/names-values.html#tracemem).


```r
url <- "https://docs.r-hub.io/#package-builder"
tracemem(url)
```

```
## [1] "<0x56391ed3ec98>"
```

```r
urltools::fragment(url) <- "intro"
```

```
## tracemem[0x56391ed3ec98 -> 0x56391fd543c8]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> eval eval eval eval eval.parent local
```

```r
url
```

```
## [1] "https://docs.r-hub.io#intro"
```

So how does the above work, exactly? What's that `fragment` method?


```r
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
## <bytecode: 0x56391de153c0>
## <environment: namespace:urltools>
## 
## Signatures:
##         x    
## target  "ANY"
## defined "ANY"
```

Actually, reading the source above doesn't help us. Sure it creates a new string, but how on Earth is it the new string bound to the initial name? Well, it's because the function is called `fragment<-` with an arrow at the end and has a last argument called `value`, both criteria together make it a **replacement function**. Replacement functions are presented in [The R Language definition](https://cran.r-project.org/doc/manuals/R-lang.html#Subset-assignment), [this StackOverflow thread](https://stackoverflow.com/questions/11563154/what-are-replacement-functions-in-r) and [in the Advanced R book by Hadley Wickham](https://adv-r.hadley.nz/functions.html#replacement-functions).

Let's create our own replacement function to make sure we got it right!


```r
x <- 1:5
x
```

```
## [1] 1 2 3 4 5
```

```r
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

```r
# does it work with an equal sign
replace_all(x) = 42
x
```

```
## [1] 42 42 42 42 42
```

So we've modified x, but not in place, see below the same code with `tracemem()`


```r
x <- 1:5
tracemem(x)
```

```
## [1] "<0x56391e5a2ce0>"
```

```r
`replace_all<-` <- function(x, value) {
  x[seq_along(x)] <- value
  x
}
replace_all(x) <- 42
```

```
## tracemem[0x56391e5a2ce0 -> 0x56391f9aee78]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> eval eval eval eval eval.parent local 
## tracemem[0x56391f9aee78 -> 0x56391f9aee28]: replace_all<- eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> eval eval eval eval eval.parent local 
## tracemem[0x56391f9aee28 -> 0x56391f9fe138]: replace_all<- eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> eval eval eval eval eval.parent local
```

```r
x
```

```
## [1] 42 42 42 42 42
```

## Exposing the C API in xml2::xml_remove()

With `xml2` you can remove XML nodes from a tree which makes you feel the tree is mutable.

[`xml2` docs explain how one should be careful when doing so because of possible memory issues](https://xml2.r-lib.org/articles/modification.html#removing-nodes). The reasons it works this way is that it's not really R code, `xml2` gives you the C API, where you are supposed to manage memory allocation manually. 

## processx::ps(): interfacing an external process that's actually mutable

external pointers

## R6: actually mutable objects

MENTION RHUB CHECK CLASS.

The [R6 class system](https://adv-r.hadley.nz/r6.html), created in R via the [R6 package](https://r6.r-lib.org/), allows to define objects that are mutable.

<!--html_preserve-->{{% tweet "1197868489442246656" %}}<!--/html_preserve-->

R6 is built around environments.

There are downsides to using R6 [as presented in the OOP trade-offs chapter of Hadley Wickham's Advanded R book](https://adv-r.hadley.nz/oo-tradeoffs.html):

> " Firstly, if you use R6 it’s very easy to create a non-idiomatic API that will feel very odd to native R users, and will have surprising pain points because of the reference semantics."

## Conclusion

In this post we have shown different reasons and ways to provide a mutable _API_ to R users. As a summary, in almost all cases, when you want a mutable API, setter methods that are in fact **replacement functions** are the way to go, like `urltools`. If you need to represent an external object, that is mutable itself (e.g system process like processx or database connection, etc.), then external pointers. If you want to avoid copying for performance or other reasons, then R6.

We recommend consulting the [Advanced R book](https://adv-r.hadley.nz) for further learning.


Thanks to [Peter Meissner](https://petermeissner.de/) whose remark ["In #rstats nearly everything is immutable by default, it's the default and makes a lot of stuff very simple."](https://twitter.com/peterlovesdata/status/1198629883766857728) inspired this post.
