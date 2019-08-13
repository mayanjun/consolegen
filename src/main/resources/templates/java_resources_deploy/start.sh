#!/bin/bash
############################################################
# Start application
#
# @author mayanjun
# @Email mayanjun@jd.com
# @ERP mayanjun3
############################################################

# init app
BIN_DIR="$(cd `dirname $0`; pwd)"
APP_DIR="`dirname $BIN_DIR`"
PROFILE_NAME="@maven.profile.name@"
APP_JAR_FILE="@maven.project.name@-@maven.project.version@.jar"
JAVA_BIN="@maven.profile.javabin@"
JVM_OPTS="@maven.profile.javaopts@"
PID_DIR="@maven.profile.logpath@"
PID_FILE="$PID_DIR/app.pid"

echo "============================ APP START =============================="

# start app
if [[ -f "$PID_FILE" ]]; then
    echo "Service is not be stopped correctly, please stop it first."
    echo "PID: `cat $PID_FILE`"
    exit 1
fi

if [[ ! -f "$JAVA_BIN" ]]; then
    echo "JDK not found: $JAVA_BIN"
    exit 1
fi

if [[ ! -d "$PID_DIR" ]]; then
    mkdir -p ${PID_DIR}
    echo "PID dir created"
fi

if [[ -f "$APP_DIR/$APP_JAR_FILE" ]]; then
    echo "Starting application using JVM_OPTS:$JVM_OPTS $SGM_OPTS"
    ${JAVA_BIN} ${JVM_OPTS} -jar ${APP_DIR}/${APP_JAR_FILE} --spring.profiles.active=${PROFILE_NAME} > ${BIN_DIR}/stdio.out 2>&1 &
    PID=$!
    echo "Application started with PID $PID"
    echo "$PID" > ${PID_FILE}
else
    echo "No app archive file found: ${APP_DIR}/${APP_JAR_FILE}"
    exit 1
fi

exit 0