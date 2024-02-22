ASM = nasm
FILE_TYPE = -f elf64
OBJECT = daytime_client.o
SOURCE = daytime_client.asm
LINKER = ld
OUT = daytime_client

build: $(OBJECT)
	$(LINKER) $(LDFLAGS) -o $(OUT) $(OBJECT)

$(OBJECT):
	$(ASM) $(FILE_TYPE) $(SOURCE) -o $(OBJECT)

clean:
	rm -rf *.o $(OUT)
