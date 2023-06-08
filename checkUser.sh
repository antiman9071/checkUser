#! /bin/bash
# the help option, if this code is called no other part of the code will run this is by design
if [[ "$1" == "help" ]];
  then
    echo "checkUser.sh [firewall] [adduser] [addgroup] [update] [mediaFiles] [password]"
    echo ""
    echo "the check user script is built to check authorized users and remove unauthorized users. It is built to be self explanatory all you need to do is follow the prompts. [] means that it is optional"
    echo ""
    echo "all options are interchangeable this is just the order I put them in the code"
    echo ""
    echo "firewall starts the firewall on ubuntu systems"
    echo ""
    echo "adduser adds multiple users to the computer and can add the users to a already existing group"
    echo ""
    echo "addgroup adds multiple users to a group and can create new groups"
    echo ""
    echo "update runs the distro's update command (currently it is only apt based systems)"
    echo ""
    echo "mediaFiles finds all video and audio files in the home directory"
    echo ""
    echo "password alllows you to change the password of a user, it will not check a users password"
  else
  #this is the start of the script and is specfically for reading which users are authorized
  AuthUsers=()
  AuthAdms=()
  users=()
  read -p 'How Many Users without admin users ' numUsers
  read -p 'How many admin users ' numAdms
  echo 'users'
  for ((i=0;i<numUsers;i++))
  do
      read ver
      AuthUsers+=($ver)
  done
  echo 'admins'
  for ((i=0;i<numAdms;i++))
  do
      read ver
      AuthAdms+=($ver)
      AuthUsers+=($ver)
  done


  # This script checks the users and administrators on a Linux system.

  # Get the list of users.
  # Read each line in the file
  while read -r line; do
    # Extract the user ID from the line
    uid=$(echo "$line" | cut -d: -f3)

    # Check if the user ID is greater than 1000
    if (($uid>=1000 && $uid<2000)); then
      # Print the line if the user ID is greater than 1000
      uid=$(echo "$line" | cut -d: -f 1)
      users+=("$uid")
    fi
  done < /etc/passwd
  usersAmt=${#users[@]}

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
  adminsAmt=${#admins[@]}
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

  #for firewall option
  if [[ "$1" == "firewall" || "$2" == "firewall" || "$3" == "firewall" || "$4" == "firewall" || "$5" == "firewall" || "$6" == "firewall" ]];
  then
  #this section was added from a chris titus tech viceo/script
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
  fi
  #for the adduser option
  if [[ "$1" == "adduser" || "$2" == "adduser" || "$3" == "adduser" || "$4" == "adduser" || "$5" == "adduser" || "$6" == "adduser" ]];
  then
    read -p "how many users to add " AddUserVer
    for ((i=0;i<AddUserVer;i++)); do
      read -p "name of the user " UserAdd
      read -p "groups this user is a part of (if none put 0) " NewUserGroup

      if [ ! $NewUserGroup = "0" ]; then
          GroupExist=$(cat /etc/group|grep "$NewUserGroup")
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
  fi
  #for the addgroup option
  if [[ "$1" == "addgroup" || "$2" == "addgroup" || "$3" == "addgroup" || "$4" == "addgroup" || "$5" == "addgroup" || "$6" == "addgroup" ]];
  then
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
  fi
  #for the update option
  if [[ "$1" == "update" || "$2" == "update" || "$3" == "update" || "$4" == "update" || "$5" == "update" || "$6" == "update" ]];
  then
    if [[ $(uname -r) == *"fc"* ]]; then
      sudo dnf update
    else if [[ $(uname -r) == *"generic"* ]]; then
      sudo apt update && sudo apt full-upgrade
    else
    sudo pamac update
    fi
    fi
  echo "PLEASE REMEMBER TO ADD AUTO UPDATE TO INCREASE SECURITY"

  fi
  if [[ "$1" == "mediaFiles" || "$2" == "mediaFiles" || "$3" == "mediaFiles" || "$4" == "mediaFiles" || "$5" == "mediaFiles" || "$6" == "mediaFiles" ]];
  then
    sudo find /home -name *.mp3
    sudo find /home -name *.mp4
    sudo find /home -name *.oss
  fi
  if [[ "$1" == "password" || "$2" == "password" || "$3" == "password" || "$4" == "password" || "$5" == "password" || "$6" == "password" ]];
  then
    read -p "what is the user name of the person" user
    sudo passwd $user
  fi
  fi
