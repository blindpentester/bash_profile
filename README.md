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
    * il (Interlace)  
    
### Things to add/fix:  
- Going to be adding more enumeration shortkeys with argument options.  
- Better methods for determining what type of input has been provided.
