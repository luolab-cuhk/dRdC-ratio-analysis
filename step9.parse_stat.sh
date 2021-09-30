#!/bin/bash

# this scriptis parse the mean, median, se, pvalue of sign test and ttest for each PNC_PNR output
# the output is ./04_dRdC_dat/dRdC.Rout.parsed

WORK_DIR=$(pwd)
TARGET_CLADES="TargetClade"

for TARGET in ${TARGET_CLADES[@]} ; do
  cd ${WORK_DIR}

  # write title to output
  OUTPUT=${WORK_DIR}/04_dRdC_dat/dRdC.target_${TARGET}.Rout_parsed
  printf "classification\tclade\tis_target\tis_plotted\tcmp_clade\t" > $OUTPUT
  printf "HON3_avg\tHON3_se\tHON3_median\tHON3_sign_test\tHON3_ttest\t" >> $OUTPUT
  printf "HON2_avg\tHON2_se\tHON2_median\tHON2_sign_test\tHON2_ttest\t" >> $OUTPUT
  printf "HON0_avg\tHON0_se\tHON0_median\tHON0_sign_test\tHON0_ttest\n" >> $OUTPUT

  CONTROL_CLADES="ControlClade"
  for CONTROL in ${CONTROL_CLADES[@]} ; do
    echo ":::::: Target = $TARGET, Control = $CONTROL ::::::"

    # statistics
    COMB="target_${TARGET}.control_${CONTROL}"
    for CLASS in 'charge' 'MY' ; do
      echo ">>> $CLASS"

      # _______________________________
      # 1) write target data to output
      printf "%s\t%s\t1\t0\t%s\t" $CLASS $TARGET $CONTROL  >> $OUTPUT

      # load dat from each HON
      while read LINE ; do
        if [[ ${LINE:0:3} == 'HON' ]] ; then
          HON=$(echo $LINE | cut -d"=" -f1)
          HON_DIR=$(echo $LINE | cut -d"=" -f2)
          cd ${WORK_DIR}/04_dRdC_dat/${HON}
	  ROUT=PNC_PNR.${COMB}.${CLASS}.Rout

	  # avg, se and median
	  avg=$( grep -A 1 \"mean\" $ROUT | tail -1 | cut -d" " -f2 )
	  se=$( grep -A 1 \"se\" $ROUT | tail -1 | cut -d" " -f2 )
	  median=$( grep -A 1 \"median\" $ROUT | tail -1 | cut -d" " -f2)
	  # pvalue of sign test and t-test will be assigned to control clade

	  # print to output
	  printf "%.3f\t%.3f\t%.3f\tNA\tNA" $avg $se $median  >> $OUTPUT
	  if [[ $HON != 'HON0_zhang' ]]; then
	    printf "\t" >> $OUTPUT
	  fi
	fi
      done < ${WORK_DIR}/04_dRdC_pipeline.cfg
      printf "\n" >> $OUTPUT

      # ________________________________
      # 2) write control data to output
      printf "%s\t%s\t0\t1\t%s\t" $CLASS $CONTROL $TARGET  >> $OUTPUT

      # load dat from each HON
      while read LINE ; do
        if [[ ${LINE:0:3} == 'HON' ]] ; then
          HON=$(echo $LINE | cut -d"=" -f1)
          HON_DIR=$(echo $LINE | cut -d"=" -f2)
          cd ${WORK_DIR}/04_dRdC_dat/${HON}
	  ROUT=PNC_PNR.${COMB}.${CLASS}.Rout

	  # avg, se and median
	  avg=$( grep -A 2 \"mean\" $ROUT | tail -1 | cut -d" " -f2 )
	  se=$( grep -A 2 \"se\" $ROUT | tail -1 | cut -d" " -f2 )
	  median=$( grep -A 2 \"median\" $ROUT | tail -1 | cut -d" " -f2)
	  # pvalue of sign test and t-test
  	  signtest=$(grep "number of successes" $ROUT | cut -d"," -f3 | cut -d" " -f4)
	  ttest=$(grep "t = " $ROUT | cut -d"," -f3 | cut -d" " -f4)

	  # print to output
	  printf "%.3f\t%.3f\t%.3f\t%s\t%s" $avg $se $median $signtest $ttest >> $OUTPUT
	  if [[ $HON != 'HON0_zhang' ]]; then
	    printf "\t" >> $OUTPUT
	  fi
	fi
      done < ${WORK_DIR}/04_dRdC_pipeline.cfg
      printf "\n" >> $OUTPUT

    done
  done

  # add target average value to the end of output file
  INPUT=$WORK_DIR/04_dRdC_dat/target_$TARGET.median.Rinput
  head -1 $OUTPUT > $INPUT  
  for CLASS in 'charge' 'MY' ; do
    if [[ ${#TAGET_CLADES[@]}==1 ]]; then
      grep ^$CLASS$'\t'$TARGET$'\t' $OUTPUT | grep $CLASS | sed '$ d' >> $INPUT
    else
      grep ^$CLASS$'\t'$TARGET$'\t' $OUTPUT | grep $CLASS >> $INPUT 	# don't do "sed '$ d' " for Prochlorococcus
    fi
  done
  Rscript /home-user/xyfeng/18_new_pipeline_build/33_drdc/scripts/calc_target_dRdC_avg.R  $INPUT  $OUTPUT

  # sort output file
  head -1 $OUTPUT > $OUTPUT.tmp
  grep -v classification $OUTPUT | sort -k1,3 >> $OUTPUT.tmp
  mv $OUTPUT.tmp $OUTPUT 
  
done


# move to output folder
cd ${WORK_DIR}/
mkdir -p output
mv 04_dRdC_dat/*.Rout_parsed output


