#!/bin/bash
### --ntasks-total=8 --ntasks=1 --cpus-per-task=1 --mem-per-cpu=4000

ntasks_total=1
ntasks=-1
cpus_per_task=-1
mem_per_cpu=-1

myargs="$@"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --ntasks-total)
    ntasks_total="$2"
    shift
    shift
    ;;
    --ntasks)
    ntasks="$2"
    shift
    shift
    ;;
    --cpus-per-task)
    cpus_per_task="$2"
    shift
    shift
    ;;
    --mem-per-cpu)
    mem_per_cpu="$2"
    shift
    shift
    ;;
    *)
    POSITIONAL+=("$1") # save it in an array for later
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

pilotargs="$@"

cmd="srun"
# if [[ $ntasks -gt 0 ]]; then
#    cmd="$cmd --ntasks $ntasks"
# fi
if [[ ${cpus_per_task} -gt 0 ]]; then
    cmd="$cmd --cpus-per-task ${cpus_per_task}"
fi
if [[ ${mem_per_cpu} -gt 0 ]]; then
    cmd="$cmd --mem-per-cpu ${mem_per_cpu}"
fi

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

# cmd="$cmd --export=ALL /cvmfs/sw.lsst.eu/linux-x86_64/panda_env/v1.0.9/pilot/wrapper/rubin-wrapper.sh $@"
# cmd="$cmd --export=ALL ${latest}/pilot/wrapper/rubin-wrapper.sh $@ --realtime-logging-server logserver='google-cloud-logging;https://google:80'"

pilot_wrapper_cmd="${pandaenvdir}/pilot/wrapper/rubin-wrapper.sh ${piloturl} --pandaenvtag v1.0.17 $@ --realtime-logging-server logserver='google-cloud-logging;https://google:80'"

echo $cmd
echo $pilot_wrapper_cmd
echo

# ntasks=${ntasks_total}
# for i in $(seq 1 $ntasks); do
#     $cmd | sed -e "s/^/pilot_$i: /"  &
# done
#
# wait

cat <<EOF > my_panda_run_script
#!/bin/bash

# Ensure SLURM_PROCID is available per task
echo "Task started: pilot_\${SLURM_PROCID} on $(hostname)"

echo ${pilot_wrapper_cmd} | sed -e "s/^/pilot_\${SLURM_PROCID}: /"
echo

${pilot_wrapper_cmd} | sed -e "s/^/pilot_\${SLURM_PROCID}: /"

EOF


chmod +x my_panda_run_script


echo $cmd --export=ALL --ntasks=${ntasks_total} --cpu-bind=none ./my_panda_run_script
echo

$cmd --export=ALL --ntasks=${ntasks_total} --cpu-bind=none ./my_panda_run_script
