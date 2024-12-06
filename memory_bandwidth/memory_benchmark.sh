#!/bin/bash

#PATH="/users/patrickt/mnt/sdb/starling/release/tests/"
PREFIX=/users/patrickt/mnt/sdb/starling/test_disk_index/spaceV1B
DATA_TYPE=int8
QUERY_FILE=/users/patrickt/mnt/sdb/SPTAG/datasets/SPACEV1B/query.bin
GT_FILE=/users/patrickt/mnt/sdb/DiskANN/build/spacev1b_gt100
result=/users/patrickt/mnt/sdb/starling/test_disk_index/spaceV1Bresult/result
EXE_PATH="../release"
DIST_FN=l2

#BM_LIST=(4)
#T_LIST=(48)
L_VALUES=(10 20 30 40 50)
#L_VALUES=(10)
BW=4
T=16
LS="10"
CACHE=0
CACHE_L=(0 1000000 10000000)
M=100
R=64
BUILD_L=100
B=3.25
USE_PAGE_SEARCH=1
MEM_R=64
MEM_BUILD_L=100
MEM_ALPHA=1.2
MEM_USE_FREQ=0
MEM_RAND_SAMPLING_RATE=0.01
MEM_FREQ_USE_RATE=0.01
INDEX_PREFIX_PATH="${PREFIX}_M${M}_R${R}_L${BUILD_L}_B${B}/"
MEM_INDEX_PATH="${INDEX_PREFIX_PATH}MEM_R_${MEM_R}_L_${MEM_BUILD_L}_ALPHA_${MEM_ALPHA}_MEM_USE_FREQ${MEM_USE_FREQ}_RANDOM_RATE${MEM_RAND_SAMPLING_RATE}_FREQ_RATE${MEM_FREQ_USE_RATE}/"
PS_USE_RATIO=1.0
DISK_FILE_PATH=${INDEX_PREFIX_PATH}_disk_beam_search.index
USE_SQ=0
MEM_LS=(0 1)
K=10

sudo modprobe amd_uncore
mkdir -p ${INDEX_PREFIX_PATH}/search
mkdir -p ${INDEX_PREFIX_PATH}/result
mkdir amd_results
mkdir cpu_results
if [ ! -d "$INDEX_PREFIX_PATH" ]; then
    echo "Directory $INDEX_PREFIX_PATH is not exist. Build it first?"
    exit 1
fi

# choose the disk index file by settings
DISK_FILE_PATH=${INDEX_PREFIX_PATH}_disk.index
if [ $USE_PAGE_SEARCH -eq 1 ]; then
    if [ ! -f ${INDEX_PREFIX_PATH}_partition.bin ]; then
    echo "Partition file not found. Run the script with gp option first."
    exit 1
    fi
    echo "Using Page Search"
else
    OLD_INDEX_FILE=${INDEX_PREFIX_PATH}_disk_beam_search.index
    if [ -f ${OLD_INDEX_FILE} ]; then
    DISK_FILE_PATH=$OLD_INDEX_FILE
    else
    echo "make sure you have not gp the index file"
    fi
    echo "Using Beam Search"
fi

log_arr=()
for MEM_L in ${MEM_LS[@]}
do
    for L in ${L_VALUES[@]}
    do
        for CACHE in ${CACHE_L[@]}
        do
            SEARCH_LOG=${INDEX_PREFIX_PATH}search/search_SQ${USE_SQ}_K${K}_L${L}_CACHE${CACHE}_BW${BW}_T${T}_MEML${MEM_L}_MEMK${MEM_TOPK}_MEM_USE_FREQ${MEM_USE_FREQ}_PS${USE_PAGE_SEARCH}_USE_RATIO${PS_USE_RATIO}_GP_USE_FREQ{$GP_USE_FREQ}_GP_LOCK_NUMS${GP_LOCK_NUMS}_GP_CUT${GP_CUT}.log
            echo "Searching... log file: ${SEARCH_LOG}"
            sync; echo 3 | sudo tee /proc/sys/vm/drop_caches; nohup ${EXE_PATH}/tests/search_disk_index --data_type $DATA_TYPE \
                --dist_fn $DIST_FN \
                --index_path_prefix $INDEX_PREFIX_PATH \
                --query_file $QUERY_FILE \
                --gt_file $GT_FILE \
                -K $K \
                --result_path ${INDEX_PREFIX_PATH}result/result \
                --num_nodes_to_cache $CACHE \
                -T $T \
                -L $L \
                -W $BW \
                --mem_L ${MEM_L} \
                --mem_index_path ${MEM_INDEX_PATH}_index \
                --use_page_search ${USE_PAGE_SEARCH} \
                --use_ratio ${PS_USE_RATIO} \
                --disk_file_path ${DISK_FILE_PATH} \
                --benchmark 1 \
                --use_sq ${USE_SQ} > ${SEARCH_LOG} &
            pid=$!;
            echo ${pid};
            log_arr+=( ${SEARCH_LOG} );
            # result_path="${INDEX_PREFIX_PATH}result/result";
            #echo "${SEARCH_LOG}"
            # check for QPS text in header file, indicating that the program has begun searching
            # queries
            while true; do
                grep -q "QPS" "${SEARCH_LOG}"
                result=$? 

                if [ $result -eq 0 ]; then
                    break 
                elif [ $result -eq 1 ]; then
                    sleep 60
                fi
            done
            sleep 30;
            echo "Beginning Memory Analysis";
            cd /opt/AMDuProf_5.0-1479/bin;
            MEMORY_LOG=/users/patrickt/mnt/sdb/starling/memory_bandwidth/amd_results/${L}_${MEM_L}_${CACHE}_results.csv;
            sudo ./AMDuProfPcm -m memory -a -d 10 -o ${MEMORY_LOG};
            
            echo "Beginning CPU Utilization Analysis";
            samples=5;
            output_file=/users/patrickt/mnt/sdb/starling/memory_bandwidth/cpu_results/${L}_${MEM_L}_${CACHE}_results.csv;
            for ((i=1; i<=samples; i++)); do
                timestamp=$(date "+%Y-%m-%d %H:%M:%S")
                sudo ps -eo pid,pcpu,comm | grep "search_disk" | grep -v "grep" | awk -v ts="$timestamp" '{print ts","$1","$2","$3}' >> "$output_file"
                sleep 10
            done
            
            echo "Killing Search";
            kill -9 ${pid};
            cd /users/patrickt/mnt/sdb/starling/memory_bandwidth/;
        done
        # while kill -0 $pid 2>/dev/null; do
        # 	sleep 1
    done
done