POLIMER_MAKE_MSR?=yes
POLIMER_MAKE_POWMGR?=yes
POLIMER_MAKE_JLSE?=no
POLIMER_MAKE_NOMPI?=no
POLIMER_MAKE_CRAY?=yes
POLIMER_MAKE_BGQ?=no
POLIMER_MAKE_NOOMP?=no
POLIMER_MAKE_COBALT?=yes
POLIMER_MAKE_DEBUG?=no
POLIMER_MAKE_TRACE?=no
POLIMER_MAKE_TIMER_OFF?=no

CFLAGS=-I. -O3 -g
Q_AR=ar
CC=`which cc`
LIB=
#JLSE
ifeq ($(POLIMER_MAKE_JLSE),yes)
CFLAGS+=-D_COBALT
ifneq ($(POLIMER_MAKE_NOMPI),yes)
CC=`which mpicc`
endif
ifneq ($(POLIMER_MAKE_NOOMP),yes)
CFLAGS+=-fopenmp
endif
endif

#use MSRs/RAPL
ifeq ($(POLIMER_MAKE_MSR),yes)
CFLAGS+=-D_MSR
ifeq ($(POLIMER_MAKE_POWMGR),yes)
CFLAGS+=-D_POWMGR
endif
endif

#CRAY
ifeq ($(POLIMER_MAKE_CRAY), yes)
CFLAGS+=-D_PMI -D_CRAY #-I${PMILOC}/include
PMILOC=/opt/cray/pe/pmi/default
#LIB+=-L${PMILOC}/lib64 ${PMILOC}/lib64/libpmi.a
ifneq ($(POLIMER_MAKE_NOOMP),yes)
CFLAGS+=-qopenmp
endif
endif

#BGQ
ifeq ($(POLIMER_MAKE_BGQ),yes)
CC=mpixlc
ifneq ($(POLIMER_MAKE_NOOMP),yes)
CFLAGS+= -qsmp=omp -qthreaded 
endif
CFLAGS+=-D_BGQ -qpic
Q_AR = /bgsys/drivers/ppcfloor/gnu-linux/bin/powerpc64-bgq-linux-ar
else
CFLAGS+=-fPIC
endif

#other flags
ifeq ($(POLIMER_MAKE_DEBUG),yes)
CFLAGS+=-D_DEBUG
endif
ifeq ($(POLIMER_MAKE_TRACE),yes)
CFLAGS+=-D_TRACE
endif
ifeq ($(POLIMER_MAKE_TIMER_OFF),yes)
CFLAGS+=-D_TIMER_OFF
endif
ifeq ($(POLIMER_MAKE_NOMPI),yes)
CFLAGS+=-D_NOMPI
endif
ifeq ($(POLIMER_MAKE_NOOMP),yes)
CFLAGS+=-D_NOOMP
endif
ifeq ($(POLIMER_MAKE_COBALT),yes)
CFLAGS+=-D_COBALT
endif

CFLAGS+=-I./include

LIBDIR=lib
OBJDIR=bin

ifeq ($(POLIMER_MAKE_TIMER_OFF),yes)
LIBDIR=lib_notimer
OBJDIR=bin_notimer
endif


all: $(LIBDIR)/libpolimer.a $(LIBDIR)/libpolimer.so
notimer: $(LIBDIR)/libpolimer_notimer.a $(LIBDIR)/libpolimer_notimer.so

OBJ = $(OBJDIR)/PoLiMEr.o $(OBJDIR)/PoLiLog.o $(OBJDIR)/output.o $(OBJDIR)/frequency_handler.o $(OBJDIR)/helpers.o

ifneq ($(POLIMER_MAKE_NOMPI),yes)
OBJ+= $(OBJDIR)/mpi_handler.o
endif

ifeq ($(POLIMER_MAKE_MSR),yes)
OBJ+= $(OBJDIR)/msr_handler.o $(OBJDIR)/power_cap_handler.o
ifeq ($(POLIMER_MAKE_POWMGR),yes)
OBJ+= $(OBJDIR)/power_manager.o
endif
endif

ifeq ($(POLIMER_MAKE_CRAY),yes)
OBJ+= $(OBJDIR)/cray_handler.o
endif

ifeq ($(POLIMER_MAKE_BGQ),yes)
OBJ+= $(OBJDIR)/bgq_handler.o
endif

$(OBJ): $(OBJDIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ $(LIB)

$(LIBDIR)/libpolimer.a: $(OBJ)
	$(Q_AR) rcs $@ $(OBJ)

$(LIBDIR)/libpolimer.so: $(OBJ)
	`which cc` -shared -o $@ $(OBJ)

clean:
	rm -f lib/*.a bin/*.o lib/*.so a.out
clean-notimer:
	rm -f lib_notimer/*.a bin_notimer/*.o lib_notimer/*.so a.out
