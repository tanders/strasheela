CC = cc
CFLAGS = -g -n32 

OBJS = OSC-callbacklist.o OSC-receive.o \
	OSC-timetag.o OSC-system-dependent.o OSC-string-help.o \
	OSC-priority-queue.o OSC-drop.o OSC-address-space.o \
	OSC-pattern-match.o NetworkReturnAddress.o

TESTPQ_OBJS = test-priority-queue.o OSC-priority-queue-heap.o \
	 OSC-system-dependent.o OSC-timetag.o

simplesynth-osc: simplesynth-osc.o  ${OBJS}
	${CC} $(CFLAGS) -o $@ ${OBJS} simplesynth-osc.o  -laudio -lm

test-pq: ${TESTPQ_OBJS}
	${CC} $(CFLAGS) -o $@  ${TESTPQ_OBJS}


test: ${OBJS} testOSC.o
	${CC} $(CFLAGS) -o $@ ${OBJS} testOSC.o


tags: *.[c]
	ctags *.[ch] > tags

clean:
	rm -f test test-pq *.o core

