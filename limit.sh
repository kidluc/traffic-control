DEV="$1"
IP="$2"
tc qdisc del dev $DEV root
tc qdisc add dev $DEV root handle 1:0 htb default 3
tc class add dev $DEV parent 1:0 classid 1:1 htb rate 1000mbit ceil 1000mbit
tc class add dev $DEV parent 1:1 classid 1:2 htb rate 1000mbit ceil 1000mbit
tc class add dev $DEV parent 1:1 classid 1:3 htb rate 1000mbit ceil 1000mbit

tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip dst $IP flowid 1:2
tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip src $IP flowid 1:2
