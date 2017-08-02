#!/bin/bash
set -xe

read -p "Please enter the source Volume ID: " src_vol
read -p "Please enter the destination Volume ID: " dest_vol
read -p "Please specify the source project name: " s_project_name
read -p "Please specify the destination project name: " d_project_name
read -p "Please specify the destination directory and file in format /../filename.raw " dest_place
s_tenant_name="${s_project_name//./_}"
d_tenant_name="${d_project_name//./_}"
echo "Please enter the export type"
read -p "For volume press 1 and for snapshot press 2: " type

if $type=1
then
    rbd export volume-$src_vol $dest_place --pool volumes_$s_tenant_name 
    echo "Volume has been exported"
    rbd rm volume-$dest_vol --pool volumes_$d_tenant_name
    echo "Destination volume has been removed"
    rbd import $dest_place volume-$dest_vol --dest-pool volumes_$d_tenant_name 
    echo "Volume has been imported"
elif $type=2 
then
    read -p "Please enter the source Snapshot ID: " src_snap
    rbd rm volume-$dest_vol --pool volumes_$d_tenant_name
    echo "Destination volume has been removed"
    rbd clone volumes_$s_tenant_name/volume-$src_vol@snapshot-$src_snap volumes_$d_tenant_name/volume-$dest_vol
    echo "Snapshot has been imported"
else 
    echo "Invalid value entered!"
    exit 1;
fi
