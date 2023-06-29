#!/usr/bin/env bash

# makes sure the script removes files it creates in the end
trap "rm -f task-script.sh output.log" EXIT

# task id and build id are arguments for this script
TASK_ID=$1
BUILD_ID=$2

# access backend api to get the script script
curl -s http://localhost:8000/tasks/"$TASK_ID"/field/script > task-script.sh
chmod u+x task-script.sh

# executes the task script and store the log
./task-script.sh > output.log 2>&1
STATUS=$?

# sends the log and the result back to the backend
curl -s -X POST -F "file=@output.log" http://localhost:8000/tasks/"$TASK_ID"/builds/"$BUILD_ID"?exit_code="$STATUS"
