#!/bin/bash

set -e
set -u
set -o pipefail

# get the directory the script exists in
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source the common bash script 
. "${__dir}/../../scripts/common.sh"

# ensure PLUGIN_PATH is set
TMPDIR=${TMPDIR:-"/tmp"}
PLUGIN_PATH=${PLUGIN_PATH:-"${TMPDIR}/snap/plugins"}
mkdir -p $PLUGIN_PATH

_info "Get latest plugins"
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-collector-psutil/latest/linux/x86_64/snap-plugin-collector-psutil && chmod 755 snap-plugin-collector-psutil)
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-collector-processes/latest/linux/x86_64/snap-plugin-collector-processes && chmod 755 snap-plugin-collector-processes)
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-collector-meminfo/latest/linux/x86_64/snap-plugin-collector-meminfo && chmod 755 snap-plugin-collector-meminfo)
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-publisher-file/latest/linux/x86_64/snap-plugin-publisher-file && chmod 755 snap-plugin-publisher-file)

# (cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-publisher-opentsdb/latest/linux/x86_64/snap-plugin-publisher-opentsdb && chmod 755 snap-plugin-publisher-opentsdb)
(cd $PLUGIN_PATH && cp /snap-plugin-publisher-opentsdb/build/linux/x86_64/snap-plugin-publisher-opentsdb . && chmod 755 snap-plugin-publisher-opentsdb)


# this block will wait check if snaptel and snapteld are loaded before the plugins are loaded and the task is started
 for i in `seq 1 5`; do
             if [[ -f /usr/local/bin/snaptel && -f /usr/local/sbin/snapteld ]];
                then

                    _info "loading plugins"
                    snaptel plugin load "${PLUGIN_PATH}/snap-plugin-collector-psutil"
                    snaptel plugin load "${PLUGIN_PATH}/snap-plugin-collector-processes"
                    snaptel plugin load "${PLUGIN_PATH}/snap-plugin-collector-meminfo"
                    snaptel plugin load "${PLUGIN_PATH}/snap-plugin-publisher-file"
                    snaptel plugin load "${PLUGIN_PATH}/snap-plugin-publisher-opentsdb"

                    _info "creating and starting a task"
                    snaptel task create -t "${__dir}/config.json" 

                    SNAP_FLAG=1

                    break
             fi 
        
        _info "snaptel and/or snapteld are unavailable, sleeping for 3 seconds" 
        sleep 3
done 


# check if snaptel/snapteld have loaded
if [ $SNAP_FLAG -eq 0 ]
    then
     echo "Could not load snaptel or snapteld"
     exit 1
fi