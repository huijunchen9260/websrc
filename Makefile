#!/usr/bin/make -f

BLOG := $(MAKE) -f $(lastword $(MAKEFILE_LIST)) --no-print-directory
ifneq ($(filter-out help,$(MAKECMDGOALS)),)
include config
endif

# The following can be configured in config
BLOG_DATE_FORMAT_INDEX ?= %x
BLOG_DATE_FORMAT ?= %x %X
BLOG_TITLE ?= blog
BLOG_DESCRIPTION ?= blog
BLOG_URL_ROOT ?= http://localhost/blog
BLOG_FEED_MAX ?= 20
BLOG_FEEDS ?= rss atom
BLOG_SRC ?= articles
BLOG_AUTHOR ?= Hui-Jun Chen

MKDIR := mkdir -p
LN := ln -vsf
LNDIR := ln -vsfn
RM := rm
RMDIR := rm -rf
RSYNC := rsync -urtvzP

.PHONY: help init build deploy clean taglist

ARTICLES := $(shell git ls-tree HEAD --name-only -- $(BLOG_SRC)/*.md 2>/dev/null)
WORKING := $(shell grep -E "; *tags: .*Working.*" $(ARTICLES) | cut -d':' -f1)
JobMarket := $(shell grep -E "; *tags: .*JobMarket.*" $(ARTICLES) | cut -d':' -f1)
PUBLISH := $(shell grep -E "; *tags: .*Published.*" $(ARTICLES) | cut -d':' -f1)
TEACHING := $(shell grep -E "; *tags: .*Teaching.*" $(ARTICLES) | cut -d':' -f1)

TAGFILES := $(patsubst $(BLOG_SRC)/%.md,tags/%,$(ARTICLES))

# ARTICLE_NEWESTDATE := "$(shell git add src 2>&1 1>/dev/null; git commit -m "src update" 2>&1 1>/dev/null; \
# 				 for f in $(ARTICLES); do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";
# WORKING_NEWESTDATE := "$(shell for f in $(WORKING); do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";
# PUBLISH_NEWESTDATE := "$(shell for f in $(PUBLISH); do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";
# COURSE_NEWESTDATE := "$(shell for f in $(TEACHING); do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";
# INDEX_NEWESTDATE := "$(shell git add index.md 1>/dev/null; git commit -m "index.md update" 1>/dev/null; \
# 				 for f in $(ARTICLES) index.md research.md teaching.md; do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";
# RESEARCH_NEWESTDATE := "$(shell for f in $(WORKING) $(PUBLISH) research.md; do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";
# TEACHING_NEWESTDATE := "$(shell for f in $(TEACHING) teaching.md; do \
# 					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 				 done | sort -rk2 | head -n 1)";

.ONESHELL:
test:
	echo $(INDEX_NEWESTDATE)

help:
	$(info make init|build|deploy|clean|taglist)

# init:
# 	mkdir -p $(BLOG_SRC) data templates
# 	printf '<!DOCTYPE html><html><head><title>$$TITLE</title></head><body>' > templates/header.html
# 	printf '</body></html>' > templates/footer.html
# 	printf '' > templates/index_header.html
# 	printf '<p>Tags:' > templates/tag_list_header.html
# 	printf '<a href="$$URL">$$NAME</a>' > templates/tag_entry.html
# 	printf ', ' > templates/tag_separator.html
# 	printf '</p>' > templates/tag_list_footer.html
# 	printf '<h2>Articles</h2><ul id=artlist>' > templates/article_list_header.html
# 	printf '<li><a href="$$URL">$$DATE $$TITLE</a></li>' > templates/article_entry.html
# 	printf '' > templates/article_separator.html
# 	printf '</ul>' > templates/article_list_footer.html
# 	printf '' > templates/index_footer.html
# 	printf '' > templates/tag_index_header.html
# 	printf '' > templates/tag_index_footer.html
# 	printf '' > templates/article_header.html
# 	printf '' > templates/article_footer.html
# 	printf 'blog\n' > .git/info/exclude

build: blog/index.html blog/research.html blog/teaching.html blog/blog.html tagpages $(patsubst $(BLOG_SRC)/%.md,blog/%.html,$(ARTICLES)) blog/rss.xml blog/atom.xml
	git add .; \
	git commit -m "updatewebsrc $(shell date "+%m/%d/%Y %H:%M:%S")"; \
	git push https://$(GIT_AUTH)@github.com/huijunchen9260/websrc; \
	$(RSYNC) pdf blog; \
	$(RSYNC) pix blog; \
	$(RSYNC) css blog; \
	$(RSYNC) style.css blog/; \
	$(RSYNC) blog/ ../web/;

deploy: build
	cd ../web; \
	git add .; \
	git commit -m "updateweb $(shell date "+%m/%d/%Y %H:%M:%S")"; \
	git push https://$(GIT_AUTH)@github.com/huijunchen9260/huijunchen9260.github.io;
	# rsync -rLtvz $(BLOG_RSYNC_OPTS) blog/ data/ $(BLOG_REMOTE)

clean:
	rm -rf blog tags; \
	mkdir -p blog tags; \
	# rm *.html;

config:
	printf 'BLOG_REMOTE:=%s\n' \
		'$(shell printf "Blog remote (eg: host:/var/www/html): ">/dev/tty; head -n1)' \
		> $@

tags/%: $(BLOG_SRC)/%.md
	mkdir -p tags; \
	grep -ih '^; *tags:' "$<" | cut -d: -f2- | tr -c '[^a-zA-Z\-]' ' ' | sed 's/  */\n/g' | sed '/^$$/d' | sort -u > $@;

### Original index.html generation: save as record
# blog/index.html: index.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header index_header tag_list_header tag_entry tag_separator tag_list_footer article_list_header article_entry article_separator article_list_footer index_footer footer))
# 	mkdir -p blog
# 	TITLE="$(BLOG_TITLE)"; \
# 	PAGE_TITLE="$(BLOG_TITLE)"; \
# 	DATE_EDITED="$(shell git log -n 1 --date="format:$(BLOG_DATE_FORMAT)" --pretty=format:'%ad' -- "$<")"; \
# 	export TITLE; \
# 	export PAGE_TITLE; \
# 	export DATE_EDITED; \
# 	envsubst < templates/header.html > $@; \
# 	envsubst < templates/index_header.html >> $@; \
# 	lowdown -thtml --html-no-skiphtml --html-no-escapehtml < index.md >> $@; \
# 	envsubst < templates/tag_list_header.html >> $@; \
# 	first=true; \
# 	for t in $(shell cat $(TAGFILES) | sort -u); do \
# 		"$$first" || envsubst < templates/tag_separator.html; \
# 		NAME="$$t" \
# 		URL="@$$t.html" \
# 		envsubst < templates/tag_entry.html; \
# 		first=false; \
# 	done >> $@; \
# 	envsubst < templates/tag_list_footer.html >> $@; \
# 	echo "<h2>Articles</h2>" >> $@; \
# 	envsubst < templates/article_list_header.html >> $@; \
# 	first=true; \
# 	for f in $(ARTICLES); do \
# 		printf '%s ' "$$f"; \
# 		git log -n 1 --diff-filter=A --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 	done | sort -k2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
# 		"$$first" || envsubst < templates/article_separator.html; \
# 		URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
# 		DATE="$$DATE" \
# 		TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
# 		envsubst < templates/article_entry.html; \
# 		first=false; \
# 	done >> $@; \
# 	envsubst < templates/article_list_footer.html >> $@; \
# 	envsubst < templates/index_footer.html >> $@; \
# 	envsubst < templates/footer.html >> $@; \

blog/index.html: index.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header index_header tag_list_header tag_entry tag_separator tag_list_footer article_list_header article_entry article_separator article_list_footer index_footer footer))
	mkdir -p blog; \
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="$(BLOG_TITLE)"; \
	DATE_EDITED="$(shell for f in $(ARTICLES) index.md research.md teaching.md; do \
					 git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
				 done | sort -rk2 | head -n 1)"; \
	export TITLE; \
	export PAGE_TITLE; \
	export DATE_EDITED; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/index_header.html >> $@; \
	lowdown -thtml --html-no-skiphtml --html-no-escapehtml < index.md >> $@; \
	envsubst < templates/index_footer.html >> $@; \
	envsubst < templates/footer.html >> $@;


blog/blog.html: blog.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header blog_header tag_list_header tag_entry tag_separator tag_list_footer article_list_header article_entry article_separator article_list_footer blog_footer footer))
	mkdir -p blog; \
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="Blog -- $(BLOG_TITLE)"; \
	DATE_EDITED="$(shell for f in $(ARTICLES); do \
					git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
					done | sort -rk2 | head -n 1)"; \
	export DATE_EDITED; \
	export TITLE; \
	export PAGE_TITLE; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/blog_header.html >> $@; \
	lowdown -thtml --html-no-skiphtml --html-no-escapehtml < blog.md >> $@; \
	envsubst < templates/tag_list_header.html >> $@; \
	first=true; \
	for t in $(shell cat $(TAGFILES) | sort -u); do \
		"$$first" || envsubst < templates/tag_separator.html; \
		NAME="$$t" \
		URL="@$$t.html" \
		envsubst < templates/tag_entry.html; \
		first=false; \
	done >> $@; \
	envsubst < templates/tag_list_footer.html >> $@; \
	echo "<h2>Articles</h2>" >> $@; \
	envsubst < templates/article_list_header.html >> $@; \
	first=true; \
	for f in $(ARTICLES); do \
		printf '%s ' "$$f"; \
		git log -n 1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort -rk2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
		"$$first" || envsubst < templates/article_separator.html; \
		URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
		DATE="$$DATE" \
		TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
		envsubst < templates/article_entry.html; \
		first=false; \
	done >> $@; \
	envsubst < templates/article_list_footer.html >> $@; \
	envsubst < templates/blog_footer.html >> $@; \
	envsubst < templates/footer.html >> $@;

blog/research.html: research.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header research_header article_list_header article_entry article_separator article_list_footer research_footer footer))
	mkdir -p blog; \
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="Research -- $(BLOG_TITLE)"; \
	DATE_EDITED="$(shell for f in $(WORKING) $(PUBLISH) $(JobMarket) research.md; do \
					git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
					done | sort -rk2 | head -n 1)"; \
	export TITLE; \
	export PAGE_TITLE; \
	export DATE_EDITED; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/research_header.html >> $@; \
	lowdown -thtml --html-no-skiphtml --html-no-escapehtml < research.md >> $@; \
	envsubst < templates/research_footer.html >> $@; \
	envsubst < templates/footer.html >> $@


# blog/research.html: research.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header research_header article_list_header article_entry article_separator article_list_footer research_footer footer))
# 	mkdir -p blog; \
# 	TITLE="$(BLOG_TITLE)"; \
# 	PAGE_TITLE="Research -- $(BLOG_TITLE)"; \
# 	DATE_EDITED="$(shell for f in $(WORKING) $(PUBLISH) $(JobMarket) research.md; do \
# 					git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 					done | sort -rk2 | head -n 1)"; \
# 	export TITLE; \
# 	export PAGE_TITLE; \
# 	export DATE_EDITED; \
# 	envsubst < templates/header.html > $@; \
# 	envsubst < templates/research_header.html >> $@; \
# 	lowdown -thtml --html-no-skiphtml --html-no-escapehtml < research.md >> $@; \
# 	f1=true; f2=true; \
# 	[ -z "$(WORKING)" ] && [ -z "$(PUBLISH)" ] && { \
# 		echo "<h1>Under Construction</h1>" >> $@ ; \
# 		envsubst < templates/research_footer.html >> $@ ; \
# 		envsubst < templates/footer.html >> $@ ; \
# 		exit ; \
# 	} ; \
# 	[ -n "$(JobMarket)" ] && { \
# 		first=true; \
#  		echo "<h2>Job Market Paper</h2>" >> $@ ; \
# 		envsubst < templates/article_list_header.html >> $@; \
# 		for f in $(JobMarket); do \
# 			printf '%s ' "$$f"; \
# 			git log -n 1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 		done | sort -rk2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
# 			"$$first" || envsubst < templates/article_separator.html; \
# 			URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
# 			DATE="$$DATE" \
# 			TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
# 			PRESENT="`grep 'Present at' "\$$FILE" | sed -e 's;Present at;<b>Present at</b>;g'`" \
# 			envsubst < templates/research_entry.html; \
# 			first=false; \
# 		done >> $@; \
# 		envsubst < templates/article_list_footer.html >> $@; \
# 	};  \
# 	[ -n "$(WORKING)" ] && { \
# 		first=true; \
#  		echo "<h2>Working Papers</h2>" >> $@ ; \
# 		envsubst < templates/article_list_header.html >> $@; \
# 		for f in $(WORKING); do \
# 			printf '%s ' "$$f"; \
# 			git log -n 1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 		done | sort -rk2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
# 			"$$first" || envsubst < templates/article_separator.html; \
# 			URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
# 			DATE="$$DATE" \
# 			TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
# 			PRESENT="`grep 'Present at' "\$$FILE" | sed -e 's;Present at;<b>Present at</b>;g'`" \
# 			envsubst < templates/research_entry.html; \
# 			first=false; \
# 		done >> $@; \
# 		envsubst < templates/article_list_footer.html >> $@; \
# 	};  \
# 	[ -n "$(PUBLISH)" ] && { \
# 		first=true; \
#  		echo "<h2>Published</h2>" >> $@ ; \
# 		envsubst < templates/article_list_header.html >> $@; \
# 		for f in $(PUBLISH); do \
# 			printf '%s ' "$$f"; \
# 			git log -n 1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
# 		done | sort -rk2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
# 			"$$first" || envsubst < templates/article_separator.html; \
# 			URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
# 			DATE="$$DATE" \
# 			TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
# 			PRESENT="`grep 'Present at' "\$$FILE" | sed -e 's;Present at;<b>Present at</b>;g'`" \
# 			envsubst < templates/research_entry.html; \
# 			first=false; \
# 		done >> $@; \
# 		envsubst < templates/article_list_footer.html >> $@; \
# 	};  \
# 	envsubst < templates/research_footer.html >> $@; \
# 	envsubst < templates/footer.html >> $@

blog/teaching.html: teaching.md $(ARTICLES) $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header teaching_header article_list_header article_entry article_separator article_list_footer teaching_footer footer))
	mkdir -p blog; \
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="Teaching -- $(BLOG_TITLE)"; \
	DATE_EDITED="$(shell for f in $(TEACHING) teaching.md; do \
					git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
					done | sort -rk2 | head -n 1)"; \
	export TITLE; \
	export PAGE_TITLE; \
	export DATE_EDITED; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/teaching_header.html >> $@; \
	lowdown -thtml --html-no-skiphtml --html-no-escapehtml < teaching.md >> $@; \
	f1=true; \
	[ -z "$(TEACHING)" ] && { \
		echo "<h1>Under Construction</h1>" >> $@ ; \
		envsubst < templates/teaching_footer.html >> $@ ; \
		envsubst < templates/footer.html >> $@ ; \
		exit ; \
	} ; \
	[ -n "$(TEACHING)" ] && { \
		first=true; \
 		echo "<h2>Teaching</h2>" >> $@ ; \
		envsubst < templates/article_list_header.html >> $@; \
		for f in $(TEACHING); do \
			printf '%s ' "$$f"; \
			git log -n 1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
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

blog/tag/%.html: $(ARTICLES) $(addprefix templates/,$(addsuffix .html,header tag_header index_entry tag_footer footer))

.PHONY: tagpages
tagpages: $(TAGFILES)
	+$(BLOG) $(patsubst %,blog/@%.html,$(shell cat $(TAGFILES) | sort -u))

blog/@%.html: $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header tag_index_header tag_list_header tag_entry tag_separator tag_list_footer article_list_header article_entry article_separator article_list_footer tag_index_footer footer))
	mkdir -p blog; \
	PAGE_TITLE="Articles tagged: $* -- $(BLOG_TITLE)"; \
	DATE_EDITED="$$(for f in $(shell awk '$$0 == "$*" { gsub("tags", "$(BLOG_SRC)", FILENAME); print FILENAME  ".md"; nextfile; }' $(TAGFILES)); do \
		git log -n 1 --date="format:$(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort -rk2 | head -n 1)"; \
	export DATE_EDITED; \
	TAGS="$*"; \
	TITLE="$(BLOG_TITLE)"; \
	export PAGE_TITLE; \
	export TAGS; \
	export TITLE; \
	export DATE_EDITED; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/tag_index_header.html >> $@; \
	envsubst < templates/tag_list_header.html >> $@; \
	first=true; \
	for t in $(shell cat $(TAGFILES) | sort -u); do \
		"$$first" || envsubst < templates/tag_separator.html; \
		NAME="$$t" \
		URL="@$$t.html" \
		envsubst < templates/tag_entry.html; \
		first=false; \
	done >> $@; \
	envsubst < templates/tag_list_footer.html >> $@; \
	envsubst < templates/article_list_header.html >> $@; \
	first=true; \
	for f in $(shell awk '$$0 == "$*" { gsub("tags", "$(BLOG_SRC)", FILENAME); print FILENAME  ".md"; nextfile; }' $(TAGFILES)); do \
		printf '%s ' "$$f"; \
		git log -n 1 --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort -rk2 | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
		"$$first" || envsubst < templates/article_separator.html; \
		URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
		DATE="$$DATE" \
		TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
		envsubst < templates/article_entry.html; \
		first=false; \
	done >> $@; \
	envsubst < templates/article_list_footer.html >> $@; \
	envsubst < templates/tag_index_footer.html >> $@; \
	envsubst < templates/footer.html >> $@;


blog/%.html: $(BLOG_SRC)/%.md $(addprefix templates/,$(addsuffix .html,header article_header tag_link_header tag_link tag_link_footer article_footer footer))
	mkdir -p blog; \
	TITLE="$(shell head -n1 $< | sed 's/^# \+//')"; \
	export TITLE; \
	PAGE_TITLE="$${TITLE} -- $(BLOG_TITLE)"; \
	export PAGE_TITLE; \
	AUTHOR="$(shell git log --format="%an" -- "$<" | tail -n 1)"; \
	export AUTHOR; \
	DATE_POSTED="$(shell git log -n 1 --diff-filter=A --date="format:$(BLOG_DATE_FORMAT)" --pretty=format:'%ad' -- "$<")"; \
	export DATE_POSTED; \
	DATE_EDITED="$(shell git log -n 1 --date="format:$(BLOG_DATE_FORMAT)" --pretty=format:'%ad' -- "$<")"; \
	export DATE_EDITED; \
	TAGS="$(shell grep -i '^; *tags:' "$<" | cut -d: -f2- | paste -sd ',')"; \
	export TAGS; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/article_header.html >> $@; \
	sed -e '/^;/d' < $< | lowdown -thtml --html-no-skiphtml --html-no-escapehtml --parse-math >> $@; \
	envsubst < templates/tag_link_header.html >> $@; \
	for i in $${TAGS} ; do \
		TAG_NAME="$$i" \
		TAG_LINK="./@$$i.html" \
		envsubst < templates/tag_link.html >> $@; \
	done; \
	envsubst < templates/tag_link_footer.html >> $@; \
	envsubst < templates/article_footer.html >> $@; \
	envsubst < templates/footer.html >> $@; \

blog/rss.xml: $(ARTICLES)
	printf '<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0">\n<channel>\n<title>%s</title>\n<link>%s</link>\n<description>%s</description>\n' \
		"$(BLOG_TITLE)" "$(BLOG_URL_ROOT)" "$(BLOG_DESCRIPTION)" > $@
	for f in $(ARTICLES); do \
		printf '%s ' "$$f"; \
		git log -n 1 --date="format:%s %a, %d %b %Y %H:%M:%S %z" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort -k2nr | head -n $(BLOG_FEED_MAX) | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
		printf '<item>\n<title>%s</title>\n<link>%s</link>\n<guid>%s</guid>\n<pubDate>%s</pubDate>\n<description><![CDATA[%s]]></description>\n</item>\n' \
			"`head -n 1 $$FILE | sed 's/^# //'`" \
			"$(BLOG_URL_ROOT)`basename $$FILE | sed 's/\.md/\.html/'`" \
			"$(BLOG_URL_ROOT)`basename $$FILE | sed 's/\.md/\.html/'`" \
			"$$DATE" \
			"`lowdown -thtml --html-no-skiphtml --html-no-escapehtml < $$FILE`"; \
	done >> $@
	printf '</channel>\n</rss>\n' >> $@

blog/atom.xml: $(ARTICLES)
	printf '<?xml version="1.0" encoding="UTF-8"?>\n<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en">\n<title type="text">%s</title>\n<subtitle type="text">%s</subtitle>\n<updated>%s</updated>\n<link rel="alternate" type="text/html" href="%s"/>\n<id>%s</id>\n<link rel="self" type="application/atom+xml" href="%s"/>\n' \
		"$(BLOG_TITLE)" "$(BLOG_DESCRIPTION)" "$(shell date +%Y-%m-%dT%H:%M:%SZ)" "$(BLOG_URL_ROOT)" "$(BLOG_URL_ROOT)atom.xml" "$(BLOG_URL_ROOT)/atom.xml" > $@
	for f in $(ARTICLES); do \
		printf '%s ' "$$f"; \
		git log -n 1 --diff-filter=A --date="format:%s %Y-%m-%dT%H:%M:%SZ" --pretty=format:'%ad %aN%n' -- "$$f"; \
	done | sort -k2nr | head -n $(BLOG_FEED_MAX) | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE AUTHOR; do \
		printf '<entry>\n<title type="text">%s</title>\n<link rel="alternate" type="text/html" href="%s"/>\n<id>%s</id>\n<published>%s</published>\n<updated>%s</updated>\n<author><name>%s</name></author>\n<summary type="html"><![CDATA[%s]]></summary>\n</entry>\n' \
			"`head -n 1 $$FILE | sed 's/^# //'`" \
			"$(BLOG_URL_ROOT)`basename $$FILE | sed 's/\.md/\.html/'`" \
			"$(BLOG_URL_ROOT)`basename $$FILE | sed 's/\.md/\.html/'`" \
			"$$DATE" \
			"`git log -n 1 --date="format:%Y-%m-%dT%H:%M:%SZ" --pretty=format:'%ad' -- "$$FILE"`" \
			"$$AUTHOR" \
			"`lowdown -thtml --html-no-skiphtml --html-no-escapehtml < $$FILE`"; \
	done >> $@
	printf '</feed>\n' >> $@

taglist:
	grep -RIh '^;tags:' src | cut -d: -f2- | tr ',' '\n' | sed 's/^ *//g;s/ *$$//g' | sort | uniq
