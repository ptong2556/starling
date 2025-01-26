#!/bin/sh

# Switch dataset in the config_local.sh file by calling the desired function

#################
#   BIGANN10M   #
#################
dataset_bigann10M() {
  BASE_PATH=/mnt/sdb/SPTAG/datasets/SPACEV1B/vectors.bin/vectors_merged.bin
  QUERY_FILE=/mnt/sdb/SPTAG/datasets/SPACEV1B/query.bin
  GT_FILE=/mnt/sdb/DiskANN/build/spacev1b/spacev1b_gt
  PREFIX=/mnt/sdb/starling/disk_index/spaceV1B
  DATA_TYPE=int8
  DIST_FN=l2
  B=3.25
  K=10
  DATA_DIM=100
  DATA_N=100000000
}
