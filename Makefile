lauunit ?= "https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua"

test: Libs/LUAUnit/luaunit.lua
	lua ./test/test.lua -v

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
	-git commit -a -m "Release $(shell cat ./VERSION)."
	git tag -f $(shell cat ./VERSION)

.PHONY: test ci release
