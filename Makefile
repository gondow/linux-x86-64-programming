all:
	mdbook build -o

push:
	rm -rf docs
	mv book docs
	git add .
	git commit -m "hoge"
	git push origin main

pull:
	git pull origin main
