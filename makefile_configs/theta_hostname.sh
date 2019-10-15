#!/bin/sh

export POLIMER_MAKE_MSR=yes
export POLIMER_MAKE_POWMGR=yes
export POLIMER_MAKE_JLSE=no
export POLIMER_MAKE_NOMPI=no
export POLIMER_MAKE_CRAY=yes
export POLIMER_MAKE_CRAYPMI=no
export POLIMER_MAKE_BGQ=no
export POLIMER_MAKE_NOOMP=yes
export POLIMER_MAKE_COBALT=yes
export POLIMER_MAKE_DEBUG=no
export POLIMER_MAKE_TRACE=no
export POLIMER_MAKE_TIMER_OFF=no

cd ..
export CRAYPE_LINK_TYPE=dynamic
make clean
make all
