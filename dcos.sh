#!/bin/bash

if [ -z "$1" ]; then
  echo "Note: You can specify the URL of your DCOS cluster upon startup"
  echo "e.g., docker run -i -t vishnumohan/alpine-dcoscli http://dcos.elb.amazonaws.com"
  source bin/env-setup
  echo ""
elif [ ! -z "$1" ]; then
  echo "Setting core.dcos_url set to ${1}"
  source bin/env-setup && dcos config set core.dcos_url "$1"
  echo ""
fi

echo "DCOS CLI Config:"
dcos config show
echo ""
dcos
echo ""
bash

