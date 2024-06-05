#!/bin/bash

set -u

NVIDIA_SMI_QUERY_GPU="uuid,index,memory.total"
NVIDIA_SMI_QUERY_COMPUTE_APPS="gpu_uuid,pid,process_name,used_memory"
PID_INDEX=3
COMMAND_INDEX=4
CONTAINER_ID_INDEX=3
CONTAINER_ID_DIGITS=12

join -a 1 \
    <(nvidia-smi --query-gpu=${NVIDIA_SMI_QUERY_GPU} --format=csv,noheader,nounits | tr -s ", " "\t") \
    <(nvidia-smi --query-compute-apps=${NVIDIA_SMI_QUERY_COMPUTE_APPS} --format=csv,noheader,nounits | tr -s ", " "\t") | \
    tr -s ' ' '\t' | \
    
while read line
do
    pid=$(echo ${line} | awk '{print $4}')
#    echo "PID: ${pid}"

    process=$(ps -o "user,%mem,%cpu,command" -p $pid 2>/dev/null | grep -vE "^USER")
    if [ $? != 0 ]; then
        echo "Warning: Failed to get process info for PID ${pid}"
        continue
    fi
#    echo "Process Info: ${process}"

    # Trích xu?t user t? k?t qu? c?a ps
    user=$(echo ${process} | awk '{print $1}')
#    echo "User: ${user}"

    # Trích xu?t thông tin c?a ti?n trình t? k?t qu? c?a ps
    process=$(echo ${process} | awk -v OFS='\t' -v "command=${COMMAND_INDEX}" '{for(i=4;i<NF;i++){printf "%s ", $i} print $NF}')
#    echo "Processed Command: ${process}"

    containerid=$(head -n 1 /proc/$pid/cgroup | cut -d'/' -f ${CONTAINER_ID_INDEX} | cut -c 1-${CONTAINER_ID_DIGITS})
#    echo "Container ID: ${containerid}"

    dcprocess=$(docker ps | grep $containerid | awk -v 'OFS=\t' '{print $2,$NF}')
#    echo "Docker Process: ${dcprocess}"

    gpu_memory=$(echo ${line} | awk '{print $(NF-2),$NF}')
#    echo "GPU Memory: ${gpu_memory}"

    echo -e "${line}\t${user}\t${process}\t${dcprocess}"
done
