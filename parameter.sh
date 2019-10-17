#!/bin/bash

# args_parse parse the args from positional parameters
args_parse() {

    dict=$1
    shift 1
    # TODO 需要检查 dict 变量是否被定义

    while [ $# -gt 0 ]
    do
        if $(eval isFindDict "$1" "${dict}");then
            eval value=\${${dict}[\$1]}
            eval ${value}=$2
            shift 2
            continue
        fi
        failboat "not exit $1"
    done
    
    return 0
}