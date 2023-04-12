# Programs
ASM			:=	nasm

# Flags
ASM_FLAGS	:= 	-I include/

# objects
TARGET 		:= boot.bin loader.bin

# Default starting position
all: $(TARGET)

boot.bin: boot.asm ./include/load.inc ./include/fat12hdr.inc 
	$(ASM) $(ASM_FLAGS) -o $@ $<

loader.bin: loader.asm ./include/pm.inc ./include/fat12hdr.inc ./include/load.inc	
	$(ASM) $(ASM_FLAGS) -o $@ $<

.PHONY: clean

clean:
	rm -rf $(TARGET)
