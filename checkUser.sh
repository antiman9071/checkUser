#! /bin/bash
# the help option, if this code is called no other part of the code will run this is by design
#set -x
if [[ "$1" == "help" ]];
  then
    echo "checkUser.sh [-f] [-a] [-g] [-m] [-p] [-s] [-u]"
    echo ""
    echo "the check user script is built to check authorized users and remove unauthorized users. It is built to be self explanatory all you need to do is follow the prompts. [] means that it is optional"
    echo ""
    echo "all options are interchangeable this is just the order I put them in the code"
    echo ""
    echo "-f starts the firewall on ubuntu systems"
    echo ""
    echo "-a adds multiple users to the computer and can add the users to a already existing group"
    echo ""
    echo "-g adds multiple users to a group and can create new groups"
    echo ""
    echo "-m finds all video and audio files in the home directory"
    echo ""
    echo "-p allows you to change the password of a user, it will not check a users password however it will set password rules"
    echo ""
    echo "-s checks against the defaultServices.txt file to flag potentially unwanted services"
    echo ""
    echo "-u runs the distro's update command (currently it is only apt based systems)"
    exit 0;
  else
  AuthUsers=()
  AuthAdms=()
  users=()
    while getopts ":s :u :f :a :g :m :p" opt; do
    case $opt in
    s)
    	read -p "which ubuntu version(16 or 22)" ubuver
    	sudo service --status-all > Services.txt
     	echo "services listed are flagged as they are different from the current list if they are normal please add a new list"
     	if[[ $ubuver == 16 ]]; then
      		diff Services.txt ./checkUser/defaultServices(UBU16).txt
	else
 		cat Services.txt
   		#diff Services.txt ./checkUser/defaultServices(UBU22).txt
  	fi
      	echo "please remove the services file when completed"
       read -p "finished? hit enter"
       rm Services.txt
       ;;
    #for the update option
    u)

    if [[ $(uname -r) == *"fc"* ]]; then
        sudo dnf update
      else if [[ $(uname -r) == *"generic"* ]]; then
        software-properties-gtk --open-tab=2
        touch update.out update1.out && sudo nohup apt update>update.out 2>&1 && sudo nohup apt full-upgrade -y>update1.out 2>&1&& echo "update complete"&
      else
        sudo pamac update
      fi
    fi
    #echo "PLEASE REMEMBER TO ADD AUTO UPDATE TO INCREASE SECURITY"

    ;;
    #for firewall option
    f)
    sleep 0.05s
      #this section was added from a chris titus tech viceo/script
        read -p "is there a service you would like to add if so type the service if not type 0" $addedserver
        sudo ufw allow "$addedserver"
        sudo ufw limit 22/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
      #end of inspired section
        sudo ufw enable
        status=$(sudo ufw status)
        if [ "$status" == "running" ]; then
            echo "firewall enabled successfully"
        else
            echo "Error: Firewall not enabled"
        fi
    ;;
    a)
    #for the adduser option
    sleep 0.05s
    read -p "how many users to add " AddUserVer
    for ((i=0;i<AddUserVer;i++)); do
      read -p "name of the user " UserAdd
      AuthUsers+=($UserAdd)
      read -p "groups this user is a part of (if none put 0) " NewUserGroup

        if [ ! $NewUserGroup = "0" ]; then
          GroupExist=$(cat /etc/group|grep "$NewUserGroup")
          if [[ $NewUserGroup == "wheel" || $NewUserGroup == "sudo"|| $NewUserGroup == "adm" ]]; then
            AuthAdms+=($UserAdd)
          fi
          if [ -n GroupExist ]; then
          sudo useradd "$UserAdd"
          sudo gpasswd -a $UserAdd $NewUserGroup
          else
          sudo groupadd "$NewUserGroup"
          sudo useradd "$UserAdd"
          sudo gpasswd -a $UserAdd $NewUserGroup
          fi
        else
          sudo useradd $UserAdd
        fi
      done
    ;;
  #for the addgroup option
    a)
    sleep 0.05s
    read -p "what is the name of the group you need to add " group
    read -p "how many people do you need to add " numUsersforGroup
      if grep -q "^$group:" /etc/group; then
        echo ""
      else
        # Create the group if it doesn't exist
        sudo groupadd "$group"
      fi
    for ((i=0;i<numUsersforGroup;i++));
    do
    read -p "who is the user to add " userAdd
    sudo gpasswd -a $userAdd $group
    done
    ;;

    m)
    sleep 0.05s
      sudo find /home -name *.mp3
      sudo find /home -name *.mp4
      sudo find /home -name *.oss
      read -p "finished? hit enter"
    ;;
    p) #add the abillity to edit the login.defs file just in case
    sleep 0.05s
      read -p "would you like to add basic password rules y/n (please put only the letter also dont mind the man pages) " yon
      if [[ "$yon" != "n" || "$yon" != "n" ]]; then
        tally2orfaillock="pam_tally2.so"
        sudo which tally2
        if [ $? != 0 ]; then
            sudo which faillock
            if [ $? != 0 ]; then
                echo "please install either pam_faillock or pam_tally2"
                exit=1
            else
                tally2orfaillock="pam_faillock.so"
            fi
        fi
        read -p "what would you like as the password threshold " denynumber
        read -p "how long would you like to lock the person out of the system in secs " unlocktime
        read -p "how many days until users can change their passwords " passmindays
        read -p "how many days until users have to change their password " passmaxdays
        read -p "how many days before they are required to change their password will they be notified " passwarnage
        echo "auth  required  $tally2orfaillock  deny=$denynumber  unlock_time=$unlocktime" > ./common-auth-edit
        cp /etc/pam.d/common-auth ./common-auth-backup
        cat /etc/pam.d/common-auth >> ./common-auth-edit
        cp /etc/pam.d/common-account ./common-account-backup
        echo "account required  $tally2orfaillock" > ./common-account-edit
        cat /etc/pam.d/common-account >> ./common-account-edit
        read -p "what is the minimum password length " minlen
        read -p "how many passwords should be remembered " remember
        cp /etc/pam.d/common-password ./common-password-edit
        cp /etc/pam.d/common-password ./common-password-backup
        while read -r line; do
          if [ "$(echo "$line" | grep "^password" | grep -v "deny.so$" | grep -v "permit.so$")" ]; then
            echo "$line minlen=$minlen remember=$remember"
          else
            echo "$line"
          fi
        done </etc/pam.d/common-password>./common-password-edit
        printf "Common Password\n"
        cat ./common-password-edit
        printf "\n Common Auth\n"
        cat ./common-auth-edit
        printf "\n Common Account\n"
        cat ./common-account-edit
        printf "\n login.defs file\n"
        cp /etc/login.defs ./login.defs-edit
        cp /etc/login.defs ./login.defs-backup
        while read -r line; do
          if [[ "$line" =~ ^PASS_MAX_DAYS ]]; then
            echo "PASS_MAX_DAYS    $passmaxdays"
          elif [[ "$line" =~ ^PASS_MIN_DAYS ]]; then
            echo "PASS_MIN_DAYS    $passmindays"
          elif [[ "$line" =~ ^PASS_WARN_AGE ]]; then
            echo "PASS_WARN_AGE    $passwarnage"
          else
            echo "$line"
          fi
        done </etc/login.defs > ./login.defs-edit
        cat ./login.defs-edit
        echo ""
        read -p "are these config files correct y/n " conifgyon
        echo "backups for all edited PAM files are in this directory"
        if [[ $configyon == n || $configyon == N ]]; then
          echo "please edit the files yourself or rerun code"
          rm ./common-password-edit ./common-auth-edit ./common-account-edit login.defs-edit
          else

	  sudo mv ./common-password-edit /etc/pam.d/common-password
          sudo mv ./common-auth-edit /etc/pam.d/common-auth
          sudo mv ./common-account-edit /etc/pam.d/common-account
          sudo rm ./common-password-edit ./common-auth-edit ./common-account-edit
        fi
      fi
      read -p "what is the user name of the person" user
      sudo passwd $user

    ;;


    esac
  done
  fi
  #this is the start of the script and is specfically for reading which users are authorized
  echo "the script may or may not check services remember to check them"


  read -p 'How Many Users without admin users ' numUsers
  read -p 'How many admin users ' numAdms
  echo 'users'
  for ((i=0;i<numUsers;i++))
  do
      read ver
      AuthUsers+=($ver)
	[ -z "$(cat /etc/passwd|grep -i "$ver")" ] && sudo useradd "$ver"||:

  done
  echo 'admins'
  for ((i=0;i<numAdms;i++))
  do
      read ver
      AuthAdms+=($ver)
      AuthUsers+=($ver)
      [ -z "$(cat /etc/passwd|grep -i "$ver")" ] && sudo useradd "$ver"||:
      [ -z "$(getent group sudo|grep -i "$ver")" ] && sudo gpasswd -a "$ver" sudo||:
  done


  # This script checks the users and administrators on a Linux system.

  # Get the list of users.
  # Read each line in the file
  while read -r line; do
    # Extract the user ID from the line
    uid=$(echo $line | cut -d\: -f3)

    # Check if the user ID is greater than 1000
    if (($uid>=1000 && $uid<65534)); then
      # Print the line if the user ID is greater than 1000
      uid=$(getent passwd $uid | cut -d\: -f1)

      users+=("$uid")
    fi
  done < /etc/passwd
  usersAmt=${#users[@]}
  adminsAmt=${#AuthAdms[@]}
  # Check for administrators.
  for ((i=0;i<usersAmt;i++)); do

      [ -z "$(sudo -lU ${users[i]}|grep -i "sudo")" ] && admins+=(${users[i]})||trueUsers+=(${users[i]})
  done
  # Print the list of users.
  echo "List of users:"
  usersAmt=${#trueUsers[@]}
  for ((i=0;i<usersAmt;i++));
  do
      echo -e "${trueUsers[i]}"
  done
  echo ""

  if [ -n "$admins" ]; then
    # Print the list of administrators.
    echo "List of administrators:"
      for ((i=0;i<adminsAmt;i++));
      do
          echo -e "${admins[i]}"
      done
  else
    # No administrators were found.
    echo "No administrators were found."
  fi
  echo ""

  AuthUsersAmt=${#AuthUsers[@]}
  AuthAdminsAmt=${#AuthAdms[@]}
  flaggedAdms=($(echo ${admins[@]} ${AuthAdms[@]}|tr ' ' '\n' | sort | uniq -u))
  flaggedUsers=($(echo ${users[@]} ${AuthUsers[@]}|tr ' ' '\n' | sort | uniq -u))

  echo "flagged users:"
  flaggedUsersAmt=${#flaggedUsers[@]}
  for ((i=0;i<flaggedUsersAmt;i++));
  do
      echo -e "${flaggedUsers[i]}"
  done
  echo ""
  echo "flagged admins"
  flaggedAdmsAmt=${#flaggedAdms[@]}
  for ((i=0;i<flaggedAdmsAmt;i++));
  do
      echo -e "${flaggedAdms[i]}"
  done
  #this is the part that removes the users and user permissions
  read -i "yes" -p "would you like to remove permissions and delete these users y/n " remPermYN
  if [[ "$remPermYN" = "N" || "$remPermYN" = "No" || "$remPermYN" = "n" || "$remPermYN" = "no" ]]; then
    echo "done"
  else
    [ -z "$(cat /etc/group |grep -i "wheel")" ] && OS=n||OS=y
    if [ $OS = "n" ]; then
      for ((i=0;i<flaggedAdmsAmt;i++)); do
        sudo gpasswd -d ${flaggedAdms[i]} sudo
      done
      for ((i=0;i<flaggedUsersAmt;i++)); do
        sudo userdel -r ${flaggedUsers[i]}
      done

    else
      for ((i=0;i<flaggedAdmsAmt;i++)); do
        sudo gpasswd -d ${flaggedAdms[i]} wheel
      done
      for ((i=0;i<flaggedUsersAmt;i++)); do
        sudo userdel -r ${flaggedUsers[i]}
      done
    fi
  fi
