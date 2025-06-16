CC=riscv64-unknown-elf-gcc
CFLAGS=-march=rv32i -mabi=ilp32 -nostdlib -ffreestanding

main.hex: main.elf
	riscv64-unknown-elf-objcopy -O ihex $+ $@

main.elf: main.ld entry.s main.c
	$(CC) $(CFLAGS) -T main.ld entry.s main.c -o $@

clean:
	rm main.bin main.elf

.PHONY: clean
