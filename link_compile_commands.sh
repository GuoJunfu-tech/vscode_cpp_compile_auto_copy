#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

if [[ -d $1 ]]; then
    catkin_ws_dir=$(readlink -f "$1")
else
    catkin_ws_dir=$(catkin locate 2> /dev/null)
    if [[ -z $catkin_ws_dir ]]; then
        current_path=$(pwd)
        while [[ $current_path != "/" ]]; do
            if [[  $current_path =~ .*ws$ && -d "$current_path/src" ]]; then
                catkin_ws_dir=$current_path
                break
            fi
            current_path=$(dirname "$current_path")
        done
    fi

    if [[ -z $catkin_ws_dir ]]; then
        echo -e "${RED}[ERROR]${NC} Cannot find a valid catkin worksapce, please specify one!"
        exit 1
    fi
fi

echo -e "${GREEN}[INFO]${NC} Found catkin worksapce: $catkin_ws_dir"

mapfile -t packages < <(catkin list -w "$catkin_ws_dir" -u)

if [[ ${#packages[@]} -gt 0 ]]; then
    echo -e "${GREEN}[INFO]${NC} Found following packages:"
    for package in "${packages[@]}"; do
        echo -e "  * ${BOLD}$package${NC}"
    done

    build_dir=$(catkin locate -w "$catkin_ws_dir" -b)
    for package in "${packages[@]}"; do
        compile_commands_file=$build_dir/$package/compile_commands.json
        symbolic_file=$(catkin locate "$package")/compile_commands.json
        if [[ -e $compile_commands_file ]]; then
            echo -e "${GREEN}[INFO]${NC} Linking $compile_commands_file -> $symbolic_file"
            ln -sf "$compile_commands_file" "$symbolic_file"
        fi
    done
fi
