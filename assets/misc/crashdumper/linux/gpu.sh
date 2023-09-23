#!/bin/bash
lspci | grep VGA | awk -F ':' '{print $3}'
