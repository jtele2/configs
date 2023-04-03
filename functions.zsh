# My custom functions all start with `,`

,tfp() {
    terraform plan -out tf.plan
    terraform show  tf.plan > tfplan.ansi
    less -RN tfplan.ansi
}

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
