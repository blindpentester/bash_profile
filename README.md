# bash_profile
My spin on the .bash_profile to help with enumeration  
  
## Usage:  
    sudo git clone https://github.com/blindpentester/bash_profile
    cd bash_profile  
    cat bash_profile >> ~/.zsh_profile  
    source ~/.zsh_profile  
    echo "source ~/.zsh_profile" >> ~/.zshrc
  
  
## Things added:  
* smb (SMB enumeration to run smbclient a few ways and and SMBMap)  
* e4l (enum4linux-ng)  
* pth (PassTheHash)  
* mntsmb (mounting remote smb share)  
* umountsmb  
* mntntfs (mounting remote ntfs)  
* umountntfs  
* il (Interlace - added checks to make sure input is either domain name, ip address or a list, otherwise command fails)  
* instashell (instashell is included in the-essentials repo)  
* asn (asnlookup runs from /opt subfolder)  
* autoenum (cd's into dir and runs from there since dependencies are not full path)  
* spoofcheck (runs from /opt subfolder)  
* sherlock (runs from /opt subfolder)  
* dnsdumpster (runs from /opt subfolder)  
* bloodhnd (lauches another terminal window for neo4j and starts bloodhound)  
* phprev (phprev <port> generates its own php-reverse-shell.php to use tun0 and port specified and outputs to whatever directory you are currently in)
* ciphey added.
  * since ciphey does not like the python i use, i am having this run through docker.  it ony captures and uses the second input put in, so it should not beother with the flags you are attempting to use.
* ipinfo  
  * type "ipinfo" for command help
    
    
### Things to add/fix:  
- Going to be adding more enumeration shortkeys with argument options.  
