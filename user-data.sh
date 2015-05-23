#!/bin/bash
set -e -x

export CUSTOMER_ID=""
export ENTITLEMENT_ID=""
export S3_BUCKET=""

curl -sL file://setup.sh | sudo bash -
