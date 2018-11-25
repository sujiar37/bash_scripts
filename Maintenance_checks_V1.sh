#!/bin/bash
#set -x

hdd_usage()
{
    if [ -z "$ARGS2" ]
      then
         echo "please specify the argument format using space : hdd hard_disk_name threshold_value"
         exit 1
      else
         hdd_stat=$(df -h | grep /dev/$ARGS2 | awk '{print $5}' |cut -d '%' -f1)

         if [ "$hdd_stat" -ge "$ARGS3" ]
            then
              echo "threshold value reached"
              exit 1
            else
               echo "looks ok"
               exit 0
         fi
    fi
}

cpu_usage()
{
    if [ -z "$ARGS2" ]
      then
         echo "please specify the argument format using space : cpu threshold_value"
         exit 1
      else
         cpu_stat=$(w | grep "load\saverage" | awk '{print $11}' | cut -d ',' -f1 | cut -c1)

         if [ "$cpu_stat" -ge "$ARGS2" ]
            then
              echo "threshold value reached"
              exit 1
            else
               echo "looks ok"
               exit 0
         fi
    fi
}

ram_usage()
{
    if [ -z "$ARGS2" ]
      then
         echo "please specify the argument format using space : ram threshold_value"
         exit 1
      else
         ram_stat=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -c1)

         if [ "$ram_stat" -ge "$ARGS2" ]
            then
              echo "threshold value reached"
              exit 1
            else
               echo "looks ok"
               exit 0
         fi
    fi
}

sip_peers_status()
{
    if [ -z "$ARGSALL" ]
      then
         echo "please specify the argument format using space : sip_peers sip1 sip2 sip3 etc..."
         exit 1
      else
         for sip in $ARGSALL
           do
             sip_status=$(asterisk -rx "sip show peer $sip" | grep Status | awk '{print $3}')
             if [ "$sip_status" == "OK" ]
               then
                  echo "looks ok"
               else
                 if [ "$sip_status" == "UNKNOWN" ] || [ "$sip_status" == "UNREACHABLE" ]
                   then
                     echo "$sip:$sip_status"
                   else
                     echo "$sip: Not Found"
                 fi
             fi
          done
    fi
}

sip_registry_status()
{
    if [ -z "$ARGSALL" ]
      then
         echo "please specify the argument format using space : sip_registry sip1 sip2 sip3 etc..."
         exit 1
      else
         for sip in $ARGSALL
           do
             sip_status=$(asterisk -rx "sip show registry" | grep $sip | awk '{print $5}')
             if [ "$sip_status" == "Registered" ]
               then
                  echo "looks ok"
               else
                 if [ "$sip_status" == "Auth." ]
                   then
                     echo "$sip:$sip_status"
                   else
                     echo "$sip: Not Found"
                 fi
             fi
          done
    fi
}

service_check()
{
    if [ -z "$ARGS2" ]
      then
         echo "please specify the argument format using space : scriptfile httpd / asterisk / mysql"
         exit 1
      else
         service_stat=$(service $ARGS2 status | grep active | awk '{print $2}')

         if [ "$service_stat" == "active" ]
            then
              echo "looks ok"
              exit 0
            else
               echo "Problem : $ARGS2 connection status is $service_stat"
               exit 1
         fi
    fi
}

print_usage()
{
   echo ""
   echo "This script can perform live checks related with HDD, RAM, CPU, SIP peers & registry, Apache, Mysql & aseterisk services and alert the users if the threshold value reached / having any issues"
   echo ""
   echo "Flags:"
   echo ""
   echo "NOTE : Threshold values are treated as percentage in total except CPU checks"
   echo "  Hard disk checks - Please pass the argument with the format using space : script_file hdd hard_disk_name threshold_value"
   echo "  CPU checks - Please pass the argument with the format using space : script_file cpu threshold_value"
   echo "  RAM usage checks - Please pass the argument with the format using space : script_file ram threshold_value"
   echo "  SIP peers checks - please specify the argument with the format using space : script_file sip_peers sip1 sip2 sip3 etc..."
   echo "  SIP registry checks - Please pass the argument with the format using space : script_file sip_registry sip1 sip2 sip3 etc..."
   echo "  ALL service checks [ httpd / mysql / asterisk ] - Please pass the argument as service name which needs to monitor : script_file service httpd / script_file service asterisk / script_file service mysql etc...."
   exit 0
}

print_help()
{
   clear
   echo ""
   echo "Maintenance Checks V1 - Sujith Abdul Rahim [ https://github.com/sujiar37 ]"
   print_usage
}

case $1 in
  hdd)
     ARGS2=$2
     ARGS3=$3
     hdd_usage
     ;;
  cpu)
     ARGS2=$2
     cpu_usage
     ;;
  ram)
     ARGS2=$2
     ram_usage
     ;;
  sip_peers)
     ARGSALL=${@:2}
     sip_peers_status
     ;;
  sip_registry)
     ARGSALL=${@:2}
     sip_registry_status
     ;;
  service)
     ARGS2=$2
     service_check
     ;;
  -h | --help)
     print_help
     ;;
  *)
     print_help
     ;;
esac