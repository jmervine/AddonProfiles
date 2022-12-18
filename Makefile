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

.PHONY: test ci
