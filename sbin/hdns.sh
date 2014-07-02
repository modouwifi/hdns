#!/bin/sh

config="/system/conf/dnsmasq.conf";
hdnsconf="conf-dir=/data/apps/hdns/conf";

initconfig()
{
    toip=`nvram_get 2860 lan_ipaddr`;
    strategy="address=/modouwifi.net/$toip";
    /system/sbin/writesys.sh;
    echo $strategy > $config;
    echo $hdnsconf >> $config;
    /system/sbin/writesys.sh close;
}

dnsstop()
{
    pid=`/bin/ps|grep dnsmasq|grep -v grep|awk '{print $1}'`;
    if [ "$pid" != "" ]; then
        /bin/kill $pid;
    else
        /usr/bin/killall dnsmasq;
    fi
}

dnsstart()
{
    initconfig;
    dnsstop;
    /bin/dnsmasq -C "$config" &
}

# main
if [ $# -lt 1 ]; then
    echo "ERROR: action missing";
    echo "syntax: dns.sh <start|stop|restart>";
    echo "example: dns.sh start or dns.sh stop"
fi

if [ "$1" == "start" ]; then
    dnsstart;
fi

if [ "$1" == "stop" ]; then
    dnsstop;
    exit $?;
fi

if [ "$1" == "restart" ]; then
    dnsstart;
fi
