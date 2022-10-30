#!/usr/bin/env bash
set -ef -o pipefail #Para deixar seu script seguro

POSITIONAL_ARGS=()

help(){
  echo "Available flags:"
  echo "
  -h | --help   ->  mostra o menu com as opções
  -s | --start  ->  Inicia a aplicação subindo um projeto docker-compose, criado por você, que suba um conteiner docker
                    para a sua aplicação(dica 1: o projeto baixado já tem um Dockerfile, dica 2, precisa buildar o projeto para o dockerfile funcionar,
                    e isso deve ser feito dentro do script), e um conteiner do Prometheus(https://prometheus.io/docs/prometheus/latest/installation/)
                    que possa ler as métricas da aplicação que você subiu. Exemplo de métrica: saber quantas vezes o endpoint de /hello foi chamado
  -d | --dev    ->  Inicia a aplicação no modo dev, ou seja, executando com "./mvnw quarkus:dev", e não inicia o Prometheus.
  -m | --message -> Recebe o argumento com a mensagem a exibir no endpoint /hello no lugar da propriedade que você definiu.
                    Para entender como sobrescrever propriedades com variáveis de ambiente no Microprofile Config,
                    consulte https://smallrye.io/smallrye-config/2.12.1/config/getting-started/.
                    Essa opção pode ser usada tanto no modo -s ou modo -d.

  "
}

build(){
  echo "Construindo o container do quarkus"
  ./mvnw clean install
}

start(){
  build
  echo "Iniciando o aplicativo junto com o prometheus"
    if [ -z "$message" ]
    then
      docker compose up
    else
      GREETING_MESSAGE="${message}" docker compose up
    fi
}

dev(){
  echo "Iniciando o aplicativo no modo de desenvolvimento"
  if [ -z "$message" ]
  then
    ./mvnw quarkus:dev
  else
    GREETING_MESSAGE=${message} ./mvnw quarkus:dev
  fi
}

message(){
  message=${1}
  echo "Parsing the message to feed the app"
  echo "Message: ${message}"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      help
      ;;
    -s|--start)
      start
      shift # past argument
      ;;
    -d|--dev)
      dev
      shift # past argument
      ;;
    -m|--message)
      MESSAGE="${2}"
      message "${2}"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ -n $1 ]]; then
    echo "You need to pass some flags!"
    echo "Please check the options you can use below."
    help
fi


