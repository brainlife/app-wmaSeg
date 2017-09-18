#!/bin/bash

#make sure jq is installed on $SCA_SERVICE_DIR (used by status.sh to analyze progress)
#if [ ! -f $SCA_SERVICE_DIR/jq ];
#then
#        echo "installing jq"
#        wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O $SCA_SERVICE_DIR/jq
#        chmod +x $SCA_SERVICE_DIR/jq
#fi

#mainly to debug locally
if [ -z $WORKFLOW_DIR ]; then export WORKFLOW_DIR=`pwd`; fi
if [ -z $TASK_DIR ]; then export TASK_DIR=`pwd`; fi
if [ -z $SERVICE_DIR ]; then export SERVICE_DIR=`pwd`; fi

#clean up previous job (just in case)
rm -f finished
qsub $SERVICE_DIR/submit.pbs > jobid
#jobid=`qsub -q preempt SERVICE_DIR/submit.pbs`
#echo $jobid > jobid

