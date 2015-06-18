CFLAGS=-Wall -g

test: test.o
	$(CC) $(LDFLAGS) jsmn/jsmn.o $< -o $@

test.o: test.c
	$(CC) -c $(CFLAGS) $< -o $@

run: test
	./test

clean:
	rm -f test
	rm -f *.o

.PHONY: run clean
