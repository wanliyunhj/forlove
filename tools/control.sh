#!/bin/sh
basedir=$(cd `dirname $0`;pwd)
supervise_status_path=./status/forlove
process=forlove
supervise_exe=./bin/supervise.forlove
port_list=(8080)

cd $basedir

get_process_name(){
    local pid=$1
    local name=$(ps -o cmd --no-heading -p $pid |awk -F'/' '{print $NF}')
    echo $name
}

get_supervise_pid(){
    local mod=$1
    local supervise_id=$(/sbin/fuser $basedir/$supervise_status_path/lock 2>/dev/null |awk '{print $1}')
    if [ "$supervise_id"x == ""x ];then
        if [ "$mod"x == "detail"x ];then
            echo "$basedir/${supervise_status_path}/lock is not used,so this supervise is not runing"
        fi
        return 1
    fi
    echo $supervise_id
}

get_pid() {
    local mod=$1
    local pid=$(od -An -j16 -N2 -tu2 $basedir/$supervise_status_path/status|awk '{print $1}')
    if [ "$pid"x == ""x ];then
        if [ "$mod"x == "detail"x ];then
            echo "$process is not runing"
        fi
        return 1
    fi
    local name=$(get_process_name $pid)
    if [ "$name"x != "$process"x ];then
        if [ "$mod"x == "detail"x ];then
            echo "supervise sub process pid=$pid name=$name ,is not $process"
        fi
        return 1
    fi
    echo $pid
}

check_port() {
    local right_port=""
    for port in ${port_list[@]};do
        netstat -nlp|grep $port 1>/dev/null 2>/dev/null
        if [ $? -eq 0 ];then
            right_port=${right_port}" "$port
        fi
    done
    echo $right_port
}

status(){
    local spid=$(get_supervise_pid detail)
    local pid=$(get_pid detail)
    port_msg=$(check_port)
    echo -e "supervise_pid:${spid}\tpid:${pid}\tprocess:${process}\tport:$port_msg"
}

start(){
    echo "Begin start..."
    cd $basedir
    get_supervise_pid
    if [ $? -eq 0 ];then
        echo "supervise is already runing..."
        echo "End start..."
        return 1
    fi
    get_pid
    if [ $? -eq 0 ] ; then
        echo "service $process is already running..."
    else
        export LD_LIBRARY_PATH=./thirdlibs/lib
        mkdir -p $basedir/$supervise_status_path
        setsid $supervise_exe -u $supervise_status_path ./bin/$process </dev/null &>/dev/null &
    fi
    echo "End start..."
}

stop_supervise(){
    echo "Begin stop_supervise..."
    while true;do
        get_supervise_pid detail
        if [ $? -ne 0 ];then
            echo "$supervise_exe has already stoped..."
            echo "End stop_supervise..."
            return 0
        else
            local spid=$(get_supervise_pid)
            kill -9 $spid
            echo "killing $supervise_exe"
        fi
        sleep 1
    done
    echo "End stop_supervise..."
}

stop_process(){
    echo "Begin stop_process..."
    while true;do
        get_pid detail
        if [ $? -ne 0 ];then
            echo "$process has already stoped..."
            echo "End stop_process..."
            rm $basedir/$supervise_status_path/status
            return 0
        else
            local pid=$(get_pid)
            kill -9 $pid
            echo "killing $process"
        fi
        sleep 1
    done
    rm $basedir/$supervise_status_path/status
    echo "End stop_process..."
}

stop()
{
    echo "Begin stop..."
    stop_supervise
    stop_process
    echo "End stop..."
}

restart(){
    stop
    start
}

case "$1" in
    'start')
        start
        ;;
    'stop')
        stop
        ;;
    'status')
        status
        ;;
    'restart')
        restart
        ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
        ;;
    esac

