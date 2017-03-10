#!/bin/bash

# -------
# HISTORY
# -------
# Author: ARM - Service Continuity Team
# Source: gitHub
# Purpose: To find mbed cloud client v1.1 error codes from Jenkins build log and integrate with VictorOps.
# Revision:
#          v0.1 Beta 15-02-2017 Uses error codes sourced from local arrays (later revision may source from gitHUB .h header file) 
#          --- add next revision here & comment, changes ---
# -------

# Debug (uncomment)
#set -x

# Variables
REGEX="\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?0*([1-9]|[1-3][0-9]|4[0-7])(\)|\s|$)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(102[4-9]|10[3-9][0-9]|11[0-9]{2}|12[0-6][0-9]|127[0-9])(\)|\s|$)"

# --- Test section ---#
#BADSEARCH="kalkadoon"
#log/2017-03-08_105020/3b_every_time_device_is_turned_on_0/Dut.D1.log
JOB_NAME="3b_every_time_device_is_turned_on_0"
DATE_NAME="2017-03-08_105020"
LOG_PATH="./$DATE_NAME/$JOB_NAME"
LOG_FILE="Dut.D1.log"
LOG="./$LOG_PATH/$LOG_FILE"
# ---
#JOB="$JOB_NAME"
#LOG="./$(find . -type d -name $(date +%F)_*)/$JOB/$LOG_FILE"

# v1.1 header(.h) error code arrays
declare -a IDENTITY=(
'IdentityError error code 1'
'IdentityInvalidParameter error code 2'
'IdentityOutofMemory error code 3'
'IdentityProvisioningError error code 4'
'IdentityInvalidSessionID error code 5'
'IdentityNetworkError error code 6'
'IdentityInvalidMessageType error code 7'
'IdentityInvalidMessageSize error code 8'
'IdentityCertOrKeyNotFound error code 9'
'IdentityRetransmissionError error code 10'
);

declare -a CONNECT=(
'ConnectErrorNone error code 48'
'ConnectAlreadyExists error code 49'
'ConnectBootstrapFailed error code 50'
'ConnectInvalidParameters error code 51'
'ConnectNotRegistered error code 52'
'ConnectTimeout error code 53'
'ConnectNetworkError error code 54'
'ConnectResponseParseFailed error code 55'
'ConnectUnknownError error code 56'
'ConnectMemoryConnectFail error code 57'
'ConnectNotAllowed error code 58'
'ConnectSecureConnectionFailed error code 59'
'ConnectDnsResolvingFailed error code 60'
);

declare -a UPDATE=(
'UpdateErrorBase error code 1024'
'UpdateWarningCertificateNotFound error code 1025'
'UpdateWarningCertificateInvalid error code 1026'
'UpdateWarningSignatureInvalid error code 1027'
'UpdateWarningVendorMismatch error code 1028'
'UpdateWarningClassMismatch error code 1029'
'UpdateWarningDeviceMismatch error code 1030'
'UpdateWarningURINotFound error code 1031'
'UpdateErrorUserActionRequired error code 1032'
'UpdateFatalRebootRequired error code 1033'
);

function getIdentityError {
# Find if build log error code number matches an Identity error
# Populate identityERROR array 

        OLD_IFS="$IFS"  #bash is ugly at times
        IFS=$'\n'
        
	# Hnadle leading zero
	tempcodeLIST=( ${codeLIST[@]#0} )
	#printf -- '%s\n' ${tempCODELIST[@]}

        for i in "${tempcodeLIST[@]}"; do
                identityERROR+=( $(printf -- '%s\n' "${IDENTITY[@]}" | grep -w "$i") )
        done
 
	echo " --- IDENTITY ERRORS"
        printf -- '%s\n' ${identityERROR[@]}
        IFS="$OLD_IFS"
}

function getConnectError {
# Find if build log error code number matches a Connect error
# Populate connectERROR array 

	OLD_IFS="$IFS"  #bash is ugly at times
	IFS=$'\n'

	for c in "${codeLIST[@]}"; do
		connectERROR+=( $(printf -- '%s\n' "${CONNECT[@]}" | grep -w "$c") )
	done

	echo " --- CONNECT ERRORS"
	printf -- '%s\n' ${connectERROR[@]}
	IFS="$OLD_IFS"
}

function getUpdateError {
# Find if build log error code number matches an Update error
# Populate updateERROR array 

	OLD_IFS="$IFS"  #bash is ugly at times
	IFS=$'\n'

	for u in "${codeLIST[@]}"; do
		updateERROR+=( $(printf -- '%s\n' "${UPDATE[@]}" | grep -w "$u") )
	done

	echo " --- UPDATE ERRORS"
	printf -- '%s\n' ${updateERROR[@]}
	IFS="$OLD_IFS"
}

function pushIdentityError {
	echo ${iMSG[*]}
	#curl -X POST --header 'Accept: application/json' -d '{"entity_id":"'$JOB_NAME'","message_type":"INFO","monitoring_tool":"Jenkins","state_message":"Device fails bootstraping system test","impact_message":"Device cannot come online","build_url":"'$BUILD_URL'","error_message":"'${iMSG[*]}'"}' https://alert.victorops.com/integrations/generic/20131114/alert/0a682c50-9d98-4356-a228-bbcefae225ae/SystemTest-RK0
}

function pushConnectError {
	echo ${cMSG[*]}
	#curl -X POST --header 'Accept: application/json' -d '{"entity_id":"'$JOB_NAME'","message_type":"INFO","monitoring_tool":"Jenkins","state_message":"Device fails bootstraping system test","impact_message":"Device cannot come online","build_url":"'$BUILD_URL'","error_message":"'${cMSG[*]}'"}' https://alert.victorops.com/integrations/generic/20131114/alert/0a682c50-9d98-4356-a228-bbcefae225ae/SystemTest-RK0
}

function pushUpdateError {
	echo ${uMSG[*]}
	#curl -X POST --header 'Accept: application/json' -d '{"entity_id":"'$JOB_NAME'","message_type":"INFO","monitoring_tool":"Jenkins","state_message":"Device fails bootstraping system test","impact_message":"Device cannot come online","build_url":"'$BUILD_URL'","error_message":"'${uMSG[*]}'"}' https://alert.victorops.com/integrations/generic/20131114/alert/0a682c50-9d98-4356-a228-bbcefae225ae/SystemTest-RK0
}

function alertVictorOps {
# Push alerts to VictorOps

	echo "INFO: --- START ---pushing errors messages to VictorOps"

	# Push where identity|connect|update<>ERROR not null
	if [ -z "$identityERROR" ]; then 
		echo "INFO: identityERROR array empty"
	elif
		[ "${#identityERROR[@]}" == "1" ]; then
		iMSG=( $(printf '%s' "${identityERROR[@]}") )
		pushIdentityError
	else
		iMSG=( $(printf '%s | ' "${identityERROR[@]}") )
		pushIdentityError
	fi

	# Push where connectERROR not null
	if [ -z "$connectERROR" ]; then 
		echo "INFO: connectERROR array empty"
	elif
		[ "${#connectERROR[@]}" == "1" ]; then
		cMSG=( $(printf '%s' "${connectERROR[@]}") )
		pushConnectError
	else
		cMSG=( $(printf '%s | ' "${connectERROR[@]}") )
		pushConnectError
	fi

	# Push where updateERROR not null
	if [ -z "$updateERROR" ]; then 
		echo "INFO: updateERROR array empty"
	elif
		[ "${#updateERROR[@]}" == "1" ]; then
		uMSG=( $(printf '%s' "${updateERROR[@]}") )
		pushUpdateError
	else
		uMSG=( $(printf '%s | ' "${updateERROR[@]}") )
		pushUpdateError
	fi

	echo "INFO: --- END ---pushing errors messages to VictorOps"
}

function checkLog
{
# Check build logfile for error code
	#if ! [[ $(grep -E ''${REGEX}'' /home/peedo/tmp/example.txt) ]]; then
	if ! [[ $(grep -E '\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?0*([1-9]|[1-3][0-9]|4[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(102[4-9]|10[3-9][0-9]|11[0-9]{2}|12[0-6][0-9]|127[0-9])(\)|\s|$)' /home/peedo/tmp/example.txt) ]]; then
		echo "Return state 0: $LOG_FILE no match found for regex $REGEX"
	else
		echo "Return state 1: $LOG_FILE match found for regex $REGEX"
		OLD_IFS="$IFS"  #bash is ugly at times
		IFS=$'\n' errorLINE=( $(grep -E '\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?0*([1-9]|[1-3][0-9]|4[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(102[4-9]|10[3-9][0-9]|11[0-9]{2}|12[0-6][0-9]|127[0-9])(\)|\s|$)' /home/peedo/tmp/example.txt) )

		echo "--- START --- : regex returned lines from $LOG"
		echo "Num_of errorLINE array elements: ${#errorLINE[@]}"
		echo "${errorLINE[*]}"
		echo " --- END --- : regex returned lines from $LOG"

		codeLINE=("${errorLINE[@]}")
        	codeLINE=( $(echo ${codeLINE[@]} | sed 's/[()]//g') )

		# Create unique elements codeLIST array 
        	codeLIST=( $(awk '{for(j=1;j<=NF;j++) if ($j=="code") print $(j+1)}' <<< ${codeLINE[@]}) )
        	codeLIST=( $(printf "%s\n" "${codeLIST[@]}" | sort -u) )

		printf -- '%s\n' ${codeLIST[@]}
		IFS="$OLD_IFS"
	fi
}

#---Start Main ---#
checkLog
getIdentityError
getConnectError
getUpdateError
alertVictorOps
#---End Main ---#

# --- v0.2 --- #
#sed "s/^[ \t]*//" header.txt | awk '/typedef enum/{flag=1;next}/}Error;/{flag=0}flag' | grep -v ^# | sed 's/,//g' > out.txt

# GIT source
#cd to mount popint for gitHub/arm-mbed/?

# IF file exists, then copy
# ELSE BREAK with exit msg, email
#cp /?/MbedCloudClient.h .

#INPUTFILE="MbedCloudClient.h"

#IDENTITY=($(sed "s/^[ \t]*//" $INPUTFILE | grep -E "^Identity[^[:space:]]+" | sed 's/,//g' | awk '{print $1}'))
#CONNECT=($(sed "s/^[ \t]*//" $INPUTFILE | grep -E "^Connect[^[:space:]]+" | sed 's/,//g' | awk '{print $1}'))
#UPDATE=($(sed "s/^[ \t]*//" $INPUTFILE | grep -E "^Update[^[:space:]]+" | sed 's/,//g' | awk '{print $1}'))

# --- v0.2 ---

#Regex
#1-47
#0*([1-9]|[1-3][0-9]|4[0-7])(\)
#\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?0*([1-9]|[1-3][0-9]|4[0-7])(\)|\s|$)
#
#48-137
#(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])
#\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])(\)|\s|$)
#
#1024-1279 
#(102[4-9]|10[3-9][0-9]|11[0-9]{2}|12[0-6][0-9]|127[0-9])
#\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(102[4-9]|10[3-9][0-9]|11[0-9]{2}|12[0-6][0-9]|127[0-9])(\)|\s|$)
#
# 10-47 | 48-137 | 1024-1279
#\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?([1-3][0-9]|4[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])(\)|\s|$)|\[?[Ee][Rr][Rr][Oo][Rr]\]? code \(?(102[4-9]|10[3-9][0-9]|11[0-9]{2}|12[0-6][0-9]|127[0-9])(\)|\s|$)
