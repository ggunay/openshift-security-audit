# OpenShift Security Checker Scripts

This repository contains a collection of shell scripts developed for checking the security configurations of OpenShift clusters. These scripts cover various aspects such as roles, cluster roles, bindings, shell access, and more. Please note that there might be some overlap in functionality between the scripts.

## Requirements

- OC CLI
- jq

## Usage

Each script can be executed independently by running `./script_name.sh`. Ensure that you have the necessary permissions and access to the OpenShift cluster before running these scripts. Make sure you set the namespace variable inside the script.

## To-Do

Currently, the scripts are separate entities, and there might be some duplication in functionality. They should be merged into a single project.
Writing the results to output files.
