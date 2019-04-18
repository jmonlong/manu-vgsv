incfiles := $(shell cat includeInManuscript.txt)
incfiles := $(incfiles:%=../content/images/%)

all: $(incfiles)

png/%.png: pdf/%.pdf
	pdftoppm -png $<  > $@

../content/images/%.png: png/%.png
	cp $< $@
