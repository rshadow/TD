
.PHONY: run test exe i18n

LANGS	:=	$(shell find ./po -type f -name '*.po')

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

i18n:
	find							\
		./lib						\
		./data/conf					\
		./data/level -type f |		\
	xargs							\
	xgettext 						\
		--language=Perl				\
		--add-comments				\
		--sort-by-file				\
		--output-dir=po				\
		--output=TEMPLATE.pot		\
		--force-po					\
		-
	for f in $(LANGS); do			\
		msgmerge					\
			--update				\
			--backup=off			\
			--force-po				\
			--sort-by-file			\
			$$f po/TEMPLATE.pot;	\
	done;