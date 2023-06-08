# Pandit - Minimalist Pandoc-based static site generator
# https://p2pcollab.net/pandit/

MD := $(shell git ls-files | grep '\.md$$')
ORG := $(shell git ls-files | grep '\.org$$')
RST := $(shell git ls-files | grep '\.rst$$')
ADOC := $(shell git ls-files | grep '\.adoc$$')
DOT := $(shell git ls-files | grep '\.dot$$')

MD_HTML := $(patsubst %.md,%.md.html,$(MD))
ORG_HTML := $(patsubst %.org,%.org.html,$(ORG))
RST_HTML := $(patsubst %.rst,%.rst.html,$(RST))
ADOC_HTML := $(patsubst %.adoc,%.adoc.html,$(ADOC))

MD_PDF := $(patsubst %.md,%.md.pdf,$(MD))
ORG_PDF := $(patsubst %.org,%.org.pdf,$(ORG))
RST_PDF := $(patsubst %.rst,%.rst.pdf,$(RST))
ADOC_PDF := $(patsubst %.adoc,%.adoc.pdf,$(ADOC))

MD_TEX := $(patsubst %.md,%.md.tex,$(MD))
ORG_TEX := $(patsubst %.org,%.org.tex,$(ORG))
RST_TEX := $(patsubst %.rst,%.rst.tex,$(RST))
ADOC_TEX := $(patsubst %.adoc,%.adoc.tex,$(ADOC))

DOT_SVG := $(patsubst %.dot,%.svg,$(DOT))

# Input/output directory names
OUT := public
OUT_CSS := css
OUT_LIB := lib
IMG := img

# CSS to be included directly in HTML documents
CSS := $(shell test -e css.mk && cat css.mk)

# Extra CSS to publish
CSS_X := $(shell test -e css-x.mk && cat css-x.mk)

KATEX_URL := https://cdn.jsdelivr.net/npm/katex@0.16.0/dist

PANDOC_OPTS := \
	--data-dir=. \
	--section-divs

PANDOC_OPTS_HTML := $(shell test -e html.mk && cat html.mk)

PANDOC_OPTS_PDF := $(shell test -e pdf.mk && cat pdf.mk) \
	--pdf-engine=xelatex

# Publish to web server with filename extensions and index.html removed from links
WEB :=
LINK_REGEX := \
	s/href="\([^\":]*\)\.\(md\|org\|rst\|adoc\)\(\#[^\"]*\)\?"/href="\1.html\3"/g;\
	$(if $(WEB),$\
	s/href="\([^\":]*\)\.html\(#[^\"]*\)\?"/href="\1\2"/g;\
	s/href="\([^\":]*\/\)index\(#[^\"]*\)\?"/href="\1\2"/g;\
	s/href="index\(#[^\"]*\)\?"/href=".\1"/g;\
	,)

all: md org rst adoc dot

md: $(MD_HTML) $(MD_PDF) css lib img dot
org: $(ORG_HTML) $(ORG_PDF) css lib img dot
rst: $(RST_HTML) $(RST_PDF) css lib img dot
adoc: $(ADOC_HTML) $(ADOC_PDF) css lib img dot

dot: $(DOT_SVG)

%.md.html: %.md $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=markdown \
		--to=html5+smart \
		--defaults=defaults.yaml \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .md,.yaml,$<) && echo 1),--defaults=$(subst .md,.yaml,$<),) \
		-V basename=$(shell basename $< .md) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_HTML) \
		--katex=$(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_LIB)/ \
		$(foreach css,$(CSS),$\
			--css $(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_CSS)/$(notdir $(css))) \
		$< | sed '$(LINK_REGEX)' > $(OUT)/$(patsubst %.md,%.html,$<)

%.org.html: %.org $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=org+citations \
		--to=html5+smart \
		--defaults=$(if $(shell test -e $(shell basename $< .org).yaml),$(shell basename $< .org).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .org,.yaml,$<) && echo 1),--defaults=$(subst .org,.yaml,$<),) \
		-V basename=$(shell basename $< .org) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_HTML) \
		--katex=$(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_LIB)/ \
		$(foreach css,$(CSS),--css $(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_CSS)/$(notdir $(css))) \
		$< | sed '$(LINK_REGEX)' > $(OUT)/$(patsubst %.org,%.html,$<)

%.rst.html: %.rst $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=rst \
		--to=html5+smart \
		--defaults=$(if $(shell test -e $(shell basename $< .rst).yaml),$(shell basename $< .rst).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .rst,.yaml,$<) && echo 1),--defaults=$(subst .rst,.yaml,$<),) \
		-V basename=$(shell basename $< .rst) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_HTML) \
		--katex=$(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_LIB)/ \
		$(foreach css,$(CSS),--css $(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_CSS)/$(notdir $(css))) \
		$< | sed '$(LINK_REGEX)' > $(OUT)/$(patsubst %.rst,%.html,$<)

%.adoc.html: %.adoc $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	asciidoctor -v -b docbook5 -o - $< \
	| pandoc \
		--from=docbook \
		--to=html5+smart \
		--defaults=$(if $(shell test -e $(shell basename $< .adoc).yaml),$(shell basename $< .adoc).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .adoc,.yaml,$<) && echo 1),--defaults=$(subst .adoc,.yaml,$<),) \
		-V basename=$(shell basename $< .adoc) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_HTML) \
		--katex=$(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_LIB)/ \
		$(foreach css,$(CSS),--css $(subst %,,$(patsubst %,../,$(subst /,%,$(subst ./,,$(dir $@)))))$(OUT_CSS)/$(notdir $(css))) \
		| sed '$(LINK_REGEX)' > $(OUT)/$(patsubst %.adoc,%.html,$<)

%.md.pdf: %.md $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=markdown \
		--to=pdf \
		--defaults=defaults.yaml \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .md,.yaml,$<) && echo 1),--defaults=$(subst .md,.yaml,$<),) \
		--resource-path=$(dir $@):$(dir $(OUT)/$(dir $@)) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.md,%.pdf,$<) \
		$<

%.org.pdf: %.org $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=org+citations \
		--to=pdf \
		--defaults=$(if $(shell test -e $(shell basename $< .org).yaml),$(shell basename $< .org).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .org,.yaml,$<) && echo 1),--defaults=$(subst .org,.yaml,$<),) \
		--resource-path=$(dir $@):$(dir $(OUT)/$(dir $@)) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.org,%.pdf,$<) \
		$<

%.rst.pdf: %.rst $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=rst \
		--to=pdf \
		--defaults=$(if $(shell test -e $(shell basename $< .rst).yaml),$(shell basename $< .rst).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .rst,.yaml,$<) && echo 1),--defaults=$(subst .rst,.yaml,$<),) \
		--resource-path=$(dir $@):$(dir $(OUT)/$(dir $@)) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.rst,%.pdf,$<) \
		$<

%.adoc.pdf: %.adoc $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	asciidoctor -v -b docbook5 -o - $< \
	| pandoc \
		--from=docbook \
		--to=pdf \
		--defaults=$(if $(shell test -e $(shell basename $< .adoc).yaml),$(shell basename $< .adoc).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .adoc,.yaml,$<) && echo 1),--defaults=$(subst .adoc,.yaml,$<),) \
		--resource-path=$(dir $@):$(dir $(OUT)/$(dir $@)) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.adoc,%.pdf,$<)

%.md.tex: %.md $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=markdown \
		--to=latex \
		--defaults=defaults.yaml \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .md,.yaml,$<) && echo 1),--defaults=$(subst .md,.yaml,$<),) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.md,%.tex,$<) \
		$<

%.org.tex: %.org $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=org+citations \
		--to=latex \
		--defaults=$(if $(shell test -e $(shell basename $< .org).yaml),$(shell basename $< .org).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .org,.yaml,$<) && echo 1),--defaults=$(subst .org,.yaml,$<),) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.org,%.tex,$<) \
		$<

%.rst.tex: %.rst $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	pandoc \
		--from=rst \
		--to=latex \
		--defaults=$(if $(shell test -e $(shell basename $< .rst).yaml),$(shell basename $< .rst).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .rst,.yaml,$<) && echo 1),--defaults=$(subst .rst,.yaml,$<),) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.rst,%.tex,$<) \
		$<

%.adoc.tex: %.adoc $(TMPL) $(CSS)
	mkdir -p $(dir $(OUT)/$(dir $@))
	asciidoctor -v -b docbook5 -o - $< \
	| pandoc \
		--from=docbook \
		--to=latex \
		--defaults=$(if $(shell test -e $(shell basename $< .adoc).yaml),$(shell basename $< .adoc).yaml,defaults.yaml) \
		$(if $(shell test -e $(shell dirname $<)/defaults.yaml && echo 1),--defaults=$(shell dirname $<)/defaults.yaml,) \
		$(if $(shell test -e $(subst .adoc,.yaml,$<) && echo 1),--defaults=$(subst .adoc,.yaml,$<),) \
		$(PANDOC_OPTS) \
		$(PANDOC_OPTS_PDF) \
		-o $(OUT)/$(patsubst %.adoc,%.tex,$<)

%.svg: %.dot
	mkdir -p $(dir $(OUT)/$(dir $@))
	neato -Tsvg $< > $(OUT)/$@

css: $(OUT)/$(OUT_CSS)
lib: $(OUT)/$(OUT_LIB)
img: $(OUT)/$(IMG)

$(OUT)/$(OUT_CSS): $(CSS) $(CSS_X)
	mkdir -p $(OUT)/$(OUT_CSS)
	cp -a $(CSS) $(CSS_X) $(OUT)/$(OUT_CSS)

$(OUT)/$(OUT_LIB):
	mkdir -p $(OUT)/$(OUT_LIB)
	wget -cP $(OUT)/$(OUT_LIB) $(KATEX_URL)/katex.min.js
	wget -cP $(OUT)/$(OUT_LIB) $(KATEX_URL)/katex.min.css
	wget -cP $(OUT)/$(OUT_LIB)/contrib $(KATEX_URL)/contrib/auto-render.min.js

$(OUT)/$(IMG):
	mkdir -p $(OUT)
	test -e $(IMG) && cp -a $(IMG) $(OUT)/ || true

clean:
	rm -rf $(OUT)

.PHONY: clean
.PHONY: $(OUT)/$(OUT_CSS)
.PHONY: $(OUT)/$(IMG)
