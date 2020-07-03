#!/bin/bash

##
##----------------------------------------------------------------------------------------------
## File Name    : oradebug.sh
##
## Description  : Takes hanganalyze, ashdumpseconds, systemstate dumps for post mortem analysis.
##
## Call Syntax  : bash$ ./oradebug.sh help
##
## References   : --> How to Collect Diagnostics for Database Hanging Issues (Doc ID 452358.1)
##                --> Reading and Understanding Systemstate Dumps (Doc ID 423153.1)
##                --> https://blog.dbi-services.com/oracle-is-hanging-dont-forget-hanganalyze-and-systemstate/
##                --> https://tanelpoder.com/2012/05/08/oradebug-hanganalyze-with-a-prelim-connection-and-error-can-not-perform-hang-analysis-dump-without-a-process-state-object-and-a-session-state-object/
##                --> https://grepora.com/2017/01/04/systemstate-dump/
##----------------------------------------------------------------------------------------------
##

#############################
function help() {

echo "
USAGE:

1) For standalone instance:

   $ ./oradebug.sh sa 

2) For RAC:

   $ ./oradebug.sh rac

3) For help:

   $ ./oradebug.sh help

Note: ORACLE_SID and ORACLE_HOME environment variables must be defined before running this script.
"
return 0
}

#############################
function sa() {

echo "*************** `date` ***************"
echo ""
if [[ "${ORACLE_SID}" = "" || "${ORACLE_HOME}" = "" ]]
then
   echo "ERROR: Please set ORACLE_SID / ORACLE_HOME environment variables before running this script."
   return 1
fi
echo "ORACLE_SID  = ${ORACLE_SID}"
echo "ORACLE_HOME = ${ORACLE_HOME}"
echo ""
sqlplus -s -prelim / as sysdba << EOF
oradebug setorapname diag
!echo ""
!echo "INFO: Taking hanganalyze dump ..."
oradebug hanganalyze 3
!echo ""
!echo "INFO: Taking ashdumpseconds dump ..."
oradebug dump ashdumpseconds 30
!echo ""
!echo "INFO: Taking systemstate dump ..."
oradebug dump systemstate 266
!echo ""
oradebug tracefile_name
exit;
EOF
if [[ $? = 0 ]]
then
   return 0
else
   return 1
fi
}

#############################
function rac() {

echo "*************** `date` ***************"
echo ""
if [[ "${ORACLE_SID}" = "" || "${ORACLE_HOME}" = "" ]]
then
   echo "ERROR: Please set ORACLE_SID / ORACLE_HOME environment variables before running this script."
   return 1
fi
echo "ORACLE_SID  = ${ORACLE_SID}"
echo "ORACLE_HOME = ${ORACLE_HOME}"
echo ""
sqlplus -s -prelim / as sysdba << EOF
oradebug setorapname diag
!echo ""
!echo "INFO: Taking hanganalyze dump ..."
oradebug -g all hanganalyze 3
!echo ""
!echo "INFO: Taking ashdumpseconds dump ..."
oradebug -g all dump ashdumpseconds 30
!echo ""
!echo "INFO: Taking systemstate dump ..."
oradebug -g all dump systemstate 266
!echo ""
oradebug tracefile_name
exit;
EOF
if [[ $? = 0 ]]
then
   return 0
else
   return 1
fi
}

#############################
## Main

if [[ $# = 0 || $# > 1 ]]
then
   echo ""
   echo "ERROR: Provide correct parameter value to the script."
   help
   exit 1
elif [[ $1 = "help" ]]
then
   if help
   then
       exit 0
   else
      echo ""
      echo "ERROR: Unexpected error occured!"
      echo ""
      exit 1
   fi
elif [[ $1 = "sa" ]]
then
   echo ""
   echo "INFO: Running script for standalone instance."
   echo ""
   if sa
   then
      echo ""
      echo "Completed!"
      exit 0
   else
      echo ""
      echo "ERROR: Looks like something went wrong. Try to run oradebug from sqlplus manually."
      echo ""
      exit 1
   fi
elif [[ $1 = "rac" ]]
then
   echo ""
   echo "INFO: Running script for RAC cluster."
   echo ""
   if rac
   then
      echo ""
      echo "Completed!"
      exit 0
   else
      echo ""
      echo "ERROR: Looks like something went wrong. Try to run oradebug from sqlplus manually."
      echo ""
      exit 1
   fi
else
   echo ""
   echo "ERROR: Provide correct parameter value to the script."
   help
   exit 1
fi
