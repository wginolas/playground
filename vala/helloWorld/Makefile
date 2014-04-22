hello.c: hello.vala
	valac -C hello.vala

hello: hello.c
	gcc -I /usr/include/glib-2.0/ -I /usr/lib/x86_64-linux-gnu/glib-2.0/include/ -lglib hello.c -o hello
