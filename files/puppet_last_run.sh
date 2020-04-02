#!/bin/bash
# puppet managed file
# snmpd compatible check

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

PUPPETBIN=$(which puppet 2>/dev/null)

if [ -z "${PUPPETBIN}" ];
then
  # puppet not found
  exit 2
fi

PUPPET_VER="$(${PUPPETBIN} --version 2>/dev/null)"

if [[ $PUPPET_VER = 3* ]];
then
  LAST_RUN_FILE='/var/lib/puppet/state/last_run_summary.yaml'
elif [[ $PUPPET_VER = 5* ]];
then
  LAST_RUN_FILE='/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml'
else
  exit 2
fi

if [ ! -e "${LAST_RUN_FILE}" ];
then
	# last_run_summary.yaml does not exists
	exit 2
fi

if [ ! -e "${LAST_RUN_FILE}" ];
then
	# last_run_report.yaml does not exists
	exit 2
fi

LAST_RUN=$(grep last_run ${LAST_RUN_FILE} | awk '{ print $NF }')

if [ -z "$LAST_RUN" ];
then
	# error getting data from last_run_summary.yaml
	exit 2
fi

NOW=$(date +%s)

DIFF_LAST_RUN=$(($NOW-$LAST_RUN))

echo "${DIFF_LAST_RUN}"
exit 0
