# Programs
ASM			= nasm
DASM		= ndisasm
CC			= gcc
LD			= ld

# Flags
ASMBFLAGS	= -I boot/include/
ASMKFLAGS	= -I include/ -f elf
CFLAGS		= -I include/ -c -m32 -fno-builtin
LDFLAGS		= -s -m elf_i386 -Ttext $(ENTRYPOINT)

# objects
OBJS			= kernel/kernel.o kernel/start.o lib/kliba.o lib/string.o

# targets 
TARGETBOOT 		= boot/boot.bin
TARGETLOADER 	= boot/loader.bin
TARGETKERNEL	= kernel.bin

# some varible
ENTRYPOINT	= 0x30400
ENTRYOFFSET	=   0x400
FLOPPYIMAGE = floppy.img
MOUNTDIR = /mnt/floppy/

# Default starting position
all: floppy boot kernel flash run

# build boot and kernel 
build: boot kernel

# create floppy image
floppy:
ifeq ($(wildcard ./$(FLOPPYIMAGE)),)
	@echo "please input 1, fd, enter, floppy.img"
	@echo ""
	bximage	
endif

# build boot
boot: $(TARGETBOOT) $(TARGETLOADER)

# build kernel
kernel: $(TARGETKERNEL)

# flash os to image
flash:
	dd if=$(TARGETBOOT) of=$(FLOPPYIMAGE) bs=512 count=1 conv=notrunc
	sudo mount -o loop $(FLOPPYIMAGE) $(MOUNTDIR) 
	sudo cp -fv $(TARGETLOADER) $(MOUNTDIR)
	sudo cp -fv $(TARGETKERNEL) $(MOUNTDIR) 
	sudo umount $(MOUNTDIR) 

# run
run:
	bochs -q

# build specfic files
$(TARGETBOOT):
	$(MAKE) -C boot/ boot.bin

$(TARGETLOADER):
	$(MAKE) -C boot/ loader.bin

$(TARGETKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGETKERNEL) $(OBJS)

kernel/kernel.o : kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/start.o : kernel/start.c include/type.h include/const.h include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

lib/kliba.o : lib/kliba.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<


.PHONY : all floppy build boot kernel flash run clean help

help:
	@echo "Usage: make [all|floppy|build|boot|kernel|flash|run|clean|help]"
	@echo "Available targets:"
	@echo ""
	@echo "  all       Build and run the projce, default exec"
	@echo "  floppy    Create a floppy disk image"
	@echo "  build     Build boot and kernel"
	@echo "  boot      Build boot" 
	@echo "  kernel    Build kernel" 
	@echo "  flash     Flash boot and kernel to floppy disk" 
	@echo "  run       Run os"
	@echo "  clean     Clean up the project"
	@echo "  help      Show this help message"

clean :
	rm -f $(FLOPPYIMAGE) $(TARGETLOADER) $(TARGETBOOT) $(TARGETKERNEL) $(OBJS) 
