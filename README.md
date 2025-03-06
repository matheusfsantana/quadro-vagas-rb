# Quadro de Vagas


## Como executar a aplicação
Para executar a aplicação com docker, execute:

```
  docker compose up -d
```

## Como funciona?

O arquivo compose.yml está configurado para provisionar um container para o banco de dados postgres e um container para a nossa aplicação rails, ele faz o build do arquivo Dockerfile.dev e executa o arquivo bin/entrypoint.sh que faz a execução da aplicação em modo de desenvolvimento e acessivel em <a href="http://localhost:3000">localhost:3000</a>


## Executar os testes

Com o containers de pé, execute:

```
  docker compose exec web rspec
```

## Executar o rubocop 

Com os containers de pé, execute:

```
  docker compose exec web rubocop
```

## Interromper containers

Para interromper os containers execute:

```
  docker compose down
```

## Comandos Úteis:

Para rebuildar a imagem docker ao subir o container execute:

```
  docker compose up --build
```

Para remover todos os containers inativos execute:

```
  docker rm $(docker ps -aq)
```

Para remover todas as imagens criadas execute

```
  docker rmi (docker images -aq)
```