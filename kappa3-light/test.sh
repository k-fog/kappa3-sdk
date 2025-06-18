#!/bin/sh

assert() {
    if [ ! -d "testbench/$1" ]; then
        echo "Test directory for $1 does not exist"
        exit 1
    fi
    mkdir -p test_tmp/$1

    iverilog -c filelist.txt src/instruction_tester.v -I testbench/$1 -o test_tmp/$1/instruction_tester.vvp
    vvp test_tmp/$1/instruction_tester.vvp | grep -v 'VCD info' | grep -v 'src/instruction_tester.v' > test_tmp/$1/result.txt

    if ! diff test_tmp/$1/result.txt testbench/$1/expected.txt; then
        echo "Output mismatch for $1"
        exit 1
    fi
}

assert basic01_lui
assert basic02_auipc
assert basic03_jal
assert basic04_jalr
assert basic05_beq
assert basic06_beq
assert basic07_blt
assert basic08_blt
assert basic09_blt

echo "All tests passed !!!"