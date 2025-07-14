#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#define MEMIO_BASE 0x04000000
#define SEG7_OFFSET 0x00
#define DOT_OFFSET 0x40
#define PSWITCH_OFFSET 0x48

#define DOT_NUM 8

#define SEG7_NUM 64
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

#define SEG7_G 0xBC
#define SEG7_H 0x6E
#define SEG7_I 0x60  
#define SEG7_J 0x78
#define SEG7_K 0xAE  
#define SEG7_L 0x1C
#define SEG7_M 0xEC  //
#define SEG7_N 0x6E  
#define SEG7_O 0xFC 
#define SEG7_P 0xCE
#define SEG7_Q 0xF6  
#define SEG7_R 0x0A  
#define SEG7_S 0xB6  
#define SEG7_T 0x1E  
#define SEG7_U 0x7C
#define SEG7_V 0x7C  //
#define SEG7_W 0x3C  
#define SEG7_X 0x6E  
#define SEG7_Y 0x76
#define SEG7_Z 0xDA 

#define SEG7_SPACE 0x00  // 消灯
#define SEG7_ALL_ON 0xFF // 全灯

inline bool get_pswitch(uint8_t id) {
    int addr = MEMIO_BASE + PSWITCH_OFFSET;
    int shamt = id;
    if (0 <= id && id < 5) addr += 0, shamt -= 0;
    else if (5 <= id && id < 10) addr += 1, shamt -= 5;
    else if (10 <= id && id < 15) addr += 2, shamt -= 10;
    else if (15 <= id && id < 20) addr += 3, shamt -= 15;
    return ((*(volatile uint8_t *)addr) >> shamt) & 1;
}

inline void write_7seg(uint32_t offset, uint8_t value) {
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

inline void write_dot(uint32_t offset, uint8_t value) {
    volatile uint8_t *seg7 = (volatile uint8_t *)(MEMIO_BASE + DOT_OFFSET);
    seg7[offset] = value;
    return;
}

uint8_t seg7_buf[SEG7_NUM];

#define TITLE 0
#define GAME 1
#define GAMESET 2

#define COOLTIME 3

int gameState;
int lifeA, lifeB;
int cooltimeA, cooltimeB;
uint16_t bulletA[4], bulletB[4]; 
int AY, BY;
unsigned int frameCount;

void write_7seg_buf_digit(uint32_t offset, uint8_t digit) {
    switch (digit) {
        case 0x0: seg7_buf[offset] = SEG7_0; break;
        case 0x1: seg7_buf[offset] = SEG7_1; break;
        case 0x2: seg7_buf[offset] = SEG7_2; break;
        case 0x3: seg7_buf[offset] = SEG7_3; break;
        case 0x4: seg7_buf[offset] = SEG7_4; break;
        case 0x5: seg7_buf[offset] = SEG7_5; break;
        case 0x6: seg7_buf[offset] = SEG7_6; break;
        case 0x7: seg7_buf[offset] = SEG7_7; break;
        case 0x8: seg7_buf[offset] = SEG7_8; break;
        case 0x9: seg7_buf[offset] = SEG7_9; break;
        case 0xA: seg7_buf[offset] = SEG7_A; break;
        case 0xB: seg7_buf[offset] = SEG7_B; break;
        case 0xC: seg7_buf[offset] = SEG7_C; break;
        case 0xD: seg7_buf[offset] = SEG7_D; break;
        case 0xE: seg7_buf[offset] = SEG7_E; break;
        case 0xF: seg7_buf[offset] = SEG7_F; break;
        default: seg7_buf[offset] = 0x00; break; // Turn off the segment
    }
}

void init(){
    gameState = TITLE;
    lifeA = 4;
    lifeB = 4;
    AY = 3;
    BY = 3;
    for(int i = 0; i < 4; i++) {
        bulletA[i] = 0;
        bulletB[i] = 0;
    }
    frameCount = 0;
    return;
}

void title() {
    write_7seg(0, 0xCE);//P
    write_7seg(1, 0x38);//u
    write_7seg(2, 0xB6);//S
    write_7seg(3, 0x2E);//h
    write_7seg(4, 0x3E);//b
    write_7seg(5, 0xDB);//2.
    write_7seg(6, 0x1A);//c
    write_7seg(7, 0xDB);//2.
    write_7seg(8, 0x00);
    write_7seg(9, 0x00);
    write_7seg(10, 0x00);
    write_7seg(11, 0x00);
    write_7seg(12, 0x00);
    write_7seg(13, 0x00);
    write_7seg(14, 0x00);
    write_7seg(15, 0x00);
    //line 2
    write_7seg(16, 0x00);
    write_7seg(17, 0x1E);//t
    write_7seg(18, 0x3A);//o
    write_7seg(19, 0x00);
    write_7seg(20, 0xCE);//P
    write_7seg(21, 0x1C);//L
    write_7seg(22, 0xEE);//A
    write_7seg(23, 0x76);//y
    write_7seg(24, 0x00);
    write_7seg(25, 0x00);
    write_7seg(26, 0x00);
    write_7seg(27, 0x00);
    write_7seg(28, 0x00);
    write_7seg(29, 0x00);
    write_7seg(30, 0x00);
    write_7seg(31, 0x00);
    //line 3
    write_7seg(32, 0x61);//1.
    write_7seg(33, 0x00);
    write_7seg(34, 0xB6);//S
    write_7seg(35, 0x2E);//h
    write_7seg(36, 0x3A);//o
    write_7seg(37, 0x3A);//o
    write_7seg(38, 0x1E);//t
    write_7seg(39, 0x00);
    write_7seg(40, 0x00);
    write_7seg(41, 0x00);
    write_7seg(42, 0x00);
    write_7seg(43, 0x00);
    write_7seg(44, 0x00);
    write_7seg(45, 0x00);
    write_7seg(46, 0x00);
    write_7seg(47, 0x00);
    //line 4
    write_7seg(48, 0xDB);//2.
    write_7seg(49, 0x00);
    write_7seg(50, 0x7A);//d
    write_7seg(51, 0x3A);//o
    write_7seg(52, 0x7A);//d
    write_7seg(53, 0xBC);//G
    write_7seg(54, 0x9E);//E
    write_7seg(55, 0x00);
    write_7seg(56, 0x00);
    write_7seg(57, 0x00);
    write_7seg(58, 0x00);
    write_7seg(59, 0x00);
    write_7seg(60, 0x00);
    write_7seg(61, 0x00);
    write_7seg(62, 0x00);
    write_7seg(63, 0x00);
    if (get_pswitch(7) == 1 && get_pswitch(12) == 1) {
        gameState = GAME;
    }
}

void gameUpdate() {
    bool a_up = get_pswitch(1);
    bool a_shoot = get_pswitch(11);
    bool a_down = get_pswitch(16);
    bool b_up = get_pswitch(4);
    bool b_shoot = get_pswitch(9);
    bool b_down = get_pswitch(19);
    if (a_up) AY -= 1;
    else if (a_down) AY += 1;
    if (b_up) BY -= 1;
    else if (b_down) BY += 1;

    AY = AY & 0x03;
    BY = BY & 0x03;

    if (a_shoot && cooltimeA == 0) {
        bulletA[AY] |= 0x8000;
        cooltimeA = COOLTIME;
    }
    if (b_shoot && cooltimeB == 0) {
        bulletB[BY] |= 0x1;
        cooltimeB = COOLTIME;
    }

    if ((bulletA[BY] & 1) == 1) lifeB -= 1;
    if ((bulletB[AY] >> 15 & 1) == 1) lifeA -= 1;


    if ((frameCount & 0xFF) == 0) {
        for (int i = 0; i < 4; i++) {
            bulletA[i] >>= 1;        
            bulletB[i] <<= 1;        
        }
    }

    if (lifeA < 0 || lifeB < 0) gameState = GAMESET;
    if (0 < cooltimeA) cooltimeA--;
    if (0 < cooltimeB) cooltimeB--;
    return;
}

void clear() {
    for (int i = 0; i < SEG7_NUM; i++) seg7_buf[i] = 0x00;
}

void gameDraw() {
    clear();
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 16; j++) {
            if (((bulletA[i] >> j) & 1) == 1) seg7_buf[i * 16 + (15 - j)] = 0x02;
            else if (((bulletB[i] >> j) & 1) == 1) seg7_buf[i * 16 + (15 - j)] = 0x02;
            else seg7_buf[i * 16 + (15 - j)] = 0x00;
        }
    }
    if (AY == 0) write_7seg_buf_digit(0, 0);
    else if (AY == 1) write_7seg_buf_digit(16, 0);
    else if (AY == 2) write_7seg_buf_digit(32, 0);
    else if (AY == 3) write_7seg_buf_digit(48, 0);
    if (BY == 0) write_7seg_buf_digit(15, 0);
    else if (BY == 1) write_7seg_buf_digit(31, 0);
    else if (BY == 2) write_7seg_buf_digit(47, 0);
    else if (BY == 3) write_7seg_buf_digit(63, 0);
}

void displayPoints() {
    uint8_t bits = 0xFF;
    for (int i = 0; i < 8; i+=2) {
        if (lifeA == 0) write_dot(i, bits >> 8);
        else if (lifeA == 1) write_dot(i, bits >> 6);
        else if (lifeA == 2) write_dot(i, bits >> 4);
        else if (lifeA == 3) write_dot(i, bits >> 2);
        else if (lifeA == 4) write_dot(i, bits);
    }
    for (int i = 1; i < 8; i+=2) {
        if (lifeB == 0) write_dot(i, bits << 8);
        else if (lifeB == 1) write_dot(i, bits << 6);
        else if (lifeB == 2) write_dot(i, bits << 4);
        else if (lifeB == 3) write_dot(i, bits << 2);
        else if (lifeB == 4) write_dot(i, bits);
    }
}

void display_game_over_centered() {
    write_7seg(4, SEG7_G);
    write_7seg(5, SEG7_A);
    write_7seg(6, SEG7_M);
    write_7seg(7, SEG7_E);
    // write_7seg(8, SEG7_SPACE);
    write_7seg(8, SEG7_O);
    write_7seg(9, SEG7_V);
    write_7seg(10, SEG7_E);
    write_7seg(11, SEG7_R);

    // その他の桁を空白に
    for (int i = 0; i < 4; i++) write_7seg(i, SEG7_SPACE);
    for (int i = 13; i < 16; i++) write_7seg(i, SEG7_SPACE);
}

void display_left_win_right_lose() {
    for (int i = 0; i < 10; i++) {
        // 左側: GG（列3, 4）
        write_7seg(16 + 3, SEG7_G);
        write_7seg(16 + 4, SEG7_G);
        write_7seg(32 + 3, SEG7_G);
        write_7seg(32 + 4, SEG7_G);
        write_7seg(48 + 3, SEG7_G);
        write_7seg(48 + 4, SEG7_G);

        // 右側: LOSE（列10〜13）
        write_7seg(16 + 10, SEG7_L);
        write_7seg(16 + 11, SEG7_O);
        write_7seg(16 + 12, SEG7_S);
        write_7seg(16 + 13, SEG7_E);
        write_7seg(32 + 10, SEG7_L);
        write_7seg(32 + 11, SEG7_O);
        write_7seg(32 + 12, SEG7_S);
        write_7seg(32 + 13, SEG7_E);
        write_7seg(48 + 10, SEG7_L);
        write_7seg(48 + 11, SEG7_O);
        write_7seg(48 + 12, SEG7_S);
        write_7seg(48 + 13, SEG7_E);




        // 簡易ディレイ（点灯）
        for (volatile int d = 0; d < 10; d++) asm("nop");

        // GG消す（LOSEは残す）
        write_7seg(16 + 3, SEG7_SPACE);
        write_7seg(16 + 4, SEG7_SPACE);
        write_7seg(32 + 3, SEG7_SPACE);
        write_7seg(32 + 4, SEG7_SPACE);
        write_7seg(48 + 3, SEG7_SPACE);
        write_7seg(48 + 4, SEG7_SPACE);



        // 簡易ディレイ（消灯中）
        for (volatile int d = 0; d < 10; d++) asm("nop");
    }

    // 最後にGGを点灯しておく
        write_7seg(16 + 3, SEG7_G);
        write_7seg(16 + 4, SEG7_G);
        write_7seg(32 + 3, SEG7_G);
        write_7seg(32 + 4, SEG7_G);
        write_7seg(48 + 3, SEG7_G);
        write_7seg(48 + 4, SEG7_G);
}

void display_left_lose_right_win() {
      for (int i = 0; i < 10; i++) {
        // 右側: GG（列3, 4）
        write_7seg(16 + 11, SEG7_G);
        write_7seg(16 + 12, SEG7_G);
        write_7seg(32 + 11, SEG7_G);
        write_7seg(32 + 12, SEG7_G);
        write_7seg(48 + 11, SEG7_G);
        write_7seg(48 + 12, SEG7_G);

        // 右側: LOSE（列10〜13）
        write_7seg(16 + 2, SEG7_L);
        write_7seg(16 + 3, SEG7_O);
        write_7seg(16 + 4, SEG7_S);
        write_7seg(16 + 5, SEG7_E);
        write_7seg(32 + 2, SEG7_L);
        write_7seg(32 + 3, SEG7_O);
        write_7seg(32 + 4, SEG7_S);
        write_7seg(32 + 5, SEG7_E);
        write_7seg(48 + 2, SEG7_L);
        write_7seg(48 + 3, SEG7_O);
        write_7seg(48 + 4, SEG7_S);
        write_7seg(48 + 5, SEG7_E);




        // 簡易ディレイ（点灯）
        for (volatile int d = 0; d < 10; d++) asm("nop");

        // GG消す（LOSEは残す）
        write_7seg(16 + 11, SEG7_SPACE);
        write_7seg(16 + 12, SEG7_SPACE);
        write_7seg(32 + 11, SEG7_SPACE);
        write_7seg(32 + 12, SEG7_SPACE);
        write_7seg(48 + 11, SEG7_SPACE);
        write_7seg(48 + 12, SEG7_SPACE);



        // 簡易ディレイ（消灯中）
        for (volatile int d = 0; d < 10; d++) asm("nop");
    }

    // 最後にGGを点灯しておく
        write_7seg(16 + 11, SEG7_G);
        write_7seg(16 + 12, SEG7_G);
        write_7seg(32 + 11, SEG7_G);
        write_7seg(32 + 12, SEG7_G);
        write_7seg(48 + 11, SEG7_G);
        write_7seg(48 + 12, SEG7_G);
}


int main() {
    init();
    while (true) {
        if (gameState == TITLE) {
            init();
            title();
        }
        else if (gameState == GAME) {
            gameUpdate();
            gameDraw();
            for (int i = 0; i < SEG7_NUM; i++) write_7seg(i, seg7_buf[i]);
            displayPoints();
        } else if (gameState == GAMESET) {
            display_game_over_centered();
            if (lifeA < 0) display_left_lose_right_win();
            else if (lifeB < 0) display_left_win_right_lose();
            if (get_pswitch(0)) gameState = TITLE;
        }
    }
    return 0;
}
