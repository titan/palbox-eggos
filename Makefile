NAME = eggos
BUILDDIR=/dev/shm/$(NAME)
TARGET = $(BUILDDIR)/eggos.elf
DATE=$(shell git log -n 1 --date=short --pretty=format:%cd)
COMMIT=$(shell git log -n 1 --pretty=format:%h)
BIN1 = /dev/shm/$(NAME)-1-$(COMMIT)-$(DATE).bin
BIN2 = /dev/shm/$(NAME)-2-$(COMMIT)-$(DATE).bin
BIN3 = /dev/shm/$(NAME)-3-$(COMMIT)-$(DATE).bin
BIN4 = /dev/shm/$(NAME)-4-$(COMMIT)-$(DATE).bin
BIN5 = /dev/shm/$(NAME)-5-$(COMMIT)-$(DATE).bin
BIN6 = /dev/shm/$(NAME)-6-$(COMMIT)-$(DATE).bin
BIN7 = /dev/shm/$(NAME)-7-$(COMMIT)-$(DATE).bin
BIN8 = /dev/shm/$(NAME)-8-$(COMMIT)-$(DATE).bin

BUILDSRC:=$(BUILDDIR)/Makefile
CORESRC:=$(BUILDDIR)/eggos.c
COREFSMSRC:=$(BUILDDIR)/egg-fsm.c
EPIGYNYSRC:=$(BUILDDIR)/epigyny.c
DRIVERSRC:=$(BUILDDIR)/lock.c
REPLSRC:=$(BUILDDIR)/repl.c
UTILSRC:=$(BUILDDIR)/base64.c $(BUILDDIR)/hash.c $(BUILDDIR)/ring.c $(BUILDDIR)/utility.c
PROTOFSMSRC:=$(BUILDDIR)/egg-proto-fsm.c
PROTOSRC:=$(BUILDDIR)/tightrope.h
REPLFSMSRC:=$(BUILDDIR)/egg-repl-fsm.c
REPLLEXFSMSRC:=$(BUILDDIR)/egg-repl-lex-fsm.c
INFRAREDFSMSRC:=$(BUILDDIR)/egg-infrared-fsm.c
LIBRARY:=$(BUILDDIR)/libopencm3
CONFIG:=$(BUILDDIR)/config
CONFIGSRC:=config.orig

DEPENDS = $(BUILDSRC) $(CORESRC) $(EPIGYNYSRC) $(DRIVERSRC) $(REPLSRC) $(UTILSRC) $(PROTOSRC) $(LIBRARY) $(COREFSMSRC) $(PROTOFSMSRC) $(CONFIGSRC) $(REPLFSMSRC) $(REPLLEXFSMSRC) $(INFRAREDFSMSRC)

include .config

all: $(TARGET)

$(TARGET): $(DEPENDS)
	@sed '1s/\$$/1/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make; cd -

$(CORESRC): core.org | prebuild
	org-tangle $<

$(EPIGYNYSRC): epigyny.org | prebuild
	org-tangle $<

$(DRIVERSRC): driver.org | prebuild
	org-tangle $<

$(REPLSRC): repl.org | prebuild
	org-tangle $<

$(UTILSRC): utility.org | prebuild
	org-tangle $<

$(COREFSMSRC): egg-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg --style table

$(PROTOFSMSRC): egg-proto-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg_proto --style table

$(REPLFSMSRC): egg-repl-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg_repl --style table

$(REPLLEXFSMSRC): egg-repl-lex-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg_repl_lex --style table

$(INFRAREDFSMSRC): egg-infrared-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix egg_infrared --style code

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

flash: $(TARGET)
	cd $(BUILDDIR); make eggos.stlink-flash V=1; cd -

release: $(BIN1) $(BIN2) $(BIN3) $(BIN4) $(BIN5) $(BIN6) $(BIN7) $(BIN8)

$(BIN1): $(DEPENDS)
	@sed '1s/\$$/1/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN2): $(DEPENDS)
	@sed '1s/\$$/2/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN3): $(DEPENDS)
	@sed '1s/\$$/3/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN4): $(DEPENDS)
	@sed '1s/\$$/4/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN5): $(DEPENDS)
	@sed '1s/\$$/5/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN6): $(DEPENDS)
	@sed '1s/\$$/6/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN7): $(DEPENDS)
	@sed '1s/\$$/7/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

$(BIN8): $(DEPENDS)
	@sed '1s/\$$/8/' $(CONFIGSRC) > $(CONFIG)
	cd $(BUILDDIR); make clean; make bin; cd -
	cp $(BUILDDIR)/$(NAME).bin $@

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean flash prebuild release
