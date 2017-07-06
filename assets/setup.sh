#!/bin/bash

# avoid dpkg frontend dialog / frontend warnings
export DEBIAN_FRONTEND=noninteractive

cat /assets/oracle-xe_10.2.0.1-1.1_i386.deba* > /assets/oracle-xe_10.2.0.1-1.1_i386.deb

# Install OpenSSH
#apt-get update &&
#apt-get install -y openssh-server &&
dpkg --add-architecture i386 && \
  apt-get update && apt-get install -y \
       bc:i386 \
       libaio1:i386 \
       libc6-i386 \
       net-tools \
       openssh-server && \
    apt-get clean &&\
mkdir /var/run/sshd &&
echo 'root:admin' | chpasswd &&
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config &&
sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd &&
echo 'export VISIBLE=now' >> /etc/profile &&

# Prepare to install Oracle
#apt-get install -y libaio1 net-tools bc &&
ln -s /usr/bin/awk /bin/awk &&
mkdir /var/lock/subsys &&
mv /assets/chkconfig /sbin/chkconfig &&
chmod 755 /sbin/chkconfig &&

# Install Oracle
dpkg --install /assets/oracle-xe_10.2.0.1-1.1_i386.deb &&

# Backup listener.ora as template
cp /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/listener.ora /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/listener.ora.tmpl &&
cp /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/tnsnames.ora /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/tnsnames.ora.tmpl &&

mv /assets/init.ora /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/dbs &&
mv /assets/initXETemp.ora /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/dbs &&

printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure &&

echo 'export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server' >> /etc/bash.bashrc &&
echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc &&
echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc &&

# Install startup script for container
mv /assets/startup.sh /usr/sbin/startup.sh &&
chmod +x /usr/sbin/startup.sh &&

# Remove installation files
rm -r /assets/


exit $?
