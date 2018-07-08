docker build /MyProjects/docker/docker-yii2-php/5.6 -t stupka/apache-php-ora

docker run -d --name web2 -p 82:80 -p 4432:443 -v c:/MyProjects/web/sch-service:/app stupka/apache-php-ora
docker start web2
rem docker exec -i -t -e TERM=ansi web1 /bin/bash
