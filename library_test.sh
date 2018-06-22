#!/bin/bash

source ./library.sh 

MAX_ITERATIONS=3

prepare() {
    TMP_DIR=`mktemp -d -p /tmp/`
    trap 'cleanup' EXIT
}

cleanup() {
    rm -rf $TMP_DIR
}

# Test Cases
should_handle_fixed_delay() {
    before=`date +%s`
    wait_for --function fail_nth_times
    after=`date +%s`
    diff=$((after-before))
    if [ $diff -lt 3 ] || [ $diff -gt 4 ]; then
        echo "FAIL: Should take almost 3 seconds, but took: $diff!"
        exit 1
    fi
}

should_handle_exponential_backoff() {
    # With exponential backoff of 2: 1 + 2 + 4 + 8 = 15.
    before=`date +%s`
    wait_for --function fail_nth_times --backoff-multiplier 2 --retry-delay 1
    after=`date +%s`
    diff=$((after-before))
    if [ $diff -lt 15 ] || [ $diff -gt 16 ]; then
        echo "FAIL: Should take almost 15 seconds, but took: $diff!"
        exit 1
    fi
}

# Utilities
fail_nth_times() {
    if [ ! -f "$TMP_DIR/iterations" ]; then
        echo 0 > $TMP_DIR/iterations
    else
        value=`cat $TMP_DIR/iterations`
        if [ $value -eq $MAX_ITERATIONS ];then
            echo "true"
        else
            value=$((value+1))
            echo $value > $TMP_DIR/iterations
        fi
    fi
}


prepare
should_handle_fixed_delay
should_handle_exponential_backoff
cleanup
