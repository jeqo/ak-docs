all: build

build:
	hugo

test:
	hugo serve -b http://localhost:1313/documentation