
.PHONY: run test exe

run:
	@perl ./td.pl
	
test:
	@for test in `find t/ -type f -name "*.t" | sort`; do	\
		perl "$$test" || exit;								\
	done

#Need PAR Packager
exe:
	pp --icon data/img/icon.png -o td.exe -I lib/ td.pl