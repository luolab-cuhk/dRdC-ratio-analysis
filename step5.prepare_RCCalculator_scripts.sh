#!/bin/bash

WORK_DIR=$(pwd)
DATA_DIR=${WORK_DIR}/04_dRdC_dat
GENES_DIR=${WORK_DIR}/03_tstv
TsTv_FILE=${WORK_DIR}/03_tstv/TsTv_ratio.txt
NUM_RUNS_PER_JOB=10

STEP5_SCRIPT=${WORK_DIR}/"step5.run_RCCalculator.sh"
echo "# run RCCalculator" > ${STEP5_SCRIPT}
chmod +x ${STEP5_SCRIPT}

# split jobs
mkdir -p ${DATA_DIR}
cd ${DATA_DIR}
ls ${GENES_DIR}/*.seq > list_genfam
split -d -l ${NUM_RUNS_PER_JOB} --suffix-length 4 list_genfam list_genfam.pt
ls list_genfam.pt* > ls_pt.tmp
cd ..

while read LINE ; do
  if [[ ${LINE:0:3} == 'HON' ]] ; then
    HON=$(echo $LINE | cut -d"=" -f1)
    HON_DIR=$(echo $LINE | cut -d"=" -f2)
    echo $HON
    mkdir -p ${DATA_DIR}/${HON}
    cd ${DATA_DIR}/${HON}
    
    # for each job, make a folder and copy program to there
    while read PART ; do
      PT=$(echo ${PART} | cut -f2 -d".")
      mkdir -p $PT
      cd $PT
      cp ${WORK_DIR}/${HON_DIR}/prog1 ${WORK_DIR}/${HON_DIR}/*.div .

      # for each gene family, create command line
      SH="run_HON.sh"
      while read GENFAM ; do
	NAME=$(basename $GENFAM | cut -d"." -f1)
	# input parameter file, including Ts/Tv ratio
	TsTv=$(grep ${NAME} ${TsTv_FILE} | cut -f2)
	IN_PARA="1 ${TsTv} 0.05"
	if [[ ${HON:0:4} == "HON0" ]]; then
	  IN_PARA="${TsTv}"
	fi
        echo "${IN_PARA} 1" >> ${NAME}.charge_in
	echo "${IN_PARA} 3" >> ${NAME}.MY_in
	# charge 
	echo "./prog1 ${GENFAM} < ${NAME}.charge_in" >> $SH
	echo "mv outfile ${NAME}.charge_out" >> $SH
	# MY
	echo "./prog1 ${GENFAM} < ${NAME}.MY_in" >> $SH
	echo "mv outfile ${NAME}.MY_out" >> $SH
	echo "" >> $SH
      done <${DATA_DIR}/${PART}
      chmod +x $SH
      # LSF file
      LSF=run_HON.lsf
      echo "#!/bin/bash" >> $LSF
      echo "./run_HON.sh" >> $LSF
      chmod +x $LSF
      echo "cd $(pwd)" >> ${STEP5_SCRIPT}
      echo "sbatch -n1 ./$LSF" >> ${STEP5_SCRIPT}
      cd ..
    done <${DATA_DIR}/ls_pt.tmp

  fi
done < ${WORK_DIR}/04_dRdC_pipeline.cfg
