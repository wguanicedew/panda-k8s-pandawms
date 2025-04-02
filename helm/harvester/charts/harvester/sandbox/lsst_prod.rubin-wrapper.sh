#!/bin/bash
#
# pilot wrapper used for Rubin jobs
#

latest=$(ls -td /cvmfs/sw.lsst.eu/almalinux-x86_64/panda_env/v* | head -1)
pandaenvdir=${latest}

export PANDA_ENV_PILOT_DIR=${pandaenvdir}

echo "pandaenvdir: ${pandaenvdir}"
echo "PANDA_ENV_PILOT_DIR: ${PANDA_ENV_PILOT_DIR}"

rucio_cfg=${pandaenvdir}/rucio/rucio-rubin-dev.cfg

# export RUCIO_CONFIG=/cvmfs/sw.lsst.eu/linux-x86_64/panda_env/v1.0.9/conda/install/envs/pilot/etc/rucio.cfg.atlas.client.template
export RUCIO_CONFIG=$rucio_cfg

pilot_cfg=${pandaenvdir}/pilot/pilot_default.cfg
if [[ -f ${pilot_cfg} ]]; then
    if [[ -z "${HARVESTER_PILOT_CONFIG}" ]]; then
      export HARVESTER_PILOT_CONFIG=${pilot_cfg}
    fi
fi

export PILOT_ES_EXECUTOR_TYPE=fineGrainedProc

# https://rubin-panda-server-dev.slac.stanford.edu:8443/cache/schedconfig/{computingSite}.all.json
# https://datalake-cric.cern.ch/cache/schedconfig/{pandaqueue}.json
# https://datalake-cric.cern.ch/api/atlas/ddmendpoint/query/?json

queue_url=${pandaenvdir}/cric/datalake-cric-pandaqueue.json
storage_url=${pandaenvdir}/cric/datalake-cric-ddm.json
if [[ -f ${queue_url} ]]; then
    if [[ -z "${QUEUEDATA_SERVER_URL}" ]]; then
      export QUEUEDATA_SERVER_URL=${queue_url}
    fi
fi
if [[ -f ${storage_url} ]]; then
    if [[ -z "${STORAGEDATA_SERVER_URL}" ]]; then
      export STORAGEDATA_SERVER_URL=${storage_url}
    fi
fi

echo "QUEUEDATA_SERVER_URL: ${QUEUEDATA_SERVER_URL}"
echo "STORAGEDATA_SERVER_URL: ${STORAGEDATA_SERVER_URL}"
# env

echo

echo "check proxy"
voms-proxy-info -all
echo

piloturl=""
local_pilot=/sdf/data/rubin/panda_jobs/panda_env_pilot/prod_pilot3.tar.gz
if [[ -f ${local_pilot} ]]; then
    piloturl="--piloturl file://${local_pilot}"
fi

cmd="${pandaenvdir}/pilot/wrapper/rubin-wrapper.sh ${piloturl} --pandaenvtag v1.0.17 $@ --realtime-logging-server logserver='google-cloud-logging;https://google:80'"
echo $cmd
$cmd
