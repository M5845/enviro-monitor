#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

Rscript \
    -e "require(rmarkdown)" \
    -e "render('$DIR/03-viz.Rmd')"

