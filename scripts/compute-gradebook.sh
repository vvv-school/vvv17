#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

if [ -d build ]; then
  rm -Rf build
fi
mkdir build

wget -O build/git.md        https://raw.githubusercontent.com/vvv17-git/vvv17-git.github.io/master/README.md
wget -O build/yarp.md       https://raw.githubusercontent.com/vvv17-yarp/vvv17-yarp.github.io/master/README.md
wget -O build/kinematics.md https://raw.githubusercontent.com/vvv17-kinematics/vvv17-kinematics.github.io/master/README.md
wget -O build/dynamics.md   https://raw.githubusercontent.com/vvv17-dynamics/vvv17-dynamics.github.io/master/README.md
wget -O build/vision.md     https://raw.githubusercontent.com/vvv17-vision/vvv17-vision.github.io/master/README.md

file_list=$(ls ./build/*.md)
for entry in $file_list; do  
  cat $entry | grep total_score | sed 's/[^0-9]//g' > build/scores
  mapfile -t scores < build/scores
  
  if [ -z $tot_scores ]; then
    tot_scores=("${scores[@]}") 
  else
    for (( i=0; i<${#tot_scores[@]}; i++ )); do
      let tot_scores[i]+="${scores[i]}"
    done
  fi
done

cat `echo "${file_list}" | head -1` | grep '###' | awk {'print $2'} > build/usernames
mapfile -t usernames < build/usernames
for (( i=0; i<${#tot_scores[@]}; i++ )); do
  echo "${usernames[i]} ${tot_scores[i]}" >> build/unsorted_grades
done

sort -r -k 2 build/unsorted_grades > build/sorted_grades

if [ -f final-gradebook.md ]; then
  rm final-gradebook.md
fi

echo "| username | score |" >> final-gradebook.md
echo "| :---: | :---: |" >> final-gradebook.md
for (( i=1; i<=${#tot_scores[@]}; i++ )); do
  line=$(eval "sed '${i}q;d' build/sorted_grades")
  username=$(echo "$line" | awk {'print $1'})
  score=$(echo "$line" | awk {'print $2'})
  echo "| $username | $score |" >> final-gradebook.md
done
