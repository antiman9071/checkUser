checkUser.sh [-f] [-a] [-g] [-m] [-p] [-s] [-u]

The check user script is built to check authorized users and remove unauthorized users. It is built to be self-explanatory; all you need to do is follow the prompts. [] means that it is optional.

All options are interchangeable; this is just the order I put them in the code.
-s: Checks against the defaultServices.txt file to flag potentially unwanted services.

-u: Runs the distro's update command (currently, it is only apt-based systems). however, does send to background type jobs to check

-f: Starts the firewall on Ubuntu systems.

-a: Adds multiple users to the computer and can add the users to an already existing group.

-g: Adds multiple users to a group and can create new groups.

-m: Finds all video and audio files in the home directory.

-p: Allows you to change the password of a user. It will not check a user's password; however, it will set password rules.

