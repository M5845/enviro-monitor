#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/00-config.sh

# upload to google
perl $DIR/google_upload.pl -config $GOOGLE -input $OUTPUT.tmp \
    && rm $OUTPUT.tmp

