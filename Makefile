GIT = ''

.PHONY: run test

run:
	@perl ./td.pl
	
test:
	@for test in `find t/ -type f -name "*.t" | sort`; do	\
		perl "$$test";								\
	done

#Need PAR Packager
exe:
	pp --icon data/img/icon.png -o td.exe -I lib/ td.pl