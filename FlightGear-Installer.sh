#!/bin/bash
#
# FlightGear Installer
# FlightGear-Installer.sh
#
# This is the main script from the installer. It will in sequence:
# Check the running OS and try to install the required dependencies.
# Download the source code for FlightGear, SimGear, OpenSceneGraph and PLIB.
# Compile those source codes.
# Optionally, it can download fgdata as well.
#
# Through setting the flag 'remove_fg', it will install FlightGear builds that
# were installed with this script.
#
# Author:       Megaf - https://github.com/Megaf - mmegaf [at] gmail [dot] com
# Date:         03/09/2022
# GitHub:       https://github.com/Megaf/FlightGear-Installer
# License:      GPL V3

source libsay # libsay, enables "say" command to print fancy messages.
say "INFO: This is $0."

say "DEBUG: START OF FlightGear-Installer.sh'."
[[ "$*" == *"--download"* ]] && [[ ! "$*" == *"--fgdata"* ]] && echo "selected download and no fgdata" 
[[ "$*" == *"--download"* ]] && [[ "$*" == *"--fgdata"* ]] && echo "selected download and fgdata" 
[[ ! "$*" == *"--download"* ]] && [[ "$*" == *"--fgdata"* ]] && echo "selected fgdata"
[[ "$*" == *"--compile"* ]] && echo "selected compile"

quit()
{
    say "WARNING: Exiting"
    exit 0
}

print_options()
{
    clear
    say "Welcome to FlightGear Installer!"
    say "What would you like to do today?"
    say "INFO: Your options are:"
    echo "Type '0' To download the source code for PLIB, OSG, SG and FG and then compile FlightGear." 
    echo "Type '1' To download the source code for PLIB, OSG, SG and FG and then exit."
    echo "Type '2' To compile FlighGear and it's dependencies."
    echo "Type '3' To download PLIB, OSG, SG, FG and FGData."
    echo "Type '4' To download FGData only."
    echo "Type '5' To remove FlightGear previously installed with this Installer from your system."
    echo "Type '6' To exit FlightGear Installer."
}

command_line_options()
{
    print_options
    say "INFO: Use './FlightGearInstaller.sh -'number' for your choice."
    say "'1', '2', '3', '4', '5'"
    exit 0
}

read_choice()
{
    local range="0-5"
    say "Type your option or 'Ctrl C' to Quit." && read -n 1 option; printf "\n"
    say "INFO: Option chose was $option."
    say "Would you like to to Download/Compile FlightGear Next/Nightly or Stable?"
    say "Type 's' for Stable or 'n' for Next/Nightly."
    say "Type your option or 'Ctrl C' to Quit." && read -n 1 option2; printf "\n"
    say "INFO: Option chose was $option2."
    if [ "$option2" = "s" ]; then
        local fg_args="--stable"
    elif [ "$option2" = "n" ]; then
        local fg_args="--next"
    elif [ "$option2" = "q" ]; then
        quit
    else
        say "Please chose only 's' for Stable or 'n' for Next/Nightly."
        clear
        print_options
        read_choice 
    fi

    if [[ "$option" =~ ^["$range"]+$ ]] || [ "$option2" = "q" ]; then
        [ "$option" = "0" ] && unset option && ./download.sh $fg_args && ./compile.sh $fg_args
        [ "$option" = "1" ] && unset option && ./download.sh $fg_args 
        [ "$option" = "2" ] && unset option && ./compile.sh $fg_args
        [ "$option" = "3" ] && unset option && ./download.sh --all $fg_args
        [ "$option" = "4" ] && unset option && echo "You pressed $option and $option2"
        [ "$option" = "5" ] && unset option && echo "You pressed 5" && quit
        [ "$option" = "q" ] && unset option && echo "You pressed q" && quit
    else
        say "ERROR: Please only use numbers between '[$range]'."
        unset option
        clear
        print_options
        read_choice
    fi
    
    exit 0
    
}

option="$*"
[ ! "$option" ] && print_options && read_choice
[ "$option" ] && say "Your choice is: $option"

say "DEBUG: END OF FlightGear-Installer.sh'."

