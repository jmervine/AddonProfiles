lauunit ?= "https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua"

test: Libs/LUAUnit/luaunit.lua
	lua ./test/test.lua

Libs/LUAUnit:
	make -p Libs/LUAUnit

Libs/LUAUnit/luaunit.lua: Libs/LUAUnit
	curl -s https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua > Libs/LUAUnit/luaunit.lua

ci:
	docker build -t jmervine/addontemplates:test -f Dockerfile.test .
	docker run -t jmervine/addontemplates:test

releases:
	mkdir -p releases

release: releases
	mkdir -p releases/AddOnTemplates
	cp -vr ./*.toc releases/AddOnTemplates/
	cp -vr ./*.lua releases/AddOnTemplates/
	cp -vr ./*.xml releases/AddOnTemplates/
	cp -vr ./*.md releases/AddOnTemplates/
	cp -vr ./VERSION releases/AddOnTemplates/
	cp -vr ./Libs releases/AddOnTemplates/
	rm -r  ./releases/AddOnTemplates/Libs/LUAUnit
	cd releases \
		&& zip AddOnTemplates-$(shell cat ./VERSION).zip AddOnTemplates/**/* \
		&& rm -rf AddOnTemplates
	git commit -a -m "Release $(shell cat ./VERSION)."
	git tag -f $(shell cat ./VERSION)

.PHONY: test ci release
