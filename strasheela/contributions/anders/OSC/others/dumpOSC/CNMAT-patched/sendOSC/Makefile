LIBOSCDIR = ../libOSC
LIBOSC = ${LIBOSCDIR}/libOSC.a
CFLAGS=  -O2 -I$(LIBOSCDIR)

sendOSC: sendOSC.o htmsocket.o ${LIBOSC}
	${CC} -o sendOSC sendOSC.o htmsocket.o  ${LIBOSC}

${LIBOSC}:
	echo "You need to go to " ${LIBOSCDIR} " and do a make."

clean:
	rm -f sendOSC *.o
