#!/bin/bash

# 使能 alias
shopt -s expand_aliases

# myecho 打印文件名, 函数名和行号
alias myechod='info [DEBUG] File:$0, Function:$FUNCNAME, Line:$LINENO \-\-\>'


# myecho 打印文件名, 函数名和行号
alias myecho='info [DEBUG] '


# functag 进入函数时使用
alias functag='func enter $FUNCNAME'



###############################################
###  Google Chromium os project scripts start #
###############################################

# Determine and set up variables needed for fancy color output (if supported).
V_BOLD_RED=
V_BOLD_GREEN=
V_BOLD_YELLOW=
V_REVERSE=
V_VIDOFF=

if [[ -t 1 ]] && tput colors >&/dev/null; then
    # order matters: we want VIDOFF last so that when we trace with `set -x`,
    # our terminal doesn't bleed colors as bash dumps the values of vars.
    V_BOLD_RED=$(tput bold; tput setaf 1)
    V_BOLD_GREEN=$(tput bold; tput setaf 2)
    V_BOLD_YELLOW=$(tput bold; tput setaf 3)
    V_BOLD_BLUE=$(tput bold; tput setaf 4)
    V_BOLD_MAGENTA=$(tput bold; tput setaf 5) # 品红色
    V_BOLD_CYAN=$(tput bold; tput setaf 6) # 青色
    V_BOLD_WHITE=$(tput bold; tput setaf 7)
    V_BOLD_GRAY=$(tput bold; tput setaf 8) # 灰色
    V_BOLD_PINK=$(tput bold; tput setaf 9) # 粉红
    V_REVERSE=$(tput rev)
    V_VIDOFF=$(tput sgr0)
fi

# Declare these asap so that code below can safely assume they exist.
_message() {
  local prefix=$1
  shift
  if [[ $# -eq 0 ]]; then
    echo -e "${prefix}${CROS_LOG_PREFIX:-""}:${V_VIDOFF}" >&2
    return
  fi
  (
    # Handle newlines in the message, prefixing each chunk correctly.
    # Do this in a subshell to avoid having to track IFS/set -f state.
    IFS="
"
    set +f
    set -- $*
    IFS=' '
    if [[ $# -eq 0 ]]; then
      # Empty line was requested.
      set -- ''
    fi
    for line in "$@"; do
      echo -e "${prefix}${CROS_LOG_PREFIX:-}: ${line}${V_VIDOFF}" >&2
    done
  )
}


# 以下函数用作实际场景
#
# info 作消息
info() {
  _message "${V_BOLD_GREEN}INFO    " "$*"
}

# func 作消息
func() {
  _message "${V_BOLD_GREEN}FUNC    " "$*"
}

# warn 作警告
warn() {
  _message "${V_BOLD_YELLOW}WARNING " "$*"
}

# warn 作警告
ckret() {
  _message "${V_BOLD_BLUE}CHECK_RET " "$*"
}

# warn 作警告
copy() {
  _message "${V_BOLD_PINK}COPY " "$*"
}

# debug 作调试
debug() {
  _message "${V_BOLD_CYAN}DEBUG " "$*"
}

# error 作错误
error() {
  _message "${V_BOLD_RED}ERROR   " "$*"
}

# Exit this script w/out a backtrace.
die_notrace() {
  set +e +u
  if [[ $# -eq 0 ]]; then
    set -- '(no error message given)'
  fi
  local line
  for line in "$@"; do
    error "${DIE_PREFIX}${line}"
  done
  exit 1
}

okboat() {
  echo -e "${V_BOLD_GREEN}"
  cat <<BOAT
    .  o ..
    o . o o.o
         ...oo_
           _[__\___
        __|_o_o_o_o\__
    OK  \' ' ' ' ' ' /
    ^^^^^^^^^^^^^^^^^^^^
BOAT
  echo -e "${V_VIDOFF}"
}

funcdone() {
  echo -e "${V_BOLD_GREEN}"
  cat <<BOAT
    .  o ..
    o . o o.o
         ...oo_
           _[__\___
        __|_o_o_o_o\__
    OK  \' ' ' ' ' ' /
    ^^^^^^^^^^^^^^^^^^^^
BOAT
  echo -e "${V_VIDOFF}"
  info $(caller 0) complete
}

failboat() {
  echo -e "${V_BOLD_RED}"
  cat <<BOAT
             '
        '    )
         ) (
        ( .')  __/\ 
          (.  /o/' \ 
           __/o/'   \ 
    FAIL  / /o/'    /
    ^^^^^^^^^^^^^^^^^^^^
BOAT
  echo -e "${V_VIDOFF}"
  die_notrace "$* failed"
}

###############################################
###  Google Chromium os project scripts send  #
###############################################

# checkret 检查返回值
checkret(){
    ckret ret = $1 $(caller 0)
    if [ $1 -ne 0 ];then
        exit -1
    fi  
}