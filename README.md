# ShellBackup
## Config File to Set up MOUNTING_POINT
If your backup is to store files in a remote server, you can setup the mounting point (the folder the smb is mounted to). Then the script will check whether the server is connected before backup starts.

## Setup fstab to Mount without Interaction
```sh
echo "//<your_file_server>/share  /home/<your_username>/path/to/your/mounting_point  cifs  user,noauto,credentials=/home/<your_username>/.smbcredentials,uid=1000,gid=1000,iocharset=utf8 0 0" | sudo tee -a /etc/fstab
```
`//<your_file_server>/share ` is your file server smb share.
`user` will allow you to mount as yourself (no `sudo` needed)
>__important:__ `noauto` will make sure it won't mount during boot, without which your linux might not boot!!!
 
>__important:__ `credentials=/home/<your_username>/.smbcredentials` is a credential file for your own file server

```sh
# permission with 400 is recommended
chmod 400 /home/<your_username>/.smbcredentials
```

## Task.conf will have your Tasks to run:
FORMAT:
- NAME|PARENT_DIR|SOURCE_DIR
    - __NAME__: the Backup task name (up to you)
    - __PARENT_DIR__: where is the backup (including TARGET_DIR and changed Folder)
    - __SOURCE_DIR__: the folder of your backup source

e.g. `.config|$HOME/Desktop/smb/备份/ShellBackup|$HOME/.config/`

## exclude_list.txt to Exclude Items
