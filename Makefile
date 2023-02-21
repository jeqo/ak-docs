all: build

build:
	hugo -b http://localhost:8080/35/documentation

test:
	hugo serve -b http://localhost:1313/documentation

site: build
	rm -rf kafka-site/35
	mkdir kafka-site/35
	cp -r public kafka-site/35/documentation
	docker build -t ak-docs .

run:
	docker run -it -p 8080:80 ak-docs

# example
convert:
	pandoc -f html content/configuration.html -t markdown > content/configuration.md
