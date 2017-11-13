#!/bin/bash

SENSOR_INFO=$DIR/../data/cfg_sensors.yaml
GOOGLE=$DIR/../data/cfg_google.yaml

mon=`date +%m`
year=`date +%y`
prefix="$year-$mon"

OUTPUT="$DIR/../output/$prefix""_sensors.csv"
