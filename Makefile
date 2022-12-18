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
	zip releases/AddonTemplates.zip \
		AddOnTemplates.toc \
		init.lua \
		README.md \
		cmds/* \
		core/* \
		libs/* \
	&& mv releases/AddonTemplates.zip releases/AddonTemplates-$(shell cat ./VERSION).zip \
	&& git commit -a -m "Release $(shell cat ./VERSION)." \
	&& git tag -f $(shell cat ./VERSION)

.PHONY: test ci release
