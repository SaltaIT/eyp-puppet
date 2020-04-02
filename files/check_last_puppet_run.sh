#!/bin/bash
# puppet managed file

MAXDIFF=7200
WARNDIFF=3600

while getopts 'c:w:' OPT; do
  case $OPT in
    c)  MAXDIFF=$OPTARG;;
    w)  WARNDIFF=$OPTARG;;
  esac
done

shift $(($OPTIND - 1))

DIFF_LAST_RUN=$(/usr/local/bin/puppetlr)

if [ "$?" -ne 0 ];
then
  echo "CRITICAL - unable to fect last run data"
  exit 2
fi

# PERFDATA="$PERFDATA difflastrun=$DIFF_LAST_RUN;"

PUPPETBIN=$(which puppet 2>/dev/null)

if [ -z "${PUPPETBIN}" ];
then
  echo "CRITICAL - puppet not found"
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
	echo "CRITICAL - last_run_summary.yaml does not exists"
	exit 2
fi

if [ ! -e "${LAST_RUN_FILE}" ];
then
	echo "CRITICAL - last_run_report.yaml does not exists"
	exit 2
fi

PERFDATA="$PERFDATA $(grep resources: ${LAST_RUN_FILE} -A7 | grep -v resources: | paste '-sd;')"

if [ $DIFF_LAST_RUN -ge $MAXDIFF ];
then
	echo "CRITICAL - last run: $DIFF_LAST_RUN seconds ago |$PERFDATA"
	exit 2
fi

if [ $DIFF_LAST_RUN -ge $WARNDIFF ];
then
  echo "WARNING - last run: $DIFF_LAST_RUN seconds ago |$PERFDATA"
  exit 1
fi

#
# outputs
#
# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Could not find declared class sssd::monit at /etc/puppet/manifests/site.pp:919 on node centos7.vm"
#       message: "Using cached catalog"
#       message: "Finished catalog run in 7.96 seconds"
#

grep "Using cached catalog" ${LAST_RUN_FILE} >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "CRITICAL - server using cached catalog |$PERFDATA"
  exit 2
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type pam::securetty at /etc/puppet/manifests/site.pp:356 on node ar-tst2-ebsdb01.lifecapnet.com"
#       message: "Not using cache on failed catalog"
#       message: "Could not retrieve catalog; skipping run"
#
grep "Could not retrieve catalog from remote server" ${LAST_RUN_FILE} >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "CRITICAL - could not retrieve catalog from remote server |$PERFDATA"
  exit 2
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Caching catalog for ar-mgmt-svn01.lifecapnet.com"
#       message: "Finished catalog run in 10.89 seconds"
grep "Finished catalog run" ${LAST_RUN_FILE} >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "OK - last run: $DIFF_LAST_RUN seconds ago |$PERFDATA"
  exit 0
else
  echo "CRITICAL - puppet agent does not report to have finished to apply the catalog |$PERFDATA"
  exit 3
fi
