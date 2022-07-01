# docker exec airflow (pf)
deas() {
    docker exec -ti server-airflow-webserver-1 bash -c "$*"
}

# docker exec airflow (client)
deac() {
    docker exec -ti client-airflow-webserver-1 bash -c "$*"
}
