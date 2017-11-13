#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/00-config.sh

# save to file
perl $DIR/read_all_sensors.pl -config $SENSOR_INFO \
    | grep -v "^#" \
    | tee -a $OUTPUT \
    >> $OUTPUT.tmp

# END
