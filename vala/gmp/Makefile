
default: test

test: test.vala
	valac --pkg=gmp --vapidir=. -X -lgmp test.vala

run: test
	./test

check-syntax:
	valac --pkg=gmp --vapidir=. -C ${CHK_SOURCES}
