FROM quay.io/keycloak/keycloak:18.0.1

COPY last-realm.json /tmp

RUN /opt/keycloak/bin/kc.sh import --file=/tmp/last-realm.json
