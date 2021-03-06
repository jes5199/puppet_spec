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

# validation: puppet create cron entry and it matches expectation 
$BIN/puppet resource cron crontest user=${TMPUSER} command=/bin/true ensure=present | grep created && crontab -l -u ${TMPUSER} | grep "\* \* \* \* \* /bin/true"
status=$? 

# postcondition cleanup cron
#$BIN/puppet resource user ${TMPUSER} ensure=absent > /dev/null
#$BIN/puppet resource cron crontest user=${TMPUSER} command=/bin/true ensure=absent > /dev/null
userdel ${TMPUSER}
rm -f ${TMPCRON}

exit ${status}
