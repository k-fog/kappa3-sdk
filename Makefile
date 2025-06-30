CC=riscv64-unknown-elf-gcc
CFLAGS=-Wall -O1 -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding

all: main.bin main.hex

main.hex: main.bin
	# python3 bin2hex.py $< $@
	# riscv64-unknown-elf-objcopy -I binary -O ihex $< $@
	python3 bin2ihex_bytewise.py $< $@

main.bin: main.elf
	riscv64-unknown-elf-objcopy -O binary $< $@

main.elf: main.ld entry.s main.c
	$(CC) $(CFLAGS) -T main.ld entry.s main.c -o $@

clean:
	rm -f main.elf main.bin main.hex

.PHONY: all clean
