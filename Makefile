NAME = eggos
BUILDDIR=/dev/shm/$(NAME)
TARGET = $(BUILDDIR)/eggos.elf
BIN1 = /dev/shm/$(NAME)-1.bin
BIN2 = /dev/shm/$(NAME)-2.bin
BIN3 = /dev/shm/$(NAME)-3.bin
BIN4 = /dev/shm/$(NAME)-4.bin
BIN5 = /dev/shm/$(NAME)-5.bin
BIN6 = /dev/shm/$(NAME)-6.bin
BIN7 = /dev/shm/$(NAME)-7.bin
BIN8 = /dev/shm/$(NAME)-8.bin

BUILDSRC:=$(BUILDDIR)/Makefile
CORESRC:=$(BUILDDIR)/eggos.c
COREFSMSRC:=$(BUILDDIR)/egg-fsm.c
PROTOFSMSRC:=$(BUILDDIR)/egg-proto-fsm.c
PROTOSRC:=$(BUILDDIR)/tightrope.h
LIBRARY:=$(BUILDDIR)/libopencm3

include .config

all: $(TARGET)

$(TARGET): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make -e EGGID=1; cd -

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

release: $(BIN1) $(BIN2) $(BIN3) $(BIN4) $(BIN5) $(BIN6) $(BIN7) $(BIN8)

$(BIN1): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=1 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN2): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=2 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN3): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=3 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN4): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=4 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN5): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=5 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN6): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=6 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN7): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=7 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN8): $(BUILDSRC) $(CORESRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC)
	cd $(BUILDDIR); make clean; make -e EGGID=8 bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all release clean prebuild
