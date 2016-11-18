# POScript
O que o script faz é compilar o projecto, correr todos os testes (com um import caso exista), comparar o output obtido com o output esperado e escrever o sucesso ou insucesso num ficheiro.

## Compatibilidade
O script está escrito em bash, portanto logicamente só corre em SO's com bash.
* Linux (incluíndo a VM do projecto): compatibilidade total
* Windows: o Windows 10 aparentemente inclui uma versão canibalizada do kernel de linux e coreutils, logo teoricamente deve correr
* macOS/BSD: à partida deve correr, contudo é necessário mudar a flag "-regex-type posix-extended" para "-E". Pode haver mais problemas

## Instalação
* Fazer download (ali ao lado)
* Copiar para a pasta onde estão os testes:
```sh
$ unzip ~/Downloads/POscript-master.zip -d ~/path/para/a/pasta/de/testes
```
* Dar permissões de execução:
```sh
$ chmod +x ./run.sh
```
* Executar:
```sh
$ ./run2016.sh
```

#### Definir o classpath
O classpath do script é o da máquina virtual. Se compilarem o po-uuilib e deixarem o .jar na pasta ou o meterem noutra pasta qualquer, é necessário definir o classpath **no script** de acordo com isso.

### Estrutura
Este script espera uma estrutura como ilustrado abaixo. *Não corre com qualquer outra estrutura e precisa que o ponto de execução seja a pasta de testes* (ou seja ./run2016.sh funciona correctamente, ./tests-ei-eval/run.sh não).
```
project
├── pex-app
│   ├── examples
│   ├── Makefile
│   ├── pex-app.jar
│   └── src
│       └── ...
├── pex-core
│   ├── Makefile
│   ├── pex-core.jar
│   └── src
│       └── ...
└── tests-ei-daily-201611071926
    ├── A-001-001-M-ok.in
    ├── A-001-002-M-ok.import
    ├── A-001-002-M-ok.in
    ├── A-001-003-M-ok.in
    ├── ...
    ├── expected
    │   ├── A-001-001-M-ok.out
    │   ├── A-001-002-M-ok.out
    │   ├── A-001-003-M-ok.out
    │   └── ...
    ├── prim.tex
    ├── results.txt **<= Ficheiro de resultados**
    └── run2016.sh **<= Script**
```

Ou seja, o script fica no directório com os testes (onde estão os .in e .import), e este fica no mesmo directório onde estão o "pex-core" e "pex-app". **O script não corre com qualquer outra estrutura que não a mostrada acima e precisa que o ponto de execução seja a pasta de testes** (ou seja ./run2016.sh funciona correctamente, ./tests-ei-eval/run2016.sh não).

### Resultados
É gerado o ficheiro "results" que mostra "Passed!" para cada teste sem erros e "Failed!" com as diferenças de output para cada teste que falhou. Exemplo:

```sh
TEST: A-001-001-M-ok
	OPTIONS:-cp /usr/share/java/po-uuilib.jar:../pex-core/pex-core.jar:../pex-app/pex-app.jar -Din=./A-001-001-M-ok.in -Dout=.A-001-001-M-ok.outhyp
	Passed!
TEST: A-001-003-M-ok
	OPTIONS:-cp /usr/share/java/po-uuilib.jar:../pex-core/pex-core.jar:../pex-app/pex-app.jar -Din=./A-001-003-M-ok.in -Dout=.A-001-003-M-ok.outhyp
	Failed!
		10c10,11
		< Escolha uma opção: Nome do program: Menu Principal
		---
		> Escolha uma opção: Nome do program: O programa a não existe.
		> Menu Principal
```
### Testes futuros
O script usa regex para descobrir todos os inputs, imports e outputs, corrê-los e compará-los em vez de correr uma série de testes já conhecidos. Ou seja deve funcionar mesmo que adicionem testes novos feitos pelo professor ou feitos por vocês.
