#!/usr/bin/env bash
#
#TODO:
# - [ ] Empty done/pending directories are not listed correctly
# - [ ] can not "do" duplicate tasks

shopt -s nullglob
shopt -s extglob

TODO_DIR=~/.todo.dir
PENDING_DIR=$TODO_DIR/pending
DONE_DIR=$TODO_DIR/done
LIST_CACHE=$XDG_CACHE_HOME/todo-dir/list

mkdir -p "$PENDING_DIR"
mkdir -p "$DONE_DIR"

list_tasks() {
    mkdir -p $(dirname $LIST_CACHE)
    I=1
    tee $LIST_CACHE | while read data
    do
        case "$data" in
            $DONE_DIR*)
                done="[X]"
                ;;
            *)
                done="[ ]"
                ;;
        esac
        echo $I "$done" $(basename "$data")
        I=$(expr $I + 1)
    done
}
        
task_by_index() {
    awk "NR == $1 { print(\$0) }" < $LIST_CACHE
}
        
filter_tasks() {
    number="+([0-9])"
    case "$@" in
        '')
            cat
            ;;
        $number)
            task="$(task_by_index $@)"
            if [ -z "$task" ]
            then
                awk '{}'
            else
                grep --fixed-strings "$task"
            fi
            ;;
        *)
            echo kaputter filter
    esac
}
        
parse_args() {
    while [ $# -gt 0 -a -z "$command" ]
    do
        key="$1"
        case "$key" in
            add|ls|lsa|do)
                shift
                command="cmd_$key"
                ;;
            a)
                shift
                command="cmd_add"
                ;;
        esac
    done

    all=$*
    
    while [ $# -gt 0 -a "$1" != "--" ]
    do
        if [ -z "$filter" ]
        then
            filter="$1"
        else
            filter="$filter $1"
        fi
        shift
    done

    shift

    rest=$*
}


store_pipe() {
    awk ' { a[NR] = $0 } END { for (x = 1; x <= NR; x++) print a[x] }'
}

cmd_add() {
    mkdir -p "$PENDING_DIR/$all"
}

cmd_ls() {
    ls -d $PENDING_DIR/* | filter_tasks "$filter" | list_tasks
}

cmd_lsa() {
    ls -d $PENDING_DIR/* $DONE_DIR/* | filter_tasks "$filter" | list_tasks
}

do_tasks() {
    while read data
    do
        task=$(basename "$data")
        mv "$data" "$DONE_DIR"
        echo "$DONE_DIR/$task"
    done 
}

cmd_do() {
    ls -d $PENDING_DIR/* | filter_tasks "$filter" | store_pipe | do_tasks | list_tasks
}       

parse_args $*
echo command $command
echo filter $filter
echo rest $rest

$command
        
