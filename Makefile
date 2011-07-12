
.PHONY: run test exe

run:
	@perl ./td.pl
	
test:
	@for test in `find t/ -type f -name "*.t" | sort`; do	\
		perl "$$test" || exit;								\
	done

#Need PAR Packager
exe:
	pp --verbose --compile       \
		--compress=9             \
		--icon data/img/icon.png \
		--output td.exe          \
		td.pl