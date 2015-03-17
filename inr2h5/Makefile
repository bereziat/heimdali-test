CPPFLAGS = `inrinfo --cflags`
LDFLAGS  = `inrinfo --libs`
CC       = h5cc

all: inr2h5 h52inr

clean:
	$(RM) inr2h5.o h52inr.o inr2h5 h52inr
	./tests.sh clean

double float unsigned signed bits packed exponent:
	./tests.sh $@

.PHONY: all clean
.PHONY: double float unsigned signed bits packed exponent
