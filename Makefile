NAME = eggos
BUILDDIR=/dev/shm/${NAME}
TARGET = $(BUILDDIR)/eggos

BUILDSRC:=$(BUILDDIR)/Makefile
CORESRC:=$(BUILDDIR)/eggos.c
COREFSMSRC:=$(BUILDDIR)/egg-fsm.c
PROTOFSMSRC:=$(BUILDDIR)/egg-proto-fsm.c
PROTOSRC:=$(BUILDDIR)/tightrope.h
LIBRARY:=$(BUILDDIR)/libopencm3

include .config

all: $(TARGET)

$(TARGET): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make; cd -

$(CORESRC): core.org | prebuild
	org-tangle $<

$(COREFSMSRC): egg-fsm.xlsx | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg --style table

$(PROTOFSMSRC): egg-proto-fsm.xlsx | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg_proto --style table

$(BUILDSRC): build.org | prebuild
	org-tangle $<
	sed -i 's/        /\t/g' $@
	sed -i 's/        /\t/g' $(BUILDDIR)/libopencm3.rules.mk
	sed -i 's/        /\t/g' $(BUILDDIR)/libopencm3.target.mk

$(BUILDDIR)/protocol.tr: protocol.org | prebuild
	org-tangle $<

$(PROTOSRC): $(BUILDDIR)/protocol.tr | prebuild
	tightrope -entity -serial -clang -d $(BUILDDIR) $<

$(LIBRARY):
	ln -sf $(LIBOPENCM3_PATH) $(BUILDDIR)

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean prebuild
