#!/bin/bash

# isFindDict $1 是否在 字典 $2 的 keys 中
isFindDict() {
    dict=$2

    for key in $(eval echo \${!${dict}[*]})
    do
        if [ "${key}" == "$1" ];then
            return 0
        fi
    done
    return 1
}

# print_pos_args 打印位置参数
print_pos_args(){

    while [ $# -gt 0 ]
    do
        debug $1 $2
        shift 2
    done
    return 0
}

# print_all_args 打印所有需要的参数
print_all_args(){
    dict=$1

    for key in $(eval echo \${!${dict}[*]})
    do
        eval eval debug \${${dict}[\$key]} = \\\${\${${dict}[\$key]}}

    done
    return 0
}

# not_exist_error 不存在则报错
# $2 -> f -> file
# $2 -> d -> directory
# $2 -> L -> link
not_exist_error(){
    fpath=$1
    ftype=$2

    case ${ftype} in
        "file")
            [ ! -f ${fpath} ] && failboat "Error!! ${ftype} ${fpath} is not exist "
            ;;
        "directory")
            [ ! -d ${fpath} ] && failboat "Error!! ${ftype} ${fpath} is not exist "
            ;;
        "link")
            [ ! -L ${fpath} ] && failboat "Error!! ${ftype} ${fpath} is not exist "
            ;;
        *)
            failboat "not_exist_error type -> ${ftype} is not right !!"
            ;;
    esac

    return 0
}

# if_exist_rm 如果存在则删除
if_exist_rm(){
    fpath=$1
    ftype=$2

    case ${ftype} in
        "file")
            [ -f ${fpath} ] && sudo rm -rf $1 && return 0
            ;;
        "directory")
            [ -d ${fpath} ] && sudo rm -rf $1 && return 0
            ;;
        "link")
            [ -L ${fpath} ] && sudo rm -rf $1 && return 0
            ;;
        *)
            failboat "not_exist_error type -> ${ftype} is not right !!"
            ;;
    esac

    warn "if_exist_rm ${ftype} ${fpath} is not rm, mayby the type is not right or ${fpath} not exist"
    return 0
}

# if_zero_error 
if_zero_error(){
    if [ -z $2 ];then
        failboat "$1 is null"
    fi
}

# if_zero_warning 
if_zero_warn(){
    if [ -z $2 ];then
        warn "$1 is null"
    fi
}

# assert_not_root_user 必须以非 root 用户运行时使用
assert_not_root_user() {
  if [[ ${UID:-$(id -u)} == 0 ]]; then 
    failboat "This script must be run as a non-root user."
  fi
}

# assert_root_user 必须以 root 用户运行时使用
assert_root_user() {
  if [[ ${UID:-$(id -u)} != 0 ]]; then
    failboat "This script must be run using sudo from a non-root user."
  fi
}

# process_args 对参数进行处理
process_args(){

    local largs_list=$1
    shift
    # set_args_list 设置支持的参数列表
    set_args_list

    # print_pos_args 输出传递的参数列表到控制台
    print_pos_args  $*

    # args_parse 解析位置参数
    args_parse ${largs_list} $*

    # print_all_args 打印所有参数
    print_all_args ${largs_list}

}