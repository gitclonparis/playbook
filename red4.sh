########### Creation LV #####################
vgs
pvs
lvcreate -L 250M -n lv_nagiosagent rootvg
mkfs -t ext3 /dev/rootvg/lv_nagiosagent
mkdir -p /exec/products/nagiosagent
vi /etc/fstab ==> /dev/rootvg/lv_nagiosagent /exec/products/nagiosagent ext3 defaults,nodev 1 2
mount /exec/products/nagiosagent

########### Supression LV ###############
vi /etc/fstab ==>#/dev/rootvg/lv_nagiosagent /exec/products/nagiosagent ext3 defaults,nodev 1 2
umount /exec/products/nagiosagent
lvchange -an /dev/rootvg/lv_nagiosagent
lvremove /dev/rootvg/lv_nagiosagent

########### Test telnet & copier et decompreser files ###############
telnet nagiospfssatpms.itn.ftgroup 5665
telnet nagiospfssatpmsbck.itn.ftgroup 5665
mkdir -p /images/nagios
cp PI-* /images/nagios/
cd /images/nagios
unzip PI-NAG-AGT-TLG01R04C00.zip
unzip PI-SMN-AGENT-TLG03R00C02.zip
ls -ltrh

########### declare path instalation ####################
PATH_NAGIOS="/exec/products/nagiosagent"
export PATH_NAGIOS
echo $PATH_NAGIOS

########### Instalation SysMon #########################
cd /images/nagios
rpm -ivh SysMon-3.0.02-g03r00c02.noarch.rpm
# Vérifications et configurations:
rpm -qa | grep -i sysmon
ps -ef | grep SysMon
ls -ltrh /usr/local/SysMon
/sbin/chkconfig --add SysMon
ls -ltrh /etc/init.d/SysMon
ls -ltrh /var/adm/system.log
ls -ltrh /etc/signatures/ | grep SMN

############### add group & user & droits ###############################
groupadd -g 2201 nagiosagent
useradd -m -d /exec/products/nagiosagent -s /bin/bash -u 2201 -g 2201 nagiosagent
chown -R nagiosagent:nagiosagent /exec/products/nagiosagent

############### install nagiosagent ########################
cd /images/nagios
rpm -ivh nagios-agent-G01R04C00-3.noarch.rpm
cat /var/opt/log/install/install_nagios-agent_<version>_<date>_<heure>.log
chmod 644 /var/log/messages

[LogMessages]
vi /etc/logrotate.d/syslog 
	#===> /bin/chmod 0644 /var/log/messages

[agent.cfg] 
vim /exec/products/nagiosagent/current/conf/agent.cfg 
vim ${PATH_NAGIOS}/current/conf/agent.cfg 
	nagios_satellite=nagiospfssatpms.itn.ftgroup:5665,nagiospfssatpmsbck.itn.ftgroup:5665

mv /exec/products/nagiosagent/current/conf/config_linux.xml /exec/products/nagiosagent/current/conf/config_linux.xml.disable

chmod -R 755 /exec/products/nagiosagent/
chown -R nagiosagent:nagiosagent /exec/products/nagiosagent/
