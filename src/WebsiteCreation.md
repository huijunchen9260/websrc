# How do I create this website

I have two goals to share with you in this blog post:

1. How to use a [blogit](https://pedantic.software/git/blogit) to systematically build your website, and
2. How to modify the Makefile in [blog it](https://pedantic.software/git/blogit).

<!-- vim-markdown-toc GFM -->

* [The Reason](#the-reason)
* [Why blogit?](#why-blogit)

<!-- vim-markdown-toc -->

## The Reason

First, let me briefly talk about *WHY* I find [blogit](https://pedantic.software/git/blogit) is static site generator for me despite there are tones of great and modern static site generators in the web.

Long story short, it is mainly because the conflict between my desire to customize everything to the way I like and my laziness to not really make such repeatable effort in terms of customization.
On the one hand, decent blog post [Write HTML in HTML](http://john.ankarstrom.se/html/) shows probably the final stage of a Linux user who just cannot stop but customize everything in their website: write everything in HTML.
However, I don't want to write my own website in HTML.
Probably I am not in that stage yet.
On the other hand, to avoid writing in HTML, most of the current static site generators are full of fancy themes and JavaScript.
All the outcome of contemporary static site generators are great.
They are dedicated designed to look great without any effort.
To be honest, before making this website using [blogit](https://pedantic.software/git/blogit), I actually used [Hugo](https://gohugo.io/) to generate my website.
If you are lucky and find a theme that do everything for you, and probably not a needy person as I do, then congratulations, the customization that confined by the author of themes works for you.
Sadly, I *AM* a very needy person.
I really want everything to be exactly as the way I want them to be, and such restriction made by the theme author just drives me crazy when I try to update my website.
Eventually, I realize that the upfront cost to customize my website is too large, and I just don't update my blog for like two years.
That is to say, I fall into a paradox.
On one side of the spectrum, I really want to customize everything.
On the other side, I really don't want to pay the effort.
That's why I need to find a sweet spot between these two extremes.

## Why [blogit](https://pedantic.software/git/blogit)?

Because it is simple.

[blogit](https://pedantic.software/git/blogit) is nothing but just a Makefile which insert HTML tags into the Markdown file to make it become a HTML page.






;tags: Miscellaneous Technology

