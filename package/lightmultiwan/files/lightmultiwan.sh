:<<COMMENT
Copyright (c) 2010，XRouter, GROUP
All rights reserved.

Name        : lightmultiwan.sh
Description : core script for lightmultiwan

Version     : 1.0
Author      : Xu Guanglin
Created on  : Dec 31, 2010
COMMENT

#!/bin/sh

. /etc/functions.sh

routeTableId=100

logTo() {
    logger ${debug:+-s} -p 5 -t Light-Multi-Wan "$1"
}

start() {
	config_load lightmultiwan
	defineBalancerRouteTableName
	fillBalancerRouteTable
	config_foreach defineCustomRouteTableName interface
	config_foreach fillCustumRouteTable interface
	config_foreach addCustomRouteRule interface
	config_foreach buildRule mwanfw
	setDefaultRoute
	config_foreach buildRuleForDns interface
}

recover() {
	config_load lightmultiwan
	fillBalancerRouteTable
	config_foreach fillCustumRouteTable interface
	setDefaultRoute
}

defineBalancerRouteTableName() {
	local checkRouterTables=$(grep balancer /etc/iproute2/rt_tables)
	if [ -z "$checkRouterTables" ]; then
		echo "$routeTableId balancer" >> /etc/iproute2/rt_tables
	fi
}

fillBalancerRouteTable() {
	ip route flush table balancer
	ip route show table main | grep -Ev ^default \
		| while read ROUTE ; do
			ip route add table balancer $ROUTE
		done

	local command="ip route add table balancer default "
	buildCommand() {
		local gateway=`getInterfaceGateway $1`
		local weight=`getInterfaceWeight $1`
		if [ $weight != disable ]; then
			command=${command}" nexthop via ${gateway} weight $weight "
		fi
		echo $command
	}	
	config_foreach buildCommand interface

	eval $command
}

#Param $1:Table name
defineCustomRouteTableName() {
	routeTableId=$((${routeTableId}+1))

	local checkRouterTables=$(grep $1 /etc/iproute2/rt_tables)
	if [ -z "$checkRouterTables" ]; then
		echo "$routeTableId $1" >> /etc/iproute2/rt_tables
	fi
}

#Param $1:Table name
fillCustumRouteTable() {
	ip route flush table $1
	ip route show table main | grep -Ev ^default \
		| while read ROUTE ; do
			ip route add table $1 $ROUTE
		done
	local gateway=`getInterfaceGateway $1`
	ip route add default via $gateway table $1
}

#Param $1:wanname
addCustomRouteRule() {
	local ip=`getInterfaceIp $1`
	ip rule add from $ip table $1
}

setDefaultRoute() {
	local defaultRouteInterface
	config_get defaultRouteInterface config default_route
	if [ $defaultRouteInterface = balancer ]; then
		local command="ip route change table main default "
		buildCommand() {
			local gateway=`getInterfaceGateway $1`
			local weight=`getInterfaceWeight $1`
			if [ $weight != disable ]; then
				command=${command}" nexthop via ${gateway} weight $weight "
			fi
			echo $command
		}	
		config_foreach buildCommand interface
		eval $command
	else
		local gateway=`getInterfaceGateway ${defaultRouteInterface}`
		ip route change default via $gateway
	fi
	logTo "set default route to $defaultRouteInterface"
}

#Param $1:sectionname
buildRule() {
	local src,dst,wanrule

	config_get src $1 src
	if [ -z $src ]; then
		src=all
	fi
	config_get dst $1 dst
	if [ -z $dst ]; then
		dst=all
	fi
	config_get wanrule $1 wanrule

	ip rule add from $src to $dst table $wanrule
}

#Param $1:wanname
buildRuleForDns() {
	local dns=`getInterfaceDns $1`
	local wanname=$1

	addDnsRule() {
		for dnsaddr in $*; do
			ip rule add to $dnsaddr table $wanname
			echo -e "ip rule add to $dnsaddr table $wanname" >> /tmp/dns.log
		done
	}
	addDnsRule $dns	

	logTo "buildi rules for dns $dns"
}

#Param $1:wanname
getInterfaceGateway() {
	local gateway=`uci_get_state network $1 gateway`
	echo $gateway
}

#Param $1:wanname
getInterfaceWeight() {
	local weight=`uci_get_state lightmultiwan $1 weight`
	echo $weight
}

#Param $1:wanname
getInterfaceIp() {
	local ip=`uci_get_state network $1 ipaddr`
	echo $ip
}

#Param $1:wanname
getInterfaceDns() {
	local dns=`uci_get_state network $1 resolv_dns`
	echo $dns
}

case $1 in
    start) start;;
    recover) recover;;
    stop) ;;
esac
