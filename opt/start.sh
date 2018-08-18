#!/bin/sh
## Preparing all the variables like IP, Hostname, etc, all of them from the container
sleep 5

if [[ ! -z "$INSTALL" ]]; then

##############  Z I M B R A   I N S T A L L A T I O N  ################
echo "Installing a brand new instance"

sed  s/$(hostname)/"$HOST.$DOMAIN $(hostname)"/g /etc/hosts >/etc/hosts.new ; cp /etc/hosts.new /etc/hosts ; rm -f /etc/hosts.new
echo "nameserver 127.0.0.1" >/etc/resolv.conf
echo $HOST.$DOMAIN >/etc/hostname
hostname $HOST.$DOMAIN

CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
CONTAINERNET="$(ipcalc -n "${CONTAINERIP}/24"|awk -F = '{print $2}')"

RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)


RANDOMPASS=$(date +%s|sha256sum|base64|head -c 15)

# Installing the DNS Server ##
rm -f /etc/dnsmasq.conf
cat <<EOF >>/etc/dnsmasq.conf
server=8.8.8.8
listen-address=127.0.0.1
domain=$DOMAIN
mx-host=$DOMAIN,$HOST.$DOMAIN,0
address=/$HOST.$DOMAIN/$CONTAINERIP
user=root
EOF

sudo service dnsmasq restart
sudo service crond start
sudo service rsyslog start

##Creating the Zimbra Collaboration Config File ##
touch /opt/zimbra-install/installZimbraScript
cat <<EOF >/opt/zimbra-install/installZimbraScript
AVDOMAIN="$DOMAIN"
AVUSER="admin@$DOMAIN"
CREATEADMIN="admin@$DOMAIN"
CREATEADMINPASS="$PASSWORD"
CREATEDOMAIN="$DOMAIN"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOST.$DOMAIN"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPAMAVISPASS="$PASSWORD"
LDAPPOSTPASS="$PASSWORD"
LDAPROOTPASS="$PASSWORD"
LDAPADMINPASS="$PASSWORD"
LDAPREPPASS="$PASSWORD"
LDAPBESSEARCHSET="set"
LDAPDEFAULTSLOADED="1"
LDAPHOST="$HOST.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="972"
MAILPROXY="TRUE"
MODE="http"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="http"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN"
SMTPHOST="$HOST.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOST.$DOMAIN"
STARTSERVERS="yes"
STRICTSERVERNAMEENABLED="TRUE"
SYSTEMMEMORY="15.6"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="no"
USEEPHEMERALSTORE="no"
USESPELL="no"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$PASSWORD"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD"
ldap_url="ldap://$HOST.$DOMAIN:389"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/jre/lib/security/cacerts"
mailboxd_truststore_password="$RANDOMPASS"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraFeatureBriefcasesEnabled="FALSE"
zimbraFeatureTasksEnabled="FALSE"
zimbraIPMode="ipv4"
zimbraMailProxy="TRUE"
zimbraMtaMyNetworks="127.0.0.0/8 $CONTAINERIP/32 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="$TIMEZONE"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckInterval="1d"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN"
zimbraVersionCheckSendNotifications="TRUE"
zimbraWebProxy="TRUE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbra_server_hostname="$HOST.$DOMAIN"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-memcached zimbra-proxy"
EOF

##Install the Zimbra Collaboration ##

rpm -qa|grep zimbra | awk '{print "rpm -e "$1" --nodeps --justdb"}'|sh

wget https://files.zimbra.com/downloads/8.8.9_GA/zcs-8.8.9_GA_3019.RHEL6_64.20180809160254.tgz -O /opt/zimbra-install

cd /opt/zimbra-install && tar xfz zcs-* && cd zcs-* && ./install.sh -s < /opt/zimbra-install/installZimbra-keystrokes

/opt/zimbra/libexec/zmsetup.pl -c /opt/zimbra-install/installZimbraScript

echo "DOMAIN=$DOMAIN" >>/opt/zimbra/.bash_profile
echo "HOST=$HOST" >>/opt/zimbra/.bash_profile
echo "export DOMAIN" >>/opt/zimbra/.bash_profile
echo "export HOST" >>/opt/zimbra/.bash_profile
chown 498:499 /opt/zimbra/.bash_profile

rm -fR /opt/zimbra-install

else

CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo "Reusing an existing instance"

# Installing the DNS Server ##
rm -f /etc/dnsmasq.conf
cat <<EOF >>/etc/dnsmasq.conf
server=8.8.8.8
listen-address=127.0.0.1
domain=$DOMAIN
mx-host=$DOMAIN,$HOST.$DOMAIN,0
address=/$HOST.$DOMAIN/$CONTAINERIP
user=root
EOF

sed  s/$(hostname)/"$HOST.$DOMAIN $(hostname)"/g /etc/hosts >/etc/hosts.new ; cp /etc/hosts.new /etc/hosts ; rm -f /etc/hosts.new
echo "nameserver 127.0.0.1" >/etc/resolv.conf
echo $HOST.$DOMAIN >/etc/hostname
hostname $HOST.$DOMAIN

cat <<EOF >>/etc/rsyslog.conf
local0.*                -/var/log/zimbra.log
local1.*                -/var/log/zimbra-stats.log
auth.*                  -/var/log/zimbra.log
mail.*                -/var/log/zimbra.log
EOF

service dnsmasq start
service crond start
service rsyslog start

chown zimbra:zimbra  /var/log/zimbra-stats.log
su - zimbra -c 'cd conf/crontabs && cat crontab crontab.ldap crontab.logger crontab.mta crontab.store >/tmp/cron && crontab < /tmp/cron && rm -f /tmp/cron'
/opt/zimbra/libexec/zmfixperms
sleep 5
su - zimbra -c 'zmcontrol start'
rm -fR /opt/zimbra-install
sleep 30
echo "Zimbra is ready to use!!!"
fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
