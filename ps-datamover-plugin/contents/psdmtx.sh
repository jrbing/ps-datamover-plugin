#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en
#===============================================================================
#
#          FILE: psdmtx.sh
#
#   DESCRIPTION: executes the specified datamover script on a remote node
#
#===============================================================================

#set -e                          # Exit immediately on error

database_type=$1
database_name=$2
connect_id=$3
connect_password=$4
username=$5
password=$6
datamover_script=$7

required_environment_variables=( PS_HOME PS_CFG_HOME PS_APP_HOME PS_PIA_HOME PS_CUST_HOME TUXDIR )
optional_environment_variables=( JAVA_HOME PS_FILEDIR PS_SERVDIR ORACLE_HOME ORACLE_BASE TNS_ADMIN AGENT_HOME )

# Set environment variables
# Validate datamover script exists
export DM_HOME=$HOME/PS_DM
export PS_DM_DATA_IN=$DM_HOME/data
export PS_DM_DATA_OUT=$DM_HOME/data
export PS_DM_LOG=$DM_HOME/log
export PS_DM_SCRIPT="$(dirname ${datamover_script})"

set_required_environment_variables () {
  for var in ${required_environment_variables[@]}; do
    rd_node_var=$( printenv RD_NODE_${var} )
    export $var=$rd_node_var
  done
}

set_optional_environment_variables () {
  for var in ${optional_environment_variables[@]}; do
    if [[ `printenv RD_NODE_${var}` ]]; then
      rd_node_var=RD_NODE_${var}
      export $var=$( printenv $rd_node_var )
    fi
  done
}

check_variables () {
  for var in ${required_environment_variables[@]}; do
    if [[ `printenv ${var}` = '' ]]; then
      echo "${var} is not set.  Please make sure this is set before continuing."
      exit 1
    fi
  done
}

update_path () {
  #export PATH=$PATH:.
  export PATH=$TUXDIR/bin:$PATH
  export PATH=$PS_HOME/bin:$PATH
  [[ $ORACLE_HOME ]] && export PATH=$ORACLE_HOME/bin:$PATH
  [[ $AGENT_HOME ]] && export PATH=$AGENT_HOME/bin:$PATH
}

update_ld_library_path () {
  export LD_LIBRARY_PATH=$PS_HOME/verity/linux/_ilnx21/bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/optbin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/bin/sqr/ORA/bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/bin/interfacedrivers:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/jre/lib/amd64:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/jre/lib/amd64/native_threads:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$TUXDIR/lib:$LD_LIBRARY_PATH
  [[ $JAVA_HOME ]] && export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
  [[ $ORACLE_HOME ]] && export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
}

#######################
# Setup the environment
#######################
set_required_environment_variables
check_variables
set_optional_environment_variables
update_path
update_ld_library_path

psdmtx -CT $database_type \
  -CD $database_name \
  -CO $username \
  -CP $password \
  -CI $connect_id \
  -CW $connect_password \
  -FP $datamover_script
