build: content/00.front-matter.md content/02.introduction.md content/04.discussion.md content/05.methods.md content/90.back-matter.md content/01.abstract.md content/03.results.md content/059.declarations.md content/06.suppmaterial.md
	echo "Run 'conda activate manubot' first."
	sh build/build.sh

builddocx: content/00.front-matter.md content/02.introduction.md content/04.discussion.md content/05.methods.md content/90.back-matter.md content/01.abstract.md content/03.results.md content/059.declarations.md content/06.suppmaterial.md
	echo "Run 'conda activate manubot' first."
	BUILD_DOCX=true sh build/build.sh

update-sup-tags: content/06.suppmaterial.md
	python updateTagsS.py content/06.suppmaterial.md > temp.md
	mv temp.md content/06.suppmaterial.md
