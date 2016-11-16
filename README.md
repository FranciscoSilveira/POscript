# POScript
O que o script faz é compilar o projecto, correr todos os testes (com um import caso exista), comparar o output obtido com o output esperado e escrever o sucesso ou insucesso num log.

## Compatibilidade
O script está escrito em bash, portanto logicamente só corre em SO's com bash.
* Linux (incluíndo a VM do projecto): compatibilidade total
* Windows: o Windows 10 aparentemente inclui uma versão canibalizada do kernel de linux e coreutils, logo teoricamente deve correr
* macOS/OS X: à partida deve correr, contudo o script usa um standard de regex (Posix-extended) que é possível que a Apple não inclua

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

#### Definir o classpath
Se ocorrerem erros de "Symbol not found" é necessário definir onde estão as classes a usar na execução. Isto é feito com a variável 'classpath' no topo do script, que deve incluir os caminhos para todos os .jar do projecto separados por um ':' (sem aspas).

### Estrutura
Este script espera uma estrutura como ilustrado abaixo. *Não corre com qualquer outra estrutura e precisa que o ponto de execução seja a pasta de testes* (ou seja ./run2016.sh funciona correctamente, ./tests-ei-eval/run.sh não).

./  
├── project  
│   ├── CVS  
│   ├── edt-core  
│   └── edt-textui    
├── tests-ei-eval-201611171200  
│   ├── A-001-001-M-ok.in  
│   ├── A-001-001-M-ok.outhyp  
│   ├── A-001-002-M-ok.in  
│   ├── A-001-002-M-ok.outhyp  
│   ├── A-002-001-M-ok.import  
│   │ etc...  
│   ├── expected  
│   │   ├── A-001-001-M-ok.out  
│   │   ├── A-001-002-M-ok.out  
│   │   ├── A-002-001-M-ok.out  
│   │   │ etc...  
│   ├── results <- O ficheiro de resultados gerado  
│   └── run.sh <- O script  


Ou seja, coloquem o script no directório com os testes (onde estão os .in e .import) e coloquem este no mesmo directório onde está o directório "project" que contém o "edt-core" e "edt-textui".

### Executar
**O script não corre com qualquer outra estrutura que não a mostrada acima e precisa que o ponto de execução seja a pasta de testes** (ou seja ./run2016.sh funciona correctamente, ./tests-ei-eval/run2016.sh não).
```sh
$ cd ~/path/para/a/pasta/de/testes
$ ./run.sh
```

### Resultados
É gerado o ficheiro "results" que mostra "Passed!" para cada teste sem erros e "Failed!" com as diferenças de output para cada teste que falhou. Exemplo:

```sh
TEST: /A-005-001-M-ok
	OPTIONS:-Din=./A-005-001-M-ok.in -Dout=./A-005-001-M-ok.outhyp
	Passed!

TEST: /A-005-002-M-ok
	OPTIONS:-Din=./A-005-002-M-ok.in -Dout=./A-005-002-M-ok.outhyp
	Failed!
		14c14
		< Dimensão do documento (bytes): 212
		---
		> Dimensão do documento (bytes): 208
```
### Testes futuros
O script usa regex para descobrir todos os inputs, imports e outputs, corrê-los e compará-los em vez de correr uma série de testes já conhecidos. Ou seja deve funcionar mesmo que adicionem testes novos feitos pelo professor ou feitos por vocês.
