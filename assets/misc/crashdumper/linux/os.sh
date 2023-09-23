#!/bin/bash
lsb_release -a | grep "Description" | awk -F':' '{print $2}' ; uname -m
