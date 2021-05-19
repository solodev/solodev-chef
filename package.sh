#!/bin/bash
/opt/chef/embedded/bin/berks install
/opt/chef/embedded/bin/berks package cookbooks.tar.gz
aws s3 cp cookbooks.tar.gz s3://solodev-aws-ha
#aws s3 cp cookbooks.tar.gz s3://solodev-chef-testing
rm -Rf cookbooks.tar.gz