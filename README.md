# Event Processing

## Ambiente

Para executar a aplicação é necessário o Ruby (versão 2.4.0 recomendada) com RubyGems e a gem Bundler, que é usada para gerenciar as demais dependências da aplicação.

## Execução

### Linha de comando

Para executar a aplicação e processar eventos inseridos a partir da linha de comando, pode-se usar o utilitário localizado em `bin/event_processor`. Este programa irá ler os eventos a partir da entrada padrão ou de um arquivo especificado, um evento por linha, e ao final da execução irá imprimir os conjuntos de agregações na saída padrão.

```
bin/event_processor < examples/input.txt
```
```
bin/event_processor examples/input.txt
```
