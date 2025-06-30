#include <stdint.h>
#include <stdbool.h>
#define MEMIO_BASE 0x04000000
#define SEG7_OFFSET 0x00
#define PSWITCH_OFFSET 0x48

#define SEG7_0 0xFC // 0b11111100
#define SEG7_1 0x60 // 0b01100000
#define SEG7_2 0xDA // 0b11011010
#define SEG7_3 0xF2 // 0b11110010
#define SEG7_4 0x66 // 0b01100110
#define SEG7_5 0xB6 // 0b10110110
#define SEG7_6 0xBE // 0b10111110
#define SEG7_7 0xE0 // 0b11100000
#define SEG7_8 0xFE // 0b11111110
#define SEG7_9 0xF6 // 0b11110110
#define SEG7_A 0xEE // 0b11101110
#define SEG7_B 0x3E // 0b00111110
#define SEG7_C 0x9C // 0b10011100
#define SEG7_D 0x7A // 0b01111010
#define SEG7_E 0x9E // 0b10011110
#define SEG7_F 0x8E // 0b10001110

static inline bool get_pswitch(uint8_t id) {
    int addr = MEMIO_BASE + PSWITCH_OFFSET;
    int shamt = id;
    if (0 <= id && id < 5) addr += 0, shamt -= 0;
    else if (5 <= id && id < 10) addr += 1, shamt -= 5;
    else if (10 <= id && id < 15) addr += 2, shamt -= 10;
    else if (15 <= id && id < 20) addr += 3, shamt -= 15;
    return ((*(volatile uint8_t *)addr) >> shamt) & 1;
}


static inline void write_7seg(uint32_t offset, uint8_t value) {
    volatile uint8_t *seg7 = (volatile uint8_t *)(MEMIO_BASE + SEG7_OFFSET);
    seg7[offset] = value;
    return;
}

void write_7seg_digit(uint32_t offset, uint8_t digit) {
    switch (digit) {
        case 0x0: write_7seg(offset, SEG7_0); break;
        case 0x1: write_7seg(offset, SEG7_1); break;
        case 0x2: write_7seg(offset, SEG7_2); break;
        case 0x3: write_7seg(offset, SEG7_3); break;
        case 0x4: write_7seg(offset, SEG7_4); break;
        case 0x5: write_7seg(offset, SEG7_5); break;
        case 0x6: write_7seg(offset, SEG7_6); break;
        case 0x7: write_7seg(offset, SEG7_7); break;
        case 0x8: write_7seg(offset, SEG7_8); break;
        case 0x9: write_7seg(offset, SEG7_9); break;
        case 0xA: write_7seg(offset, SEG7_A); break;
        case 0xB: write_7seg(offset, SEG7_B); break;
        case 0xC: write_7seg(offset, SEG7_C); break;
        case 0xD: write_7seg(offset, SEG7_D); break;
        case 0xE: write_7seg(offset, SEG7_E); break;
        case 0xF: write_7seg(offset, SEG7_F); break;
        default: write_7seg(offset, 0x00); break; // Turn off the segment
    }
}