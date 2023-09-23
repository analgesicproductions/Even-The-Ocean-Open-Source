#!/bin/bash
cat /proc/meminfo | grep MemTotal | awk -F ':' '{print $2}'
