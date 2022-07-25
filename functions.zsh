# Filebeat logs
,flogs() {
    journalctl --output="cat" --output-fields="MESSAGE" -n 10 --no-pager _SYSTEMD_UNIT=filebeat.service
}

,alogs() {
    journalctl --output="cat" --output-fields="MESSAGE" -n 10 --no-pager _SYSTEMD_UNIT=auditbeat.service
}

# DOCKER
# docker exec airflow (pf)
,deas() {
    docker exec -ti server-airflow-webserver-1 bash -c "$*"
}

# docker exec airflow (client)
,deac() {
    docker exec -ti client-airflow-webserver-1 bash -c "$*"
}

# Elasticsearch
,es() {
    curl -k -u elastic:axPYRM3e151UVu24zB1992WA https://localhost:8443/es/"$@";
}
