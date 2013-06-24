TEX=mmu.tex

RM ?= rm -f

PDF=$(TEX:.tex=.pdf)
AUX=$(TEX:.tex=.aux)
LOG=$(TEX:.tex=.log)

all: $(PDF)

%.pdf: %.tex
	texi2pdf $<

clean:
	$(RM) $(PDF) $(LOG) $(AUX)

.PHONY: clean
