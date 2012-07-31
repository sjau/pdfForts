#!/bin/bash

source "common.sh"

function testFunc
{
	testVar="${0}"
	echo "${testVar}"

	files="${1}"

	for files ;
	do
		echo "${files}"
	done
}

testFunc "${@}"

#exit;