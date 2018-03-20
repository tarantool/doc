echo -en 'Trigger';
for i in {1..30}}; do sleep 1s; echo -en '.'; done
curl -X POST -F token=$1 -F ref=master https://gitlab.com/api/v4/projects/4657341/trigger/pipeline
echo 'Done';
