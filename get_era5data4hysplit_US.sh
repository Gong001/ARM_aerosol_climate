#!/bin/sh
# =============== Original ===============
#
# Example bash script for retrieving ERA5 for a small area.
# Author: Alice Crawford   Organization: NOAA/OAR/ARL

# Example for downloading and converting ERA5 data on pressure levels
# for a relatively small area.
# =============== Original ===============

# ==============================
# SOme changes has been made by
# Yemi Adebiyi, UC Merced
# ==============================

echo '=========================================================================================='
echo "RUNNING......: get_era5data4hysplit_US.sh ....."
echo '=========================================================================================='

echo "Year is $1";
echo "Month is $2";
echo "Day is $3";
echo "monthname is $4";

year=$1
month=$2
day=$3
monthname=$4

# python call
# MDL="python"
pythoncall="python3.9"

#Location of get_era5_cds.py
if [ -n "$ERA_datadir" ]; then
  echo "ERA_datadir is set and not empty."
else
  echo "ERA_datadir is either not set or empty."
  ERA_datadir='/home/aaadebiyi/data/shared_data/reanalysis_data/ERA5/ERA5_4hysplit_US/'
fi
# echo ${ERA_datadir}
# exit
MDL='/home/aaadebiyi/myshell/hysplit/data2arl/era52arl/'
PDL=${MDL}'/hysplit_metdata/'
# Note - if era52arl executable is not in MDL, it may be in  /home/aaadebiyi/myshell/hysplit/exec

#small area to retrieve
# upper left lat/ upper left lon / lower right lat / lower right lon
# NORTH/WEST/SOUTH/EAST
area="50/-125/20/-65" # This cover the entire US

#directory to write files to.
gribdir=${ERA_datadir}'/grib/'
arldir=${ERA_datadir}'/arl/'
/usr/bin/mkdir -p $gribdir
/usr/bin/mkdir -p $arldir


# Check if the ARL data is already available
arldata=${arldir}ERA5_${year}${month}${day}.ARL
if [ -f ${arldata} ]; then
  echo '-------------------------------------'
  echo "ARL file AVAILABLE: ${arldata} ....."
  echo '-------------------------------------'
else
  echo '-------------------------------------'
  echo "ARL file NOT AVAILABLE: ${arldata} ....."
  echo "........................"
  echo ".....check if GRIB files are available"
# Name of 3D and 3D ERA5 dataset to retrieve
  grib3dpl_file="ERA5_${year}.${monthname}${day}.3dpl.grib"
  grib2dpl_file="ERA5_${year}.${monthname}${day}.2dpl.all.grib"

  if [[ -f ${gribdir}${grib3dpl_file} && -f ${gribdir}${grib2dpl_file} ]]; then
    echo "GRIB files AVAILABLE: ${gribdir}${grib3dpl_file} and ${gribdir}${grib2dpl_file} .........."

    # So just convert to ARL here
    echo '-------------------------------------'
    echo "GENERATING ARL: year $year month $month day $day"
    /usr/bin/ln -s ${gribdir}${grib3dpl_file} ./
    /usr/bin/ln -s ${gribdir}${grib2dpl_file} ./
    # echo $MDL/era52arl -i${gribdir}${grib3dpl_file} -a${gribdir}${grib2dpl_file}
    $MDL/era52arl -i${grib3dpl_file} -a${grib2dpl_file}
    mv DATA.ARL ${arldata}
    /usr/bin/rm -f ${grib3dpl_file}
    /usr/bin/rm -f ${grib2dpl_file}
    echo '-------------------------------------'

  else
    echo "GRIB files NOT AVAILABLE: ${gribdir}${grib3dpl_file} and ${gribdir}${grib2dpl_file} .........."

    # Here request the ERA data first, and then convert to ARL
    echo '-------------------------------------'
    echo "RETRIEVING ERA5: year $year month $month day $day"
    # retrieves pressure level files
    # Note that in Python = A number with a leading zero is interpreted as octal literal. So 8 and 9 are invalid in octal. Only digits 0 to 7 are valid.
    # So I have to remove the leading zeros
    zday=$((10#$day))
    zmonth=$((10#$month))
    # echo $zday
    # echo $zmonth
    $pythoncall ${PDL}/get_era5_cds.py  --3d   -y $year -m $zmonth  -d $zday --dir $gribdir  -g  --area $area

    # retrieves surface data files with all variables
    $pythoncall ${PDL}/get_era5_cds.py  --2da  -y $year -m $zmonth  -d $zday --dir $gribdir  -g  --area $area
    # Move the file to something useful for ARL conversion
    mv new_era52arl.cfg era52arl.cfg
    /usr/bin/rm -f ${gribdir}${year}${monthname}_ecm2arl.sh

    echo '-------------------------------------'
    echo "GENERATING ARL: year $year month $month day $day"
    /usr/bin/ln -s ${gribdir}${grib3dpl_file} ./
    /usr/bin/ln -s ${gribdir}${grib2dpl_file} ./
    # echo $MDL/era52arl -i${gribdir}${grib3dpl_file} -a${gribdir}${grib2dpl_file}
    $MDL/era52arl -i${grib3dpl_file} -a${grib2dpl_file}
    mv DATA.ARL ${arldata}
    /usr/bin/rm -f ${grib3dpl_file}
    /usr/bin/rm -f ${grib2dpl_file}
    echo 'DONE ---------------------------------------------------------------------------------'
  fi
fi

exit

# for month in $2
# do
#      # for day  in   $(seq 1  31)
#      for day  in  $3
#      do
#               echo "RETRIEVING  month $month day $day"
#               # retrieves pressure level files
#               $MDL ${PDL}/get_era5_cds.py  --3d   -y $year -m $month  -d $day --dir $gribdir  -g  --area $area
#               # retrieves surface data files with all variables
#               $MDL ${PDL}/get_era5_cds.py  --2da  -y $year -m $month  -d $day --dir $gribdir  -g  --area $area
#      done
# done
#
# # use the cfg file created for the conversion.
# mv new_era52arl.cfg era52arl.cfg
#
# #-----------------------------------------
# # convert data to ARL format
#
# # In practice you may want to run the following
# # in a separate script, after you have confirmed that
# # all the data downloaded properly.
# #-----------------------------------------
#
# for month in $2
# do
#      # for day  in  {01..31}
#      for day  in  $3
#      do
#        echo '---------------------------------------------------------------------------------'
#        echo $MDL/era52arl -i${gribdir}ERA5_$year.${monthname}${day}.3dplgrib -a${gribdir}ERA5_${year}.${monthname}${day}.2dpl.all.grib
#        $MDL/era52arl -i${gribdir}ERA5_$year.${monthname}${day}.3dplgrib -a${gribdir}ERA5_${year}.${monthname}${day}.2dpl.all.grib
#        mv DATA.ARL ${arldir}ERA5_${year}${month}${day}.ARL
#        echo 'DONE ---------------------------------------------------------------------------------'
#      done
# done
