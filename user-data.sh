#!/bin/bash
set -e -x

sudo bash
export CUSTOMER_ID=""
export ENTITLEMENT_ID=""
export S3_BUCKET=""

curl -sL https://raw.githubusercontent.com/Globosat/aspera/master/setup.sh | bash -
