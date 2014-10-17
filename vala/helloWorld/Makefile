default: hello

hello: hello.vala
	valac hello.vala

run: hello
	./hello

check-syntax:
	valac -C ${CHK_SOURCES}
