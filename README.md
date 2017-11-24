# POScript
O que o script faz é compilar o projecto, correr todos os testes (com um import caso exista), comparar o output obtido com o output esperado e escrever o sucesso ou insucesso num ficheiro.

## Compatibilidade
O script está escrito em bash, portanto logicamente só corre em SO's com bash.

* Linux (incluíndo a VM do projecto): compatibilidade total
* Windows: o Windows 10 aparentemente inclui uma versão canibalizada do kernel de linux e coreutils, logo teoricamente deve correr
* macOS/BSD: à partida deve correr, contudo é necessário mudar a flag "-regex-type posix-extended" para "-E" na procura de ficheiros .in (linha 80). Pode haver mais problemas

## Instalação e resultados
* Fazer download (ali ao lado)
* Copiar para a pasta onde está o cdigo e os testes:
```sh
$ unzip ~/Downloads/POscript-master.zip -d ~/path/para/a/pasta/do/projecto
```
* Dar permissões de execução:
```sh
$ chmod +x ./run2017.sh
```
* Executar:
```sh
$ ./run2017.sh
```

É gerado o ficheiro "results.txt" que mostra "Passed!" para cada teste sem erros e "Failed!" com as diferenças de output para cada teste que falhou. Exemplo:

```
TEST: A-001-001-M-ok
	OPTIONS: -cp /usr/share/java/po-uuilib.jar:../mmt-core/mmt-core.jar:../mmt-app/mmt-app.jar -Din=./A-001-001.in -Dout=.A-001-001.outhyp
	Passed!
TEST: A-001-003-M-ok
	OPTIONS: -cp /usr/share/java/po-uuilib.jar:../mmt-core/mmt-core.jar:../mmt-app/mmt-app.jar -Din=./A-001-003.in -Dout=.A-001-003.outhyp
	Failed!
		10c10,11
		< Escolha uma opção: Nome do program: Menu Principal
		---
		> Escolha uma opção: Nome do program: O programa a não existe.
		> Menu Principal
```

## Opções
É possvel definir as directorias de testes e código com flags:

* **-s /path/to/source** : define a directoria onde estão as directorias mmt-app e mmt-core. Isto é usado na compilação dos pacotes e na execução dos testes (classpath).
* **-t /path/to/tests** : define as directorias onde estão os ficheiros de teste

**O ficheiro de resultados é sempre escrito na directoria actual da shell,** independentemente de terem usado flags ou não, ou de sequer estarem na pasta do script. Ex:
```sh
$ cd ~
$ ~/Downloads/run2017.sh -s ~/Documents/PO/projecto -t ~/testes_de_PO
$ cat ./results.txt
```
**A directoria de testes tem sempre de conter a directoria expected com os ficheiros .out**, independentemente de terem usado flags ou não. Ou seja não funciona com a primeira versão dos testes diários em que os .out estavam na mesma directoria que os .in e .import.

Caso não queiram usar as flags (y tho), o script vai procurar as directorias mmt-app, mmt-core e tests na pasta onde está. Ou seja, é esperada uma estrutura deste género:
```
project
├── run2017.sh
├── mmt-app
│   ├── Makefile
│   ├── mmt-app.jar
│   └── src
│       └── ...
├── mmt-core
│   ├── Makefile
│   ├── mmt-core.jar
│   └── src
│       └── ...
└── tests
    ├── expected
    │   ├── A-001-001.out
    │   ├── A-001-002.out
    │   ├── A-001-003.out
    │   └── ...
    ├── A-001-001.in
    ├── A-001-002.import
    ├── A-001-002.in
    ├── A-001-003.in
    └── ...
```

### Definir o classpath para o .jar fornecido pelos docentes
O classpath para a parte fornecida é o da VM (/usr/share/java/po-uuilib.jar). Se compilarem o po-uuilib e deixarem o .jar na pasta ou o meterem noutra pasta qualquer, é necessário definir essa parte do classpath **no script** de acordo com isso.


## Testes futuros
O script usa regex para descobrir todos os inputs, imports e outputs, corrê-los e compará-los em vez de correr uma série de testes já conhecidos. Ou seja deve funcionar mesmo que adicionem testes novos feitos pelo professor ou feitos por vocês.
