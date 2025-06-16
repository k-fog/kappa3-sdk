#!/bin/sh

assert() {
    if [ ! -d "testbench/$1" ]; then
        echo "Test directory for $1 does not exist"
        exit 1
    fi
    mkdir -p test_tmp/$1

    iverilog -c filelist.txt src/instruction_tester.v -I testbench/$1 -o test_tmp/$1/instruction_tester.vvp
    vvp test_tmp/$1/instruction_tester.vvp > test_tmp/$1/result.txt

    if ! diff test_tmp/$1/result.txt testbench/$1/expected.txt; then
        echo "Output mismatch for $1"
        exit 1
    fi
}

assert basic01_lui

echo "All tests passed !!!"