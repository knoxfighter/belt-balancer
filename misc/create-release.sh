#!/bin/bash

cd ..
dir="$(pwd)"
base="$(basename ${dir})"
cd ..
zip -r  ${base}.zip ${base} -x **misc\* **additional_types\* **.git\* **.idea\* **.gitignore
