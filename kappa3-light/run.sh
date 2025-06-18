#!/bin/sh -x

iverilog -c filelist.txt src/program_tester.v -o program_tester.vvp
vvp program_tester.vvp