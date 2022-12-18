lauunit ?= "https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua"

test: libs/luaunit.lua
	lua ./test/test.lua

libs:
	make -p libs

libs/luaunit.lua: libs
	curl -s https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua > libs/luaunit.lua

ci:
	docker build -t jmervine/addontemplates:test -f Dockerfile.test .
	docker run -t jmervine/addontemplates:test

releases:
	mkdir -p releases

release: releases
	mkdir -p releases/AddOnTemplates
	cp -vr ./AddOnTemplates.toc releases/AddOnTemplates/
	cp -vr ./init.lua releases/AddOnTemplates/
	cp -vr ./README.md releases/AddOnTemplates/
	cp -vr ./cmds releases/AddOnTemplates/
	cp -vr ./core releases/AddOnTemplates/
	mkdir -p releases/AddOnTemplates/libs
	cp -vr ./libs/helpers.lua releases/AddOnTemplates/libs/
	cd releases \
		&& zip AddOnTemplates-$(shell cat ./VERSION).zip AddOnTemplates/**/* \
		&& rm -rf AddOnTemplates
	git commit -a -m "Release $(shell cat ./VERSION)."
	git tag -f $(shell cat ./VERSION)

.PHONY: test ci release
