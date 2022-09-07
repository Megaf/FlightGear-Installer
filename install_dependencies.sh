#!/bin/bash
#
# FlightGear Installer
# download.sh
# This is the is a script that will download all required components.
#
# Author:       Megaf - https://github.com/Megaf - mmegaf [at] gmail [dot] com
# Date:         03/09/2022
# GitHub:       https://github.com/Megaf/FlightGear-Installer
# License:      GPL V3

source libsay # libsay, enables "say" command to print fancy messages.
say "DEBUG: START OF install_dependencies."

detect_os()
{
    local unames="$(uname -s)"
    #local unames=FreeBSDs
    
    if [ "$unames" = "Linux" ]; then
        echo "Linux" 
    elif [ "$unames" = "Darwin" ]; then
        echo "macOS"
    elif [ "$unames" = "FreeBSD" ]; then
        echo "FreeBSD"
    else
        echo "ERROR: Can't detect OS."
        exit 22
    fi
}

which_distro()
{
    if [ -f "/etc/debian_version" ]; then
        echo "Debian"
    elif [ -f "/etc/armbian-release" ]; then
        echo "Armbian"
    else
        echo "ERROR: Can't detect Distro."
        exit 22
    fi

}

install_dependencies()
{
    if [ "$(detect_os)" = "Linux" ]; then
        install_dependencies_linux
    elif [ "$(detect_os)" = "macOS" ]; then
        say "ERROR: macOS is not supported yet."
    elif [ "$(detect_os)" = "FreeBSD" ]; then
        say "ERROR: FreeBSD is not supported yet."
    else
        say "ERROR: Can't detect the OS running on this system."
        say "DEBUG: END OF install_dependencies.sh"
        exit 22
    fi
}

install_dependencies_linux()
{
    if [ "$(which_distro)" = "Debian" ]; then
        install_debian_dependencies
    fi
}

install_debian_dependencies()
{
    say "INFO: A Debian based distro was detected."
    say "Trying to use 'apt' to install dependencies."

    local debian_dependencies=(
    libopenal-dev
    libfreetype-dev
    libjpeg-dev
    libpng-dev
    libtiff-dev
    libxmu-dev
    libxi-dev
    zlib1g-dev
    libgstreamer1.0-dev
    libqt5gstreamer-dev
    )

    sudo apt install -y ${debian_dependencies[@]}
}


install_dependencies

# TODO: Complete list of Debian dependencies.
# TODO: Add dection of other OSes and Distros.

say "DEBUG: END OF install_dependencies.sh"

exit 0

