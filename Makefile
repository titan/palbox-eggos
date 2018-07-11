NAME = eggos
BUILDDIR=/dev/shm/${NAME}
TARGET = $(BUILDDIR)/eggos

BUILDSRC:=$(BUILDDIR)/Makefile
CORESRC:=$(BUILDDIR)/eggos.c
PROTOSRC:=$(BUILDDIR)/tightrope.h
LIBRARY:=$(BUILDDIR)/libopencm3

include .config

all: $(TARGET)

$(TARGET): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY)
	cd $(BUILDDIR); make; cd -

$(CORESRC): core.org | prebuild
	org-tangle $<

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
