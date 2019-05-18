incfiles := $(shell cat includeInManuscript.txt)
incfiles := $(incfiles:%=../content/images/%)

all: $(incfiles)

png/%.png: pdf/%.pdf
	pdftoppm -r 300 -png $<  > $@

../content/images/%.png: png/%.png
	cp $< $@
