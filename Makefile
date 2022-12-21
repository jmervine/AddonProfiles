test: Libs
	lua ./test/test.lua -v

Libs: Libs/LUAUnit/luaunit.lua Libs/Base64/base64.lua

Libs/LUAUnit/luaunit.lua:
	mkdir -p Libs/LUAUnit
	curl -s https://raw.githubusercontent.com/bluebird75/luaunit/LUAUNIT_V3_4/luaunit.lua > Libs/LUAUnit/luaunit.lua

Libs/Base64/base64.lua:
	mkdir -p Libs/Base64
	# Modify base64.lua in stream to work with WoW using 'sed'
	curl -s https://raw.githubusercontent.com/iskolbin/lbase64/master/base64.lua \
		| sed 's/^return base64/Base64 \= base64/' > Libs/Base64/base64.lua

ci:
	docker build -t jmervine/addonprofiles:test -f Dockerfile.test .
	docker run -t jmervine/addonprofiles:test

clean:
	rm -rf Libs/LUAUnit
	rm -rf Libs/Base64

.PHONY: test ci release
