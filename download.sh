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
say "DEBUG: START OF download.sh."
say "Wecome to FlightGear Installer's Download script!"
source locations_definitions # Setings for download and install destinations.
say "INFO: Selecting FlightGear version $release"

check_git_exit_status()
{

    local git_exit_status="$?"
    if [ "$git_exit_status" = "1" ]; then
        say "ERROR: Something went wrong when downloading/updating '$component' from '$repo'."
        say "INFO: Please try again in a few minutes."
        exit 22
    elif [ "$git_exit_status" = "0" ]; then
        say "Downloading/Updating '$component' from '$repo' seems to have worked fine."
    else
        say "WARNING: Can't be sure if downloading '$component' from '$repo' worked or not. Continuing..."
        say "WARNING: git exit status was '$git_exit_status'"
    fi        
}

clone_component()
{
    git clone -j "$git_jobs" "$repo/$component" "$component_source_destination"
    cd "$component_source_destination"
    git checkout "$branch"
    check_git_exit_status
}

update_component()
{
    cd "$component_source_destination"
    git checkout "$branch"
    git pull -j "$git_jobs"
    check_git_exit_status
}

try_git()
{
    if [ -d "$component_source_destination" ]; then
        say "INFO: $component found at '$component_source_destination'. Checking for updates."
        update_component
    else
        say "WARNING: $component not downloaded."
        say "INFO: Downloading it from $repo using branch $branch."
        clone_component
    fi
}

do_git()
{
    if [ ! -d "$source_destination" ]; then
        say "Creating $source_destination."
        mkdir -p "$source_destination"
    fi

    say "INFO: Will download '${components[@]}'"

    for i in "${components[@]}"
    do
        component="$i"
        branch="${component}_branch"
        branch=$(eval "echo \"\$$branch\"")
        repo="${component}_repo"
        repo=$(eval "echo \"\$$repo\"")
        say "INFO: Checking $component."
        if [ "$component" = "fgdata" ]; then
            component_source_destination="$fgdata_destination"
            try_git
            unset component_source_destination
        elif [ ! "$component" = "fgdata" ]; then
            component_source_destination="$source_destination/$component"
            try_git
            unset component_source_destination
        else
            say "ERROR: Something went wrong on 'download.sh' at 'do_git'"
            say "INFO: component='$component'"
            exit 22
        fi
    done
}



do_git

say "All done. Hopefully. Rerun download.sh to try again."
say "DEBUG: END OF download.sh."

exit 0
