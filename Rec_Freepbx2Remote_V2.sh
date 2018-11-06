#!/bin/bash
RELEASE="Version 2"
PROGNAME="freepbxr2c"

#set -x

### Extension Lists - Seperate each extensions with comma"s
extension_lists="4100,1604"


## All Variabled Defined here
client_name="test_client"
current_year=$(date +"%Y")
freepbx_rec_dir="/var/spool/asterisk/monitor"
extension_folder="/scripts/ext_lists/"
extension_file="/scripts/ext_lists/ext_$client_name"

database_name="database_name"
database_user="database_user"
database_password="database_password"
db_time_interval_in_minutes="db_time_interval_in_minutes"

remote_server="destination_ip"
remote_user="user"
remote_ssh_port="22"
remote_location="location"

email_address="client_email_address"

check_dir()
{
    if [ ! -d $freepbx_rec_dir ]
        then
            echo "Exiting Script.... Missing $freepbx_rec_dir. Make sure it exists and having enough recordings"
            exit 2
    fi
}

check_db_connect()
{
    db_connect=$(mysql -u $database_user -p$database_password -e "use $database_name";echo "$?")
    if [ $db_connect != 0  ]
        then
            echo "Exiting Script.... Mysql can't connect to the database $database_name"
            exit 2
    fi
}

check_dir
check_db_connect

if [ -f $extension_file ]
    then
        echo $extension_lists > /tmp/junk_lists
        tr , '\n' < /tmp/junk_lists > $extension_file
    else
        mkdir -p $extension_folder;touch $extension_file
        echo $extension_lists > /tmp/junk_lists
        tr , '\n' < /tmp/junk_lists > $extension_file
fi

process_remote_copy()
{
    for i in `cat $extension_file`
        do
            echo $freepbx_rec_dir/$current_year/ -name *-$i-*.wav -exec rsync -av -R {} $remote_user@$remote_server:$remote_location \;
#            find $freepbx_rec_dir/$current_year/$NARGS2/$NARGS1/ -name *-$extension-*.wav -exec rsync -av -R {} $remoteuser@$remoteserver:$remotelocation \;
    done
}

out_check=$( mysql -u $database_user -p$database_password -e "select calldate AS Timestamp, src AS Source, dst AS Destination, duration AS Duration, disposition AS Status from cdr where calldate > NOW() - INTERVAL $db_time_interval_in_minutes MINUTE AND disposition in ('ANSWERED') and src in ($extension_lists)\G;" -H $database_name)

in_check=$( mysql -u $database_user -p$database_password -e "select calldate AS Timestamp, src AS Source, dst AS Destination, duration AS Duration, disposition AS Status from cdr where calldate > NOW() - INTERVAL $db_time_interval_in_minutes MINUTE AND disposition in ('ANSWERED') and dst in ($extension_lists)\G;" -H $database_name)


if [ -z "$out_check" ] && [ -z "$in_check" ]
    then
        echo "No available recordings within this time interval : $db_time_interval_in_minutes minutes "
    else
        process_remote_copy
fi