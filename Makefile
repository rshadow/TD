GIT = ''

.PHONY: run test

run:
	@perl ./td.pl
	
test:
	@for test in `find t/ -type f -name "*.t" | sort`; do	\
		perl "$$test";								\
	done
