
test: test0.o test1.o
	gcc -o $@ $^

.c.o:
	gcc -c $<

clean:
	rm -rf *.o *.c test .zir

