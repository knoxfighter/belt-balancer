#!/bin/bash

cd ..
dir="$(pwd)"
base="$(basename ${dir})"
zip -r  ../${base}.zip . -x misc\* additional_types\* .git\* .idea\* .gitignore
