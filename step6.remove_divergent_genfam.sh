#!/bin/bash

# note that *.charge_out or *.MY_out of divergent gene family will be moved to another folder
# (that's why no divergent gene family will be found when you run this script again)

WORK_DIR=$(pwd)

while read LINE ; do
  if [[ ${LINE:0:3} == 'HON' ]] ; then

    HON=$(echo $LINE | cut -d"=" -f1)
    HON_DIR=$(echo $LINE | cut -d"=" -f2)
    echo ">>> $HON"
    cd ${WORK_DIR}/04_dRdC_dat/${HON}

    # make dir for excluded genfam
    for CLASS in 'charge' 'MY' ; do
      if [ ! -d divergent_genfam.$CLASS ] ; then
        mkdir divergent_genfam.$CLASS
      else
	rm divergent_genfam.$CLASS/divergent.seqid
      fi
    done

    # check divergent genfam
    for PT in pt* ; do
      echo " >> $PT"
      for CLASS in 'charge' 'MY' ; do
        for DATFILE in $PT/*.${CLASS}_out ; do
	  GENFAM=$( basename $DATFILE | cut -d"." -f1 )
	  SEQFILE=${WORK_DIR}/03_tstv/${GENFAM}.seq
	  OUTDIR=divergent_genfam.$CLASS
    perl ${WORK_DIR}/step6.identify_divergent_genfam.pl $SEQFILE $DATFILE $OUTDIR
	done
      done
    done  

    # exclude divergent genfam    
    for CLASS in 'charge' 'MY' ; do
      # if the divergent.seqid file has size (that is, not zero size)
      if [ -s divergent_genfam.$CLASS/divergent.seqid ] ; then
        cut -d":" -f1 divergent_genfam.$CLASS/divergent.seqid | sort | uniq > divergent_genfam.$CLASS/divergent.genfam
        while read EXCLUDE ; do
	  mv $EXCLUDE divergent_genfam.$CLASS
        done <divergent_genfam.$CLASS/divergent.genfam
      fi
    done

  fi
done < ${WORK_DIR}/04_dRdC_pipeline.cfg
