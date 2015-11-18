# POScript
## Instalação
Isto só funciona em Linux.
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
$ ./run.sh
```

### Estrutura
Este script espera uma estrutura deste tipo:

./  
├── project  
│   ├── CVS  
│   ├── edt-core  
│   └── edt-textui    
├── tests-ei-eval-201511161200  
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
│   └── run.sh <- O meu script  


Ou seja, coloquem o script no directório com os testes (onde estão os .in e .import) e coloquem este no mesmo directório onde está o directório "project" que contém o "edt-core" e "edt-textui".

### Log
É gerado o ficheiro "results" com um log. Exemplo de resultados:

```sh
TEST: /A-004-001-M-ok
	Passed!

TEST: /A-006-001-M-ok
	Passed!

TEST: /A-005-003-M-ok
	Failed!
	< Dimensão do documento (bytes): 273
	---
	> Dimensão do documento (bytes): 269
```
### Testes futuros
O script usa regex para descobrir todos os inputs, imports e outputs, corrê-los e compará-los em vez de correr uma série de testes já conhecidos. Ou seja deve funcionar mesmo que adicionem testes novos feitos pelo prof ou feitos por vocês.
