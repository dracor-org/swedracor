#!/bin/sh

# clone swedracor to get initial checkin
if ! [ -d ./dramawebben ]; then
  git clone git@github.com:dracor-org/swedracor.git dramawebben
fi

# change to dramawebben tag which marks the initial version
cd ./dramawebben
git checkout dramawebben
cd -

# clear tei files
rm -v tei/*.xml

for f in ./dramawebben/tei/*.xml; do
  # adjust file name
  n=$(
    basename $f .xml | sed 's/_/-/' | \
    sed -E 's/^Topelius([A-Z]+)/topelius-\1/' | \
    sed -E 's/^([A-Z][a-z]+)[A-Z]+/\1/' | \
    sed -E 's/([a-z])([A-Z])/\1-\2/g' | \
    tr '[:upper:]' '[:lower:]'
  )
  cp -v $f tei/$n.xml
done
