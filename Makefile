LEANSDR_SRC	= ../leansdr
TARGET_PLUTOSDR	= /tmp/leantrx-plutosdr.zip

default:
	@echo "make leansdr	Compile and import binaries from $(LEANSDR_SRC)"
	@echo "make plutosdr	Package into $(TARGET_PLUTOSDR)"
	@exit 1

# Compile and import leansdr binaries.

ARCH	:= $(shell uname -m)

LEANSDR_BINARIES=	leaniiotx leaniiorx  \
			leantsgen leandvbtx leandvb \
			leanmlmrx \
			leansdrserv

leansdr:	$(LEANSDR_BINARIES:%=bin/$(ARCH)/%)

bin/$(ARCH)/%:	$(LEANSDR_SRC)/src/apps/%.$(ARCH)
	cp -a $^ $@

$(LEANSDR_SRC)/src/apps/%.$(ARCH):
	make -C $(LEANSDR_SRC)/src/apps $*.$(ARCH)

# Generate zip.

plutosdr:	$(TARGET_PLUTOSDR)

$(TARGET_PLUTOSDR):
	rm -f $@
	-git describe  > html/version.txt
	cd .. && zip -r $@ leantrx
	cd bsp/plutosdr && zip $@ runme-leantrx
