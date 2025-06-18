#!/bin/sh

FAILED=false

assert() {
    if [ ! -d "testbench/$1" ]; then
        echo "Test directory for $1 does not exist"
        exit 1
    fi
    mkdir -p test_tmp/$1

    iverilog -c filelist.txt src/instruction_tester.v -I testbench/$1 -o test_tmp/$1/instruction_tester.vvp
    vvp test_tmp/$1/instruction_tester.vvp | grep -v 'VCD info' | grep -v 'src/instruction_tester.v' > test_tmp/$1/result.txt

    if ! diff test_tmp/$1/result.txt testbench/$1/expected.txt; then
        echo "$1...FAILED"
        FAILED=true
        return
    fi
    echo "$1...OK"
}

for test in `ls ./testbench`; do
    assert $test
done

if "$FAILED"; then
    echo -e "\nSome test failed\n"
else
    echo -e "\nAll tests passed !!!\n"
fi
