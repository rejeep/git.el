EMACS ?= emacs
CASK ?= cask

all: test

test: clean-elc
	${CASK} exec ert-runner
	${MAKE} compile
	${CASK} exec ert-runner
	${MAKE} clean-elc

compile:
	${CASK} exec ${EMACS} -Q -batch -f batch-byte-compile git.el

clean-elc:
	rm git.elc

.PHONY:	all test docs
