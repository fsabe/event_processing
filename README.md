# Event Processing

## Ambiente

Para executar a aplicação é necessário o Ruby (versão 2.4.0 recomendada) com RubyGems e a gem Bundler, que é usada para gerenciar as demais dependências da aplicação. Para instalar estas execute o seguinte comando:

```
bundle install --path vendor
```

## Execução

### Linha de comando

Para executar a aplicação e processar eventos inseridos a partir da linha de comando, pode-se usar o utilitário localizado em `bin/event_processor`. Este programa irá ler os eventos a partir da entrada padrão ou de um arquivo especificado, um evento por linha, e ao final da execução irá imprimir os conjuntos de agregações na saída padrão.

```
bin/event_processor < examples/input.txt
```
```
bin/event_processor examples/input.txt
```

### Servidor

Para executar o servidor pode-se utilizar o utilitário em `bin/server`. Isto fará com que seja iniciado um servidor que recebe os eventos através de requisições UDP na porta 3030. O servidor irá imprimir os conjuntos de agregações na saída padrão sempre que um intervalo determinado houver passado (medido a partir do timestamp dos eventos recebidos). Quando o servidor é encerrado, todas os eventos ainda não processados são agregados e os resultados impressos.

```
bin/server
```
```
cat examples/input.txt | nc -u -w0 localhost 3030
```
