# bash_profile
My spin on the .bash_profile to help with enumeration  
  
## Usage:  
    sudo git clone https://github.com/blindpentester/bash_profile
    cd bash_profile  
    cat bash_profile >> ~/.bash_profile  
    source ~/.bash_profile
  
  
## Things added:  
    * smb (SMB enumeration to run smbclient a few ways and and SMBMap)  
    * e4l (enum4linux-ng)  
    * pth (PassTheHash)  
    * mntsmb (mounting remote smb share)  
    * umountsmb  
    * mntntfs (mounting remote ntfs)  
    * umountntfs  
    * il (Interlace - added checks to make sure input is either domain name, ip address or a list, otherwise command fails)  
    
### Things to add/fix:  
- Going to be adding more enumeration shortkeys with argument options.  
