B = bin
O = obj
S = src
E = ext
PKGS = glib-2.0 gtk+-3.0
LIBS = $(shell pkg-config --libs $(PKGS)) -lGL -lc
LIBFLAGS = $(shell pkg-config --cflags $(PKGS))
BITS = 64

AS = nasm
ASFLAGS = 

CFLAGS = -m$(BITS) -Os -fomit-frame-pointer -fno-unwind-tables -ffast-math -march=haswell -ffunction-sections -fdata-sections
CFLAGS += $(LIBFLAGS)
SMOLCFLAGS = -no-pie -fno-PIE -fno-PIC -fno-plt -fno-stack-protector -fno-stack-check
BOLDFLAGS = -no-pie -fno-PIE -fno-PIC -fno-plt
COMPRESS = xz -c -9e --format=lzma --lzma1=preset=9,lc=1,lp=0,pb=0


.PHONY: all clean
all: $(B)/demo
clean:
	@rm -rfv $(B) $(O)


$(B)/demo: $(B)/demo.o.smol.vondehi
	cp $< $@

$(B)/demo.o: $(O)/main.o


.SECONDARY:

$(B)/%.fishypack: $(B)/% $(O)/fishypack
	$(COMPRESS) $< | cat $(O)/fishypack - > $@
	chmod +x $@

$(B)/%.vondehi: $(B)/% $(O)/vondehi
	$(COMPRESS) $< | cat $(O)/vondehi - > $@
	chmod +x $@

$(B)/%.smol: CFLAGS += $(SMOLCFLAGS)
$(B)/%.smol: $(B)/%
	$(E)/smol/smold $(LDFLAGS) $(LIBS) $(filter %.o,$^) -o $@

$(B)/%.bold: CFLAGS += $(BOLDFLAGS)
$(B)/%.bold: $(B)/%
	ln -sf ./ext/bold/runtime/bold_ibh*.o .
	./ext/bold/bold -c -a $(LIBS) $(filter %.o,$^) -o $@
	rm -f bold_ibh*.o

$(B)/%.full: $(B)/%.o
	$(CC) $< $(LDFLAGS) $(LIBS) -o $@

$(B)/%.o: | $(B)/
	$(LD) -r $(filter %.o,$^) -o $@


$(O)/fishypack: $(E)/fishypack/packer/header-64.asm | $(O)/
	$(MAKE) -C $(E)/fishypack/packer header-64
	cp $(E)/fishypack/packer/header-64 $@

$(O)/vondehi: $(E)/vondehi/vondehi.asm | $(O)/
	$(MAKE) -C $(E)/vondehi vondehi
	cp $(E)/vondehi/vondehi $@


$(O)/%.o: $(S)/%.c | $(O)/
	$(CC) $(CFLAGS) -c $< -o $@

$(B)/ $(O)/:
	@mkdir -vp $@
