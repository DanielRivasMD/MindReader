#!/bin/bash
if [ -z "$2" ]; then
	echo "Error! Please add filenames!"
  else
	xvfb-run julia --project=/MindReader/ /MindReader/src/MindReader.jl -f "$1" -i "./data"
fi
