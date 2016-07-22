#!/bin/bash

number_of_args=$# #'$#' gives the number of arguments excluding the script-name

if [ "$number_of_args" -lt "1" ]; then
    printf 'Invalid Argument!\n'
    printf 'Required: sparrow_sms <option> \n'
    printf '   Options: \n'
    printf '    -b :   Check balance \n'
    printf '    -p :   Push Sms\n'
else
    option=$1 #first argument
    if [ "$option" == "-p" ]; then
        printf 'Sending SMS...\n'
        curl -s http://api.sparrowsms.com/v2/sms/ \
             -F token='d1QYg28Hxw80xapxpsFA' \
             -F from='Demo' \
             -F to='9823450612,9851153385' \
             -F text='SMS Test from Trishakti Securities.'
    elif [ "$option" == "-b" ]; then
        printf 'Checking balance...\n'
        curl http://api.sparrowsms.com/v2/credit/?token=d1QYg28Hxw80xapxpsFA
    else
        printf 'Invalid Option.\n'
    fi
fi





