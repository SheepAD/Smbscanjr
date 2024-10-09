#!/bin/bash

Help()
{
   echo -e "\n\n \e[1;32m ###########################################"
   echo -e "\e[1;32m ############################################\n"
   echo -e "\e[1;32m [!] Modo de uso: \"./smbscanjr <Target_Ip>\""
   echo -e "\n \e[1;32m <h|help> Display this Help panel"
   echo -e "\n \e[1;32m ########################################## \e[0m"
   echo -e "\e[1;32m ##########################################\n"
}

while getopts ":h" option; do
   case $option in
      h) Help
         exit;;
   esac
done

ip=$1
if [ -z $ip ]; then
  Help
else

        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                smbclient -L //$ip -N > smb.txt 2>/dev/null
                sleep 2
                shares=$(cat smb.txt | awk '{print $1}' | grep -vE 'Sharename|---------|Reconnecting|Unable' | xargs | tr " " ",")
                ult_shares=$(echo $shares | sed -E 's/([^,]+)/"\1"/g' | tr "," " ")
                ult_shares=$(echo "$ult_shares" | tr "\"\"" " ")
                array=($ult_shares)
                rm smb.txt
for i in ${array[@]}; do
                  echo -e "\n[-] Leyendo Shares para $i..."
                  smbclient //$ip/$i -N -c "dir" 2>/dev/null
                  ss=$(echo $?)
                  sleep 2
                  if [ $ss -eq 0 ]; then
                    echo -e "\n \e[33m [+] El share \e[32m $i \e[33m tiene permiso de lectura! \e[0m"
                  fi
                done
        else
          Help
        fi
fi
