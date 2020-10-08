certprobe(){ #runs httprobe on all the hosts from certspotter
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe | tee -a ./all.txt
}

crtsh(){
curl -s https://crt.sh/?Identity=%.$1 | grep ">*.$1" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$1" | sort -u | awk 'NF'
}

crtshdirsearch(){ #gets all domains from crtsh, runs httprobe and then dir bruteforcers
curl -s https://crt.sh/?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe -c 50 | grep https | xargs -n1 -I{} python3 /opt/dirsearch/dirsearch.py -u {} -e $2 -t 50 -b
}

certnmap(){
curl https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1  | nmap -T5 -Pn -sS -i - -$
}

am(){ #runs amass passively and saves to json
amass enum --passive -d $1 -json $1.json
jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

smb() {
# smb <host ip> <uname> <password>
if [ -z "$1" ]
then
  echo "Missing variable for host IP address."
  echo "Sytax should be: smb <host ip> <uname> <password>"
  sleep 5
else
  if [ "smbclient -L $1 | grep 'NT_STATUS_ACCESS_DENIED'" ]
  then
    echo "That did not work, maybe we need to try null user credentials..."
    smbclient -L \\\\$1 -U ''
  else
    if [ "smbclient -L $1 -U '' | grep 'NT_STATUS_LOGON_FAILURE'" ]
    then
      echo "Maybe you entered credentials, lets try those..."
      smbclient -L $1 -U "$2"
    else
      if [ "smbclient -L $1 -U "$2" | grep 'NT_STATUS_LOGON_FAILURE'" ]
      then
        echo "Lets do some SMBMapping..."
        smbmap -H $1
      else
        if [ "smbmap -H $1 | grep 'Authentication error'" ]
        then
          echo "SMBMap with creds if they were applied..."
          smbmap -H $1 -u "$2" -p "$3"
        fi
      fi
    fi
  fi
fi
  }

e4l() {
# Enum4Linux-ng to run and create folder on dekstop and output found items there.
# e4l <ip addy> <uname> <password>
  cd /opt/enum4linux-ng
  mkdir -p ~/Desktop/enum4linux
  python3 enum4linux-ng.py $1 -u "$2" -p "$3" -oY ~/Desktop/enum4linux/$1-output.txt
}

pth() {
# Pass The Hash: pth <username> <password hash> <host ip>
  smbmap -u "$1" -p "$2" -H $3
}

mntsmb() {
# Quick way to mount an SMB Share
if [ -z "$1" ]
then
 echo "You are missing a variable for host IP address."
 echo "Please use syntax: mntntfs <ip addr> <share>"
else
  sudo mount -t cifs "//$1/$2" /mnt
fi
}

umountsmb() {
# Unmount SMB
  sudo umount /mnt
}


mntntfs() {
# mntfs <ip addy> <share> <uname> <pass>
if [ -z "$1" ]
then
    echo "You are missing a variable for host IP address."
    echo "Please use syntax: mntntfs <ip addr> <share> <username> <password>"
  else
  sudo mkdir -p /mnt/ntfs
  sudo mount -t cifs //$1/$2 -o username=$3,password=$4 /mnt/ntfs
fi

}

umountntfs() {
# Unmount NTFS
  sudo umount /mnt/ntfs
}

il() {
#
# syntax: il <ip / target list name> <command list>
if [ -z "$1" ]
then
  echo "Sorry, target must be selected."
  echo "Usage: il <ip> <command list>"
  echo "       il <domain name> <command list>"
  echo "       il <targets list> <command list>"
  else
    if [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
    then
      echo "$1" > /tmp/hosts.txt
      sudo interlace -tL /tmp/hosts.txt -cL $2
      else
        host $1 >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
          echo "Domain validated.."
          sudo interlace -t $1 -cL $2
          else
            cat $1 >/dev/null 2>&1
            if [ $? -eq 0 ]
            then
              echo "Using Tartets Text File..."
              sudo interlace -tL $1 -cL $2
              else
                echo "You must be confused.  Target needs a list, ip or host name.  Try again"
      fi
    fi
  fi
fi
}
