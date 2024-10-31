# Documentação para manutenção do servidor principal Cloudtoc

## Como funciona por trás?
Na pasta **cloudtoc-docker** estão disponiveis 2 pastas, **laravel** e **data**.
A principal ideia em utilizar esta tecnologia neste projeto é a compatibilidade.
De forma a que este seja compativel com futuras migrações a pasta **data** é a **"Memória"** do projeto. 
O restante (**laravel**, **mysql**) são as receitas para a criação dos sistemas onde é executado o **"Cérebro"** do projeto.

## Diretório /data
Este diretório como explicado anteriormente é onde todos os dados importantes estão alojados.
Alguns dos exemplos são a base de dados MySQL, os ficheiros encriptados dos clientes, ficheiros logs, entre outros.

## Antes da primeira instalação
Preencher os dados do .env na raíz do diretório **cloudtoc-docker**, juntamente do ficheiro **docker-compose.yaml**
Obs: Se for mais prático pode se copiar o ficheiro **.env.example** presente neste diretório.

## Comandos úteis
No dirétorio do **docker-compose.yaml** utilizar os seguintes comandos:

### Se for a primeira vez a iniciar este docker

```sh
docker-compose up -d
```

### Ou para parar os containers

```sh
docker-compose down
```

### Para reconstruir
```sh
docker-compose build --no-cache && docker-compose up -d
```

### Relativos ao docker em CLI
```sh
docker ps

docker exec -it <container_id> bash

docker logs <container_id>
```
