#!/bin/bash
#
# Originally taken from "Controlling Test Parallelism with prove":
# http://www.modernperlbooks.com/mt/2011/12/controlling-test-parallelism-with-prove.html

proveall ()
{
    if [ -d blib ]; then
        prove -j9 --state=slow,save -br t;
    else
        prove -j9 --state=slow,save -lr t;
    fi
}