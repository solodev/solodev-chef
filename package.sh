#!/bin/bash
ls -al
/opt/chef/embedded/bin/chef generate cookbook "solodev_opsworks"
/opt/chef/embedded/bin/berks package cookbooks.tar.gz
ls -al
aws s3 cp cookbooks.tar.gz s3://solodev-aws-ha
#aws s3 cp cookbooks.tar.gz s3://solodev-chef-testing
rm -Rf cookbooks.tar.gz