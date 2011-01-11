GIT = ''

.PHONY: run test

run:
	@perl ./td.pl
	
test:
	@for test in `find t/ -type f -name "*.t"`; do	\
		perl "$$test";								\
	done
