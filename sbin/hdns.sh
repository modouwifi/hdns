#!/bin/sh

config="/system/conf/dnsmasq.conf";
hdnsconf="conf-dir=/data/apps/hdns/conf";

initconfig()
{
    # generate the modouwifi.net DNS record
    /bin/sed -ie "/address=\/modouwifi.net/d" $config;
    toip=`nvram_get 2860 lan_ipaddr`;
    strategy="address=/modouwifi.net/$toip";

    # get hardware version
    hwver=`/bin/sn_get hw`
    swver=`/bin/cat /etc/version | /usr/bin/head -n 2 | /usr/bin/tail -n 1`
    g2mac=`/sbin/ifconfig ra0 | /usr/bin/head -n 1 | /usr/bin/awk '{ print $5}'`
    g5mac=`/sbin/ifconfig rai0 | /usr/bin/head -n 1 | /usr/bin/awk '{ print $5}'`

    txtRecord="txt-record=all,hwver#$hwver,swver#$swver,2gmac#$g2mac,5gmac#$g5mac"

    /system/sbin/writesys.sh;
    echo $strategy > $config;
    echo $txtRecord >> $config;
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
