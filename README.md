In order to access the local superset application follow these instructions (bash commands):

export SUPERSET_VERSION=3.0.4

docker pull apache/superset:$SUPERSET_VERSION

docker run -d -p 8080:8088 \
             -e "SUPERSET_SECRET_KEY=$(openssl rand -base64 42)" \
             -e "TALISMAN_ENABLED=False" \
             --name superset apache/superset:$SUPERSET_VERSION


docker exec -it superset superset fab create-admin \
              --username admin \
              --firstname Admin \
              --lastname Admin \
              --email admin@localhost \
              --password admin


$ docker exec -it superset superset db upgrade &&
         docker exec -it superset superset load_examples &&
         docker exec -it superset superset init


After configuring your fresh instance, head over to http://localhost:8080 and log in with the default created account:

username: admin
password: admin
