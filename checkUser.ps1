if ( $args[0] -eq "help" ) {
    Write-Host "checkUser.ps1 [a] [g] [m] [p] [s]"
    Write-Host ""
    Write-Host "the check user script is built to check authorized users and remove unauthorized users. It is built to be self explanatory all you need to do is follow the prompts. [] means that it is optional"
    Write-Host ""
    Write-Host "all options are interchangeable this is just the order I put them in the code"
    Write-Host ""
    Write-Host "a adds multiple users to the computer and can add the users to a already existing group"
    Write-Host ""
    Write-Host "g adds multiple users to a group and can create new groups"
    Write-Host ""
    Write-Host "m finds all video and audio files in the home directory"
    Write-Host ""
    Write-Host "p allows you to change the password of a user, it will not check a users password however it will set password rules"
    Write-Host ""
    Write-Host "s checks against the defaultServices.txt file to flag potentially unwanted services"
    Write-Host ""
    exit 0;
} else {


switch -casesensitive ($args[0],$args[1],$args[2],$args[3],$args[4]) {
"m" {
    Get-ChildItem -Path C:\Users -Recurse -File -Filter *.mp3
    Get-ChildItem -Path C:\Users -Recurse -File -Filter *.mp4
    Get-ChildItem -Path C:\Users -Recurse -File -Filter *.oss
    $null = Read-Host "finished? Hit Enter to continue"
}
"p" {
    $yon=Read-Host "do you need to change password policy"
    if ("$yon" -eq "y"){
    $PWlen = Read-Host "what is the minimum length"
    $PWage = Read-Host "what is the maximum password age in days"
    $PWageMin = Read-Host "what is the minimum time before you can change password in days"
    $UniquePW = Read-Host "how many passwords will be remembered in days"
    $LOthresh = Read-Host "what is the lockout threshold"
    $LOwindow = Read-Host "what is the lockout window in mins"
    $LOduration= Read-Host "what is the lockout duration in mins"
    net accounts /minpwlen:$PWlen
    net accounts /maxpwage:$PWage
    net accounts /minpwage:$PWageMin
    net accounts /uniqepw:$UniquePW
    net accounts /lockoutthreshold:$LOthresh
    net accounts /lockoutwindow:$LOwindow
    net accounts /lockoutduration:$LOduration
    }
    $yon=Read-Host "do you need to change a users password"
    if ("$yon" -eq "y"){
        $userPW = Read-Host "what user password do you need to change"
        net user $userPW password
    }
}
"a" {
    $amtOfUsers = Read-Host "how many users do you need to add"
    for ($i=$amtOfUsers; $i -ge 1; $i--) {
        $user = Read-Host "what user do you need to add"
        New-LocalUser $user
    }
    
}
"g" {
    $amtOfGroups = Read-Host "how many groups do you need to add"
    for ($i=$amtOfGroups; $i -ge 1; $i--) {
        $group = Read-Host "what group do you need to add"
        New-LocalGroup -Name $group
        $amtOfUsers = Read-Host "how many users do you need to add"
            for ($i=$amtOfUsers; $i -ge 1; $i--) {
                $user = Read-Host "what user do you need to add"
                net localgroup $group $user /add
            }
    }
    $yon = Read-Host "do you need to add users to an existing group"
    if ("$yon" -eq "y" ){
    $group = Read-Host "what group do you need to add users to"
    $amtOfUsers = Read-Host "how many users do you need to add"
            for ($i=$amtOfUsers; $i -ge 1; $i--) {
                $user = Read-Host "what user do you need to add"
                net localgroup $group $user /add
            }
        }
}
"s" {
    
}
}
}