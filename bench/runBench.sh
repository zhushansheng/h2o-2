#!/bin/bash

#set -x

h2oBuild=
benchmarks="benchmarks"
DATE=`date +%Y-%m-%d`

function ALL() {
    echo "Running PCA benchmark..."
    PCA
    wait
    echo "Running KMeans benchmark..."
    KMeans
    wait
    echo "Running GLM benchmark..."
    GLM
    wait
    #echo "Running Big KMeans..."
    #BigKMeans
    #wait
}

function PCA() {
    pyScript="BMscripts/pcaBench.py"
    python ${pyScript} --config_json BMscripts/${JSON} ${h2oBuild}
    wait
}

function KMeans() {
    pyScript="BMscripts/kmeansBench.py"
    python ${pyScript} --config_json BMscripts/${JSON} ${h2oBuild}
    wait
}

function BigKMeans() {
    #py_args="BMscripts/BigKMeansBench.py -cj ${JSON}"
    #python "$py_args"
    #echo ${py_args}
    #wait
    echo "No Big KMeans yet..."
}

function GLM() {
    pyScript="BMscripts/glmBench.py"
    python ${pyScript} --config_json BMscripts/${JSON} ${h2oBuild}
    wait
}

usage()
{
cat << EOF

usage: $0 [options]

This script obtains the latest h2o jar from S3 and runs the benchmarks for PCA, KMeans, GLM, and BigKMeans.

OPTIONS:
   -h      Show this message
   -t      Run task:
               Choices are:
                   ALL        -- Runs PCA, KMeans, GLM, and BigKMeans
                   PCA        -- Runs PCA on Airlines/AllBedrooms data
                   KMeans     -- Runs KMeans on Airlines/AllBedrooms data
                   GLM        -- Runs logistic regression on Airlines/AllBedrooms data
                   BigKMeans  -- Runs KMeans on 180 GB of synthetic data
   -j      JSON config:
               Choices are:
                   161        -- Runs benchmark(s) on single machine on 161
                   164        -- Runs benchmark(s) on single machine on 164
                   161_164    -- Runs benchmark(s) on four machines 161 - 164
EOF
}

TASK=
JSON=
while getopts "ht:j:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    t)
      TEST=$OPTARG
      ;;
    j)
      JSON=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -z "$TEST" ] || [ -z "$JSON" ]
then
    usage
    exit
fi

#bash S3getLatest.sh
#wait
h2oBuild=`cat latest`

if [ -a ${benchmarks}/${h2oBuild}/${DATE}/"pcabench.csv" ]; then
 rm -f ${benchmarks}/${h2oBuild}/${DATE}/"pcabench.csv"
fi

if [ -a ${benchmarks}/${h2oBuild}/${DATE}/"glmbench.csv" ]; then
 rm -f ${benchmarks}/${h2oBuild}/${DATE}/"glmbench.csv"
fi

if [ -a ${benchmarks}/${h2oBuild}/${DATE}/"kmeansbench.csv" ]; then
 rm -f ${benchmarks}/${h2oBuild}/${DATE}/"kmeansbench.csv"
fi

#if [ -a ${benchmarks}/${h2oBuild}/${DATE}/bigkmeansbench.csv ]; then
# rm -f ${benchmarks}/${h2oBuild}/${DATE}/bigkmeansbench.csv
#fi

if [ ! -d ${benchmarks}/${h2oBuild}/${DATE} ]; then
  mkdir -p ${benchmarks}/${h2oBuild}/${DATE}
fi
#rm latest
$TEST

