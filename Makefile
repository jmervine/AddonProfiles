lauunit ?= "https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua"

libs:
	make -p libs

libs/luaunit.lua: libs
	curl -s https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua > libs/luaunit.lua
