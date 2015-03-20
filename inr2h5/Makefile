CPPFLAGS = `inrinfo --cflags`
LDFLAGS  = `inrinfo --libs`
CC       = h5cc

all: inr2h5 h52inr

inr2h5 h52inr: h5utils.o
clean:
	$(RM) inr2h5.o h52inr.o h5utils.o inr2h5 h52inr
	./tests.sh clean

double float unsigned signed bits packed exponent: inr2h5 h52inr
	./tests.sh $@

.PHONY: all clean
.PHONY: double float unsigned signed bits packed exponent
