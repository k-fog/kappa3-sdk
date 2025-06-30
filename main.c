#include "mu500lib.h"

int main() {
    int i = 0;
    while (true) {
        write_7seg(i, 0x02);
        for (int i = 0; i < 5; i++) asm("nop");
        write_7seg(i, 0x00);
        i = (i + 1) & 0x3f;
    }
    return 0;
}
