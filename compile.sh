#!/bin/bash
#
# FlightGear Installer
# compile.sh
# This is the script that will compile and install the required components.
#
# Author:       Megaf - https://github.com/Megaf - mmegaf [at] gmail [dot] com
# Date:         03/09/2022
# GitHub:       https://github.com/Megaf/FlightGear-Installer
# License:      GPL V3

source libsay # libsay, enables "say" command to print fancy messages.

say "DEBUG: START OF compile.sh."
source libisitinstalled # libisitinstalled, simple thing to check if something is installed.
source locations_definitions # Setings for download and install destinations.
source compiler_definitions # Settings and flags to be used by the compiler.

say "Welcome to FlightGear Installer!"
say "This is the compiler script."
say "INFO: To switch between branches:"
say "You can use '-f branch', '-o branch' and '-p branch' to switch branches."
say "'-f' for FlightGear, '-o' for OpenSceneGraph and '-p' for PLIB."
say "For example, to build FlightGear Nighlty use './compile.sh -f next'."

# Tries to find ccache and enable it if it is installed on the system.
findthing "ccache"; [[ "$isitinstalled" = "true" ]] && export PATH="/usr/lib/ccache/bin/:$PATH" && say "INFO: ccache was found."
say "DEBUG: PATH is set to $PATH"

say "INFO: Selecting FlightGear version $release"
say "Install destination is $install_destination."

[[ "$release" == "Next" ]] && say "WARNING: You are about to compile FlightGear Next. It may be UNSTABLE."

write_details()
{
    say "DEBUG: START OF 'write_details' function."

    local current_moment="$(date +'%d-%m-%Y_%H-%M-%S')"
    local details_file="$install_destination/install_details.txt"
    local git_info_file="$source_destination/$component/.git/FETCH_HEAD"
    local git_info="$(cat $git_info_file | head -n 1)"

    if [[ "$install_destination" == "/opt/"* ]] || [[ "$install_destination" = "/usr/"* ]]; then
        say "DEBUG: Installing to a system folder '$install_destination', 'sudo' is required."

        echo "Details for '$component'" | sudo tee -a "$details_file" > /dev/null
        echo "Build date: $current_moment" | sudo tee -a "$details_file" > /dev/null
        echo "$git_info" | sudo tee -a "$details_file" > /dev/null
        echo "##########" | sudo tee -a "$details_file" > /dev/null
 
    elif [[ "$install_destination" == *"$USER"* ]]; then
        say "DEBUG: Installing to user's home. 'sudo' and aliases are not required."
        echo "Details for '$component'" | tee -a "$details_file" > /dev/null
        echo "Build date: $current_moment" | tee -a "$details_file" > /dev/null
        echo "$git_info" | tee -a "$details_file" > /dev/null
        echo "##########" | tee -a "$details_file" > /dev/null

    else
        say "ERROR: Something went wrong when creating on 'write_datils' function."
    fi
    
    unset current_moment

    say "DEBUG: END OF 'write_details' function."
}

run_builds()
{
    say "DEBUG: START OF 'run_builds' function."
    for i in "${components[@]}"
    do
        component="$i"
        say "Trying to find $component's source code."
        if [ -d "$source_destination/$component"  ];
        then
            say "Source code for $component found at $source_destination/$component!"
            say "INFO: Configuring build for $component."
            [[ "$component" == "plib" ]] && build_plib
            [[ "$component" != "plib" ]] && build_with_cmake
        else
            say "ERROR: Couldn't find the source code for $component."
            say "INFO: Please run 'download.sh' and try again."
            exit 22
        fi
        
        write_details
    done
    say "DEBUG: END OF 'run_builds' function."
}

compile_component()
{
    say "DEBUG: START OF 'compile_component' function."
    say "INFO: Compiling $component."
    make -j "$compiler_jobs"
    if [[ "$install_destination" == "/opt/"* ]] || [[ "$install_destination" = "/usr/"* ]]; then
        say "WARNING: FlightGear is going to be installed to a 'system folder' '$install_destination'."
        say "WARNING: Please enter your root password when 'sudo' asks for it."
        say "INFO: Running 'sudo make install' for '$component'."
        sudo make -j "$compiler_jobs" install
    elif [[ "$install_destination" == *"$USER"* ]]; then
        say "INFO: Running 'make install' for '$component'."
        make -j "$compiler_jobs" install
    else
        say "ERROR: Invalid path/destination for install destination. install_destination='$install_destination'."
        say "DEBUG: END OF compile_component."
        exit 22
    fi
    say "DEBUG: END OF 'compile_component' function."
}

build_plib()
{
    cd "$source_destination/$component"
    sh autogen.sh
    ./configure --prefix="$install_destination"
    compile_component
}

check_cmake_exit_status()
{

    local cmake_exit_status="$?"
    if [ "$cmake_exit_status" = "1" ]; then
        say "ERROR: Something went wrong when running 'cmake' for '$component'."
        say "INFO: Please make sure you have all dependencies installed."
        unset cmake_exit_status
        say "ERROR: Exiting."
        exit 22
    elif [ "$cmake_exit_status" = "0" ]; then
        say "'cmake' for '$component' seems to have worked fine."
    else
        say "WARNING: Can't be sure if cmake for '$component' worked or not. Continuing..."
        say "WARNING: cmake exit status was '$cmake_exit_status'"
    fi

    unset cmake_exit_status
}

build_with_cmake()
{
    say "DEBUG: Creating folder $build_destination/$component"
    mkdir -p "$build_destination/$component"
    cd "$build_destination/$component"
    cmake_flags="${component}_cmake_flags"
    cmake_flags=$(eval "echo \"\$$cmake_flags\"")
    cmake_flags="${cmake_flags} ${common_cmake_flags}"
    cmake -Wno-dev -Wno-deprecated "$source_destination/$component" -DCMAKE_INSTALL_PREFIX="$install_destination" "$cmake_flags"
    check_cmake_exit_status
    compile_component
}

copy_files()
{
    say "DEBUG: START OF copy_files."
    if [[ "$install_destination" == "/opt/"* ]] || [[ "$install_destination" = "/usr/"* ]]; then
        sudo cp "$script_dir/libsay" "$install_destination/lib/"
        sudo mv "$script_dir/flightgear" "$install_destination/"
        sudo ln -f -s "$install_destination/flightgear" "$system_binary_destination"
        sudo mv "$script_dir/flightgear-$release.desktop" "$system_applications_destination"
    elif [[ "$install_destination" == *"$USER"* ]]; then
        cp "$script_dir/libsay" "$install_destination/lib/"
        mv "$script_dir/flightgear" "$install_destination/"
        ln -f -s "$install_destination/flightgear" "$user_binary_destination"
        if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
            say "WARNING: '$HOME/.local/bin' is not in your PATH."
            say "INFO: Please add it to your path so you can use the command 'fgfs'."
        fi
        mv "$script_dir/flightgear-$release.desktop" "$system_applications_destination"
    else
       say "ERROR: Something went wrong on 'copy_files'"
    fi
    say "DEBUG: END OF copy_files."
}

install_flightgear()
{
    cd "$script_dir"
    say "DEBUG: Switching to $script_dir."

    say "INFO: Starting instalation of FlightGear to your system."
    say "DEBUG: Creating flightgear executable from 'flightgear_template' with 'sed'."
    cp flightgear_template flightgear

    say "INFO: Installing flightgear runner."
    sed -i "s/flightgear_release/$release/g" flightgear
    sed -i --expression "s@flightgear_install_directory@$install_destination@" flightgear
    chmod +x flightgear

    say "INFO: Creating desktop menus launcher."
    sed --expression "s@fgfs --launcher@flightgear --launcher@" "$install_destination/share/applications/org.flightgear.FlightGear.desktop" > "flightgear-$release.desktop"
    sed -i "s/Name=FlightGear/Name=FlightGear $release/g" "flightgear-$release.desktop"

    copy_files

    say "If everything went well..."
    say "INFO: FlightGear will be hopefully installed to $install_destination."
}

install_check()
{
    if [ -d "$install_destination" ]; then
        install_flightgear
    else
        say "ERROR: $install_destination wasn't found!"
        say "ERROR: Did the build work at all?"
        exit 22
    fi
}

run_builds
install_check

say "DEBUG: END OF compile.sh."

exit 0

