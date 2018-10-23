#!/bin/bash
RELEASE="Version 1"
AUTHOR="sujithar37@gmail.com"
PROGNAME="freepbxr2c"

#set -x
### Variables defined here
freepbx_rec_dir='/var/spool/asterisk/monitor'
NARGS=$#
NARGS1=$1
NARGS2=$2
NARGS3=$3
current_year=$(date +"%Y")

fetch_year()
{
    if [ $NARGS == 3  ]
        then
            year="$NARGS3"
        else
            year="$current_year"
    fi
}

arg_passed()
{
    if [ $NARGS -ne 3 ] && [ $NARGS -ne 2 ]
        then
            echo "exiting script... try to execute in the format as 'freepbxr2c.sh {date} {month} {year}' [ Eg: 17th july 2018 - freepbxr2c.sh 17 07 2018 ]"
            exit 1
        elif ([ $NARGS1 -le 31 ] && [ $NARGS2 -le 12 ]) || ([ $NARGS1 -le 31 ] && [ $NARGS2 -le 12 ] && [ $NARGS3 -eq fetch_year ])
            then
                echo "date:$NARGS1, month:$NARGS2, year:$year"
            else
                echo "exiting script... parsing argument details failed, try to execute in the format as 'freepbxr2c.sh {date} {month} {year}' [ Eg: 17th july 2018 - freepbxr2c.sh 17 07 2018 ]"
                exit 1
    fi
}

monitor_dir_exist()
{
    ls $freepbx_rec_dir/$year/$NARGS2/$NARGS1
    if [ $? != 0 ]
        then
            echo "exiting script...since "$freepbx_rec_dir/$year/$NARGS2/$NARGS1" isn't exist"
            exit 1
    fi
}


filter_recording_number()
{
    if [ -z $extension ] && [ -z $remoteuser ] && [ -z $remoteserver ] && [ -z $remotelocation ]
        then
            echo "exiting script... parsing User Input details failed"
            exit 1
        else
            echo "$freepbx_rec_dir/$year/$NARGS2/$NARGS1/ -name *-$extension-*.wav -exec rsync -av -R {} $remoteuser@$remoteserver:$remotelocation \;"
#            find $freepbx_rec_dir/$current_year/$NARGS2/$NARGS1/ -name *-$extension-*.wav -exec rsync -av -R {} $remoteuser@$remoteserver:$remotelocation \;
    fi
}

fetch_year
arg_passed
monitor_dir_exist

echo "Are you looking for copying recording files to remote destination? [ y/n ]"
read answer
if [ $answer == y ] || [ $answer == Y ] || [ $answer == yes ] || [ $answer == YES ]
    then
        echo "User input is required to proceed further"
        echo "Provide the recording number:"
        read extension
        echo "Provide the remote ssh user name:"
        read remoteuser
        echo "Provide the remote ssh server ip address:"
        read remoteserver
        echo "Provide the remote location:"
        read remotelocation
        filter_recording_number
    else
        echo "exiting script... this script currently supports copying files to remote destination only"
        exit 1
fi