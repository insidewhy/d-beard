# gdc ?= 1
.PHONY: test

cwd      ?= .
dmd      ?= $(if ${gdc},gdmd,dmd)
subdirs  ?= .
libfiles ?= $(foreach d,$(addprefix ${cwd}/,${subdirs}),$(wildcard ${d}/*.d))

O ?= ${cwd}/.obj

${O}/%: %.d ${libfiles}
	@mkdir -p ${O}
	${dmd} -I../.. ${comp_args} -od${O} -of$@ $^

test:
	${MAKE} -C test
