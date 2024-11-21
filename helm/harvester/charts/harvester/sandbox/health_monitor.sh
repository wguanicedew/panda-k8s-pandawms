#!/bin/bash

source  /opt/harvester/bin/activate
source  /data/condor/condor/condor.sh

python /data/harvester/health_monitor.py
