#!/bin/bash
# Script which Aggregates the execution for the websocket tests

TERM_NAME_PREFIX=$1
HOST=$2
TERM_LIMIT=$3

username=''
password=''
while IFS="," read -r rec_column1 rec_column2
do
  username=$rec_column1
  password=$rec_column2
done < <(tail -1 $CREDENTIALS_CSV)

echo $username
echo $password

ALLOBJS_TERMINALS=$(curl -k -u "$USERNAME:$PASSWORD" -s "http://$HOST/api/2.0/config/terminal?limit=$TERM_LIMIT&obj_name=%$TERM_NAME_PREFIX%" | /usr/local/bin/jq -r '.data[] | .obj_id')

echo $ALLOBJS_TERMINALS
ALL_OBJS_TERMINALS=$(echo $ALLOBJS_TERMINALS | sed 's/ /,/g')

echo $ALL_OBJS_TERMINALS


csv_file=testResults_${BUILD_NUMBER}.csv
text_file=testResults_${BUILD_NUMBER}.txt
xml_file=testResults_${BUILD_NUMBER}.xml

if [ -z "$ALL_OBJS_TERMINALS" ]; then	
    echo "ALLOBJS_TERMINALS is NULL"	
    exit -1
fi

# Ping and reachability check
ping_check_stats_sim_ip=$(ping -c 1 ${HOST})
if [ $? != 0 ]; then
    echo "============================================="
    echo "The reachability to NMS IP is not there"
    echo "============================================="
    exit -1
fi

debug_flag="true"

if [[ ${JMX_Implementation} == "With_basic_auth_logout" ]]; then
    if [[ ${debug_flag} == "true" ]]; then
        
        echo "##################################"
        echo "STARTING THE JMETER TEST.........."
        echo "##################################"
        
        multiuser_credentials_file=""
        if [[ $USERGROUP_OPTIONS == "Busy_Usergroup" ]]; then
            multiuser_credentials_file="multiuser_credentials_n_busy_users.csv"
        elif [[ $USERGROUP_OPTIONS == "General_Usergroup" ]]; then
            multiuser_credentials_file="multiuser_credentials_n_general_users.csv"
        elif [[ $USERGROUP_OPTIONS == "Special_Usergroup" ]]; then
            multiuser_credentials_file="multiuser_credentials_n_special_users.csv"
        fi
        
        if [[ ${JOB_NAME} == *"Sockio"* ]]; then
            echo "In sockio"
            ../../apache-jmeter-5.2.1/bin/jmeter -n -t Sockio_Client.jmx -JNUM_USERS=${NUM_USERS} -j test_logfile_${BUILD_NUMBER}.log -L${Log_Levels} -JCREDENTIALS_CSV=$multiuser_credentials_file -JHOST=${HOST} -JTERM_LIMIT=${TERM_LIMIT}  -JTEST_DURATION=${TEST_DURATION} -JTERM_NAME_PREFIX="${TERM_NAME_PREFIX}" -Jall_terminal_obj_ids="${ALL_OBJS_TERMINALS}" -JbuildNumber=${BUILD_NUMBER} -Jdebug_flag=${debug_flag} -Jxml_file=${xml_file} -Jtext_file=${text_file} -Jcsv_file=${csv_file} -l testResults_${BUILD_NUMBER}.jtl
        elif [[ ${JOB_NAME} == *"Pubsub"* ]]; then
            ../../apache-jmeter-5.2.1/bin/jmeter -n -t PubSub_Client.jmx -JNUM_USERS=${NUM_USERS} -j test_logfile_${BUILD_NUMBER}.log -L${Log_Levels} -JCREDENTIALS_CSV=$multiuser_credentials_file -JHOST=${HOST} -JTERM_LIMIT=${TERM_LIMIT}  -JTEST_DURATION=${TEST_DURATION} -JTERM_NAME_PREFIX="${TERM_NAME_PREFIX}" -Jall_terminal_obj_ids="${ALL_OBJS_TERMINALS}" -JbuildNumber=${BUILD_NUMBER} -Jdebug_flag=${debug_flag} -Jxml_file=${xml_file} -Jtext_file=${text_file} -Jcsv_file=${csv_file} -l testResults_${BUILD_NUMBER}.jtl
        elif [[ ${JOB_NAME} == *"Websocket"* ]]; then
            echo "../../apache-jmeter-5.2.1/bin/jmeter -n -t Websocket_Client.jmx -JNUM_USERS=${NUM_USERS} -j test_logfile_${BUILD_NUMBER}.log -L${Log_Levels} -JCREDENTIALS_CSV=$multiuser_credentials_file -JHOST=${HOST} -JTERM_LIMIT=${TERM_LIMIT}  -JTEST_DURATION=${TEST_DURATION} -JTERM_NAME_PREFIX="${TERM_NAME_PREFIX}" -Jall_terminal_obj_ids="${ALL_OBJS_TERMINALS}" -JbuildNumber=${BUILD_NUMBER} -Jdebug_flag=${debug_flag} -Jxml_file=${xml_file} -Jtext_file=${text_file} -Jcsv_file=${csv_file} -l testResults_${BUILD_NUMBER}.jtl"
            ../../apache-jmeter-5.2.1/bin/jmeter -n -t Websocket_Client.jmx -JNUM_USERS=${NUM_USERS} -j test_logfile_${BUILD_NUMBER}.log -L${Log_Levels} -JCREDENTIALS_CSV=$multiuser_credentials_file -JHOST=${HOST} -JTERM_LIMIT=${TERM_LIMIT}  -JTEST_DURATION=${TEST_DURATION} -JTERM_NAME_PREFIX="${TERM_NAME_PREFIX}" -Jall_terminal_obj_ids="${ALL_OBJS_TERMINALS}" -JbuildNumber=${BUILD_NUMBER} -Jdebug_flag=${debug_flag} -Jxml_file=${xml_file} -Jtext_file=${text_file} -Jcsv_file=${csv_file} -l testResults_${BUILD_NUMBER}.jtl
        fi

    	if [ ${Logging} == true ]; then
            if [[ -f testResults_${BUILD_NUMBER}.xml && testResults_${BUILD_NUMBER}.csv && testResults_${BUILD_NUMBER}.txt ]]; then
            	gzip -9 testResults_${BUILD_NUMBER}.xml testResults_${BUILD_NUMBER}.csv testResults_${BUILD_NUMBER}.txt
        	fi
        else
   			rm -rf ${csv_file} ${text_file} ${xml_file}      	
        fi
    
    fi

fi
   
   
