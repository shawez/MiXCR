#!/bin/bash

# This Shell scipt is to run MiXCR software platform for immune profiling with Next-Generation Sequencing (NGS) data.
# This Shell scipt performs Alignment, Assembly analysis and then Export clones from Bulk TCR RNA seq data. 

###############################################################################################################################################
# Steps to follow before using MiXCR

# 1. Please set the path of your input FASTQ files
homepath='/home/projects/cu_10158/people/arighi/MIXCR/FastqFiles/Plate3'

# 2. Please set the path of output folder
outPut='/home/projects/cu_10158/people/arighi/MIXCR/outPut/'

# 3. Please set -OmaxBadPointsPercent to 0 for bulk samples and to 0.5 for clones in Assemple section

# 4. Please set the minimum number of reads that you want to export (-m) in Clones section

################################################################################################################################################
#the line below should be run in Terminal after saving 
# qsub -W group_list=cu_10158 -A cu_10158 -l nodes=2:ppn=10,mem=40gb,walltime=1:00:00 mixcrAnalysis_loop.sh

module load tools
module load openjdk/18.0.1
module load mixcr/4.0.0
cd $homepath

# Check if input data directory exists
if [ -d "$homepath" ]; 
then
  echo "'$homepath' found and now checking for output file folder.. please wait ..."
  if [ -d "$outPut" ];
  then
    echo "Starting mixcr on your input data"
  else
  echo "Path to output folder directory missing. Please use correct path to the output folder"
  exit
  fi
  
for R1 in *L001_R1*
do
  R2=${R1//R1_001.fastq.gz/R2_001.fastq.gz} 
  outPutFile=$(cut -d_ -f1-2 <<< "$R1")
  echo "Running mixcr on $outPutFile"

# Alignment
  mixcr align --species HomoSapiens $R1 $R2 $outPut/$outPutFile.vdjcan -f

# Assemble
  mixcr assemble -OmaxBadPointsPercent=0.5 $outPut/$outPutFile.vdjcan $outPut/$outPutFile.clns -f
  rm $outPut/$outPutFile.vdjcan

# Clones
  mixcr exportClones -t -o -m5 $outPut/$outPutFile.clns $outPut/$outPutFile"_TRA_TRB".txt -f
  rm $outPut/$outPutFile.clns
  echo "Congratulations,  Your MiXCR analysis is finished"
done

else
echo "Path to raw fastq files is NOT correct. Please use the correct path"
   exit
fi

