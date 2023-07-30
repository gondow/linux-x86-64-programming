all:
	mdbook build -o

push:
	rm -rf docs
	mv book docs
	git add -u
	git commit -m "hoge"
	git push -u origin main
