#!/bin/bash

source $(grab github.com/shellib/cli)

ALWAYS_TRUE="always_true"
DEFAULT_MAX_WAIT_TIME=7200
DEFAULT_RETRY_DELAY=1
DEFAUL_BACKOFF_MULTIPLIER=1
DEFAULT_MAX_DELAY=3600


usage::wait_for() {
echo "Wait until the specified function return a non empty, non error response.
Options and Flags:

 --function                        The function that evaluates if we should wait for more (defaults: to always return true).
 --max-wait-time                   The maximum amount of time in seconds to wait.
 --retry-delay                     The delay between retries (if exponential back off is not used).
 --backoff-multiplier              The backoff multiplier to use
"
}
function wait_for() {
    if [ -n "$(hasflag --help $*)" ]; then
        usage::wait_for
	exit 0
    fi
    local func=$(or $(readopt --function $*) $ALWAYS_TRUE)
    local max_wait_time=$(or $(readopt --max-wait-time $*) $DEFAULT_MAX_WAIT_TIME)
    local retry_delay=$(or $(readopt --retry-delay $*) $DEFAULT_RETRY_DELAY)
    local backoff_multiplier=$(or $(readopt --backoff-multiplier $*) $DEFAUL_BACKOFF_MULTIPLIER)
    local max_delay=$(or $(readopt --max-delay $*) $DEFAULT_MAX_DELAY)

    local timeout=$retry_delay
    local result=$(eval "$func")
    while [ -z "$result" ] || [ "$result" == "false" ]
    do
        sleep $timeout
        timeout=$((timeout * backoff_multiplier))
        result=$(eval "$func")
    done
}

function always_true() {
    echo "true"
}
