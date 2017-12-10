#!/bin/bash -v
set -e
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
rm -rf /var/lib/apt/lists/*
sed -e '/^deb.*security/ s/^/#/g' -i /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
apt-get update -y -m -qq
apt-get -y install conntrack iptables-persistent nfs-common > /tmp/nat.log
[[ -s $(modinfo -n ip_conntrack) ]] && modprobe ip_conntrack && echo ip_conntrack | tee -a /etc/modules
/sbin/sysctl -w net.ipv4.ip_forward=1
/sbin/sysctl -w net.ipv4.conf.eth0.send_redirects=0
/sbin/sysctl -w net.netfilter.nf_conntrack_max=131072
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth0.send_redirects=0" >> /etc/sysctl.conf
echo "net.netfilter.nf_conntrack_max=131072" >> /etc/sysctl.conf
/sbin/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
/sbin/iptables -A FORWARD -m conntrack --ctstate INVALID -j DROP
/sbin/iptables -A INPUT -p tcp --syn -m limit --limit 5/s -i eth0 -j ACCEPT
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -t nat -A POSTROUTING -o eth0 -s ${cidr} -j MASQUERADE
sleep 1
wget -P /usr/local/bin https://s3-ap-southeast-2.amazonaws.com/encompass-public/ha-nat-terraform.sh
[[ ! -x "/usr/local/bin/ha-nat-terraform.sh" ]] && chmod +x /usr/local/bin/ha-nat-terraform.sh
/bin/bash /usr/local/bin/ha-nat-terraform.sh
cat > /etc/profile.d/user.sh <<END
HISTSIZE=1000
HISTFILESIZE=40000
HISTTIMEFORMAT="[%F %T %Z] "
export HISTSIZE HISTFILESIZE HISTTIMEFORMAT
END
sed -e '/^#deb.*security/ s/^#//g' -i /etc/apt/sources.list
exit 0