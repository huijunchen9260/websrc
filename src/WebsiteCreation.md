# How do I create this website

I have two goals to share with you in this blog post:

1. How to use a [blogit](https://pedantic.software/git/blogit) to systematically build your website, and
2. How to modify the Makefile in [blogit](https://pedantic.software/git/blogit).

If you want to see the source code for this website, it is stored in [huijunchen9260/websrc](https://github.com/huijunchen9260/websrc) repository.

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

It is simple enough for me to understand every detail, but do the heavy-duty for me.
(still not *every* to be honest, that is exaggeration)
[blogit](https://pedantic.software/git/blogit) is nothing but just a Makefile which insert HTML tags into the Markdown file to make it become a HTML page.
I don't know what's happening inside the brain of the author of [blogit](https://pedantic.software/git/blogit), but this is such a terribly tedious job.
Thankfully, once it is done, it is so simple and magic.
Every tags are precisely placed in corresponding webpages, and automatically generate a list of articles that every blog need.

Comparing with all other static site generators, which involves learning `YAML`, `TOML`, `JS` and a lot of "settings" just confuses me.

## But...[blogit](https://pedantic.software/git/blogit) is only for blogs!

Yes, that is true, and I am not satisfied with that.
A good personal website in my opinion should include individual pages for specific purposes.
For example, pages for [Research](research.html), [Teaching](teaching.html), and last link for [Blog](blog.html) are necessary for a Ph.D. student website.
In order to achieve this, I rewrite the code to generate `blog/index.html` in the Makefile to also generate `blog/teaching.html`.
The logic to generate this page is to use the existing tags system:

1. I use `grep` to find out this `.md` files actually have `Teaching` tag, and record them into a shell variable `$WP`.
2. If there is no articles with `Teaching` tag, then create a HTML with "Under Construction".
3. Otherwise, we enter the stage of creating [Teaching](teaching.html) page:
    1. Using `git` command to extract the modified date for each markdown file, and update `DATE_EDITED`.
        - `git log -1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"`
            - `git log` create a log file and enter a pager.
            - `git log -1` shows the log file on last commit (`-1` part).
            - `--date` and `format:` shows the format of date to show. I use `%F` and result in the format `%Y-%M-%D`.
            - `--pretty` and `format:` shows the format for pretty print. `%ad` outputs author date, and `%n` means newline.
    2. If there is articles with `Teaching` tag, generate the `DATE`, `URL`, `TITLE` of the articles using `git`, and correspond them into links in the [Teaching](teaching.html) webpage.

The corresponding code block is also listed below:

```make
blog/teaching.html: teaching.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header teaching_header article_list_header article_entry article_separator article_list_footer teaching_footer footer))
	mkdir -p blog
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="Teaching -- $(BLOG_TITLE)"; \
	DATE_EDITED="$(shell git log -1 --date="format:$(BLOG_DATE_FORMAT)" --pretty=format:'%ad' -- "$<")"; \
	export TITLE; \
	export PAGE_TITLE; \
	export DATE_EDITED; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/teaching_header.html >> $@; \
	markdown < teaching.md >> $@; \
	f1=true; \
    # grep for the markdown files with Teaching tag
	for f in $(ARTICLES); do \
		grep -qE "; *tags: .*Teaching.*" "$$f" && { "$$f1" && WP="$$f" || WP="$$WP $$f"; f1=false; }; \
	done ; \
    # If no files with Teaching tag, output Under Construction
	[ -z "$$WP" ] && { \
		echo "<h1>Under Construction</h1>" >> $@ ; \
		envsubst < templates/teaching_footer.html >> $@ ; \
		envsubst < templates/footer.html >> $@ ; \
		exit ; \
	} ; \
    # If there's Teaching tag, find modified dates for all files and update DATE_EDITED
	[ -n "$$WP" ] && { \
		articleNewestDate="$$(for f in $$WP; do \
			git log -1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
		done | sort -rk2 | head -n 1)"; \
		tmpNewest=$$(echo $$articleNewestDate | tr -d '-'); \
		tmpEdit=$$(echo $$DATE_EDITED | tr -d '-'); \
		[ "$$tmpNewest" -ge "$$tmpEdit" ] && DATE_EDITED="$$articleNewestDate"
		export DATE_EDITED; \
	};  \
    # IF there's file with Teaching tag, add hyperlink to each file on this Teaching page
	[ -n "$$WP" ] && { \
		first=true; \
 		echo "<h2>Teaching</h2>" >> $@ ; \
		envsubst < templates/article_list_header.html >> $@; \
		for f in $$WP; do \
			printf '%s ' "$$f"; \
			git log -1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
		done | sort -rk2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
			"$$first" || envsubst < templates/article_separator.html; \
			URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
			DATE="$$DATE" \
			TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
			envsubst < templates/article_entry.html; \
			first=false; \
		done >> $@; \
		envsubst < templates/article_list_footer.html >> $@; \
	};  \
	envsubst < templates/teaching_footer.html >> $@; \
	envsubst < templates/footer.html >> $@
```

With some modification for each individual pages, I can systematically generate everything using just `make build`, and directly publish on GitHub using `make deploy`.



Updates 2022-02-10: added methods to add modified dates

;tags: Miscellaneous Technology
