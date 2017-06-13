#!/usr/bin/env bash
#
#  Minio Cloud Storage, (C) 2017 Minio, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#


root_dir="$PWD"
test_dir="apps"
log_dir="log"
error_file_name="error.log"
log_file_name="output.log"

# Setup environment variables for the run.
_init() {
	set -e

	# If S3_ADDRESS is not set the tests are run on play.minio.io by default.

	# S3_ADDRESS is passed on as env variables while starting the docker container.
	# see README.md for info on options.
	#  Note: https://play.minio.io hosts publicly available Minio server.
	if [ -z "$S3_ADDRESS" ]; then
	    export S3_ADDRESS="play.minio.io:9000"
	    export ACCESS_KEY="Q3AM3UQ867SPQQA43P2F"
	    export SECRET_KEY="zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG"
	    export S3_SECURE=1
	    export S3_REGION="us-east-1"  # needed for minio-java
	fi

	# other env vars
	export S3_REGION="us-east-1"  # needed for minio-java
	
}

# Run the current SDK Test
runTest() {

	# Clear log directories before run.
	local sdk_log_dir=$root_dir/$log_dir/$1
	
	# make and clean SDK specific log directories.
	if [ ! -d $sdk_log_dir ]
		then
			mkdir $sdk_log_dir
		else 
			rm -rf $sdk_log_dir/*
	fi
	cd $test_dir/$1
	
	chmod +x ./run.sh

	./run.sh "$sdk_log_dir/$log_file_name" "$sdk_log_dir/$error_file_name"
	
	cd ../..
}

# Cycle through the sdk directories and run sdk tests
main() {
	for i in $(yq  -r '.apps[]' $root_dir/config.yaml ); 
		do 
			f=$root_dir/$test_dir/$i
			if [ -d ${f} ]; then
				echo "running .... $f"

		        # Will not run if no directories are available
		        sdk="$(basename $f)"

		        # Run test
				runTest "$sdk"	
		
			fi
		done
}

_init && main 
