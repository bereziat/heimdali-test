# Sous Ubuntu faire: apt-get install libhdf5-serial-dev

CPPFLAGS = `inrinfo --cflags` -Dimagex_=imagenf_
LDLIBS   = `inrinfo --libs`
CC       = h5cc

all: inr2h5 h52inr

inr2h5 h52inr: h5utils.o
clean:
	$(RM) inr2h5.o h52inr.o h5utils.o inr2h5 h52inr
	./tests.sh clean

tests: double float unsigned signed bits packed exponent

double float unsigned signed bits packed exponent: inr2h5 h52inr
	SILENT=$(SILENT) ./tests.sh $@

.PHONY: all clean tests
.PHONY: double float unsigned signed bits packed exponent
