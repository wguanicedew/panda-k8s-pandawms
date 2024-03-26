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
if [[ $ntasks -gt 0 ]]; then
    cmd="$cmd --ntasks $ntasks"
fi
if [[ ${cpus_per_task} -gt 0 ]]; then
    cmd="$cmd --cpus-per-task ${cpus_per_task}"
fi
if [[ ${mem_per_cpu} -gt 0 ]]; then
    cmd="$cmd --mem-per-cpu ${mem_per_cpu}"
fi

latest=$(ls -td /cvmfs/sw.lsst.eu/linux-x86_64/panda_env/v* | head -1)
rucio_cfg=${latest}/rucio/rucio-rubin.cfg

# export RUCIO_CONFIG=/cvmfs/sw.lsst.eu/linux-x86_64/panda_env/v1.0.9/conda/install/envs/pilot/etc/rucio.cfg.atlas.client.template
export RUCIO_CONFIG=$rucio_cfg

# env

echo
# cmd="$cmd --export=ALL /cvmfs/sw.lsst.eu/linux-x86_64/panda_env/v1.0.9/pilot/wrapper/rubin-wrapper.sh $@"
cmd="$cmd --export=ALL ${latest}/pilot/wrapper/rubin-wrapper.sh $@"
echo $cmd

ntasks=${ntasks_total}
for i in $(seq 1 $ntasks); do
    $cmd | sed -e "s/^/pilot_$i: /"  &
done

wait
