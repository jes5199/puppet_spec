#!/bin/bash
# 
set -e
set -u

source local_setup.sh

# precondition:
# this cron test unit is not portable 
TMPUSER=cron-$$
TMPFILE=/tmp/cron-$$
TMPCRON=/var/spool/cron/${TMPUSER}

# Per discussion with Dan, using linux useradd and removing /var/spool/cron/
#$BIN/puppet resource user ${TMPUSER} ensure=present > /dev/null
#$BIN/puppet resource cron crontest user=${TMPUSER} command=/bin/true ensure=absent >/dev/null
useradd ${TMPUSER}
rm -f ${TMPCRON}
echo -e "# Puppet Name: crontest\n* * * * * /bin/true\n1 1 1 1 1 /bin/true" > ${TMPCRON}

# validation: puppet does not create cron entry and it matches expectation 
($BIN/puppet resource cron bogus user=${TMPUSER} command=/bin/true ensure=absent | grep removed) && ((`crontab -l -u ${TMPUSER} | grep -c '/bin/true'`==1))

status=$? 

# postcondition cleanup cron
#$BIN/puppet resource user ${TMPUSER} ensure=absent > /dev/null
#$BIN/puppet resource cron crontest user=${TMPUSER} command=/bin/true ensure=absent > /dev/null
userdel ${TMPUSER}
rm -f ${TMPCRON}

exit ${status}
