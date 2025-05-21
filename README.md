# CadernoScript

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Motivação

**CadernoScript** foi concebida com a ideia de ser tão intuitiva e organizada quanto um caderno de anotações bem estruturado. Acreditamos que a programação pode ser mais acessível quando a linguagem reflete processos familiares e é visualmente clara.

*   **Linhas de Ação Claras:** Cada instrução principal começa com `->`, funcionando como um marcador de ação ou um *bullet point*, o que permite identificar imediatamente o fluxo de execução do programa.
*   **Linguagem Natural em Português:** Utilizamos palavras-chave em português como `guarde`, `se`, `enquanto`, `escreva`, fazendo com que o código "fale" a língua do programador iniciante no Brasil, buscando diminuir a barreira inicial do inglês técnico.
*   **Blocos Lógicos Definidos:** Estruturas como `se`, `enquanto` e `por` formam blocos lógicos, explicitamente delimitados por palavras-chave de início (`entao`, `faca`) e fim (`fim_se`, `fim_enquanto`, `fim_por`), semelhante a como se agruparia notas relacionadas sob um tópico em um caderno.
*   **Recurso Tangível (O Lápis):** A mecânica do "lápis" (`aponte_lapis`) introduz um conceito de gerenciamento de um recurso limitado para a ação de `escreva`, adicionando um elemento lúdico e uma metáfora para a atenção necessária ao realizar ações.

Essa abordagem visa tornar a programação mais direta e menos intimidante, especialmente para aqueles que estão dando seus primeiros passos no mundo do desenvolvimento.

Este projeto foi desenvolvido como parte da disciplina de **Linguagens e Paradigmas**, cumprindo os objetivos de criação de uma linguagem com análise léxica/sintática (utilizando Flex e Bison) e um mecanismo de execução (um interpretador em Python).

## Características Principais

*   **Sintaxe em Português:** Palavras-chave como `guarde`, `como`, `numero`, `texto`, `logico`, `se`, `entao`, `senao`, `fim_se`, `enquanto`, `faca`, `fim_enquanto`, `por`, `vezes`, `fim_por`, `escreva`, `leia` (opcional), `verdadeiro`, `falso`, `e`, `ou`, `nao`.
*   **Clareza Estrutural:** Cada instrução principal inicia com o marcador `->`.
*   **Declaração e Atribuição Explícitas:**
    *   Declaração: `-> guarde nome_variavel como tipo_variavel : valor_inicial`
    *   Atribuição: `-> nome_variavel : nova_expressao`
*   **Comparação Intuitiva:** Uso do símbolo `=` para comparação de igualdade e `!=` para desigualdade.
*   **Fim de Bloco Explícito:** Uso de `fim_se`, `fim_enquanto`, `fim_por` para indicar o fim de blocos de código.
*   **Tipos Básicos:** Suporte para `numero` (inteiros e decimais), `texto` (strings) e `logico` (booleano).
*   **Estruturas Essenciais:** Inclui declaração de variáveis, atribuição, condicionais (`se`/`senao`) e loops (`enquanto`/`por N vezes`).
*   **Comentários:** Usa `#` para comentários de linha única.
*   **Mecânica do Lápis:** O comando `escreva` depende do "lápis" estar apontado. O comando `-> aponte_lapis por N usos` gerencia esse recurso, onde `N` é uma expressão numérica que define quantos "usos" o lápis terá.

## Estrutura do Projeto

*   `src/`: Contém os arquivos fonte do validador C (arquivos `.l` do Flex, `.y` do Bison, e `main.c`).
*   `interpreter/`: Contém o script Python `cadernoscript_interpreter.py` responsável pela execução semântica dos comandos.
*   `examples/`: Contém arquivos de exemplo `.caderno` para demonstrar e testar a linguagem (`exemplos_validos.caderno`, `exemplos_invalidos.caderno`).
*   `doc/`: (Opcional) Pode conter documentação adicional, como o EBNF detalhado ou diagramas.
*   `bin/`: Diretório onde o executável `validador_cadernoscript` é colocado após a compilação.
*   `build/`: Diretório onde os arquivos objeto e intermediários da compilação C são colocados.
*   `Makefile`: Arquivo para automatizar o processo de compilação e limpeza.
*   `LICENSE`: Arquivo de licença do projeto (MIT).
*   `README.md`: Este arquivo.

## Gramática EBNF (Resumida)

A estrutura da CadernoScript é formalmente definida pela seguinte gramática EBNF:

```ebnf
programa ::= { instrucao }

instrucao ::= ( declaracao_variavel | atribuicao_variavel | comando_aponte_lapis | comando_escreva | comando_se | comando_enquanto | comando_por | comentario ) [EOL]

EOL ::= "\n"

comentario ::= "#" { QUALQUER_CARACTERE_EXCETO_NOVA_LINHA }

declaracao_variavel ::= "->" "guarde" IDENTIFICADOR "como" tipo ":" expressao
atribuicao_variavel ::= "->" IDENTIFICADOR ":" expressao
tipo ::= "numero" | "texto" | "logico"

comando_aponte_lapis ::= "->" "aponte_lapis" "por" expressao_numerica "usos"
comando_escreva ::= "->" "escreva" "(" lista_expressoes_escreva ")"
lista_expressoes_escreva ::= expressao { "," expressao }

comando_se ::= "->" "se" condicao "entao" EOL { instrucao } [ "senao" EOL { instrucao } ] "fim_se"
comando_enquanto ::= "->" "enquanto" condicao "faca" EOL { instrucao } "fim_enquanto"
comando_por ::= "->" "por" expressao_numerica "vezes" "faca" EOL { instrucao } "fim_por"

expressao ::= termo_logico { ( "ou" ) termo_logico }
termo_logico ::= fator_logico { ( "e" ) fator_logico }
fator_logico ::= [ "nao" ] expressao_comparativa | expressao_comparativa
expressao_comparativa ::= expressao_aditiva [ operador_comparacao expressao_aditiva ]
expressao_aditiva ::= termo_multiplicativo { ( "+" | "-" ) termo_multiplicativo }
termo_multiplicativo ::= fator { ( "*" | "/" ) fator }
fator ::= IDENTIFICADOR | LITERAL_NUMERO | LITERAL_TEXTO | LITERAL_LOGICO | "(" expressao ")" | ( "+" | "-" ) fator

IDENTIFICADOR ::= letra { letra | digito | "_" }
LITERAL_NUMERO ::= digito { digito } [ "." digito { digito } ]
LITERAL_TEXTO ::= "\"" { QUALQUER_CARACTERE_EXCETO_ASPAS_E_NOVA_LINHA } "\""
LITERAL_LOGICO ::= "verdadeiro" | "falso"
operador_comparacao ::= "=" | "!=" | "<" | "<=" | ">" | ">="

*(Para uma análise mais aprofundada da gramática, incluindo as definições de `letra` e `digito` (implícitas nas regras de tokens do Flex), consulte os arquivos `src/cadernoscript.l` para a definição de tokens e `src/cadernoscript.y` para a estrutura gramatical.)*

## Arquitetura

A CadernoScript opera com dois componentes principais que interagem durante a execução gerenciada pelo `Makefile`:

1.  **Validador (C com Flex & Bison):**
    *   **Localização:** Código fonte em `src/`, executável compilado em `bin/validador_cadernoscript`.
    *   **Análise Léxica (Flex - `src/cadernoscript.l`):** Processa o arquivo `.caderno` e o divide em uma sequência de tokens (palavras-chave, identificadores, literais, operadores).
    *   **Análise Sintática (Bison - `src/cadernoscript.y`):** Recebe os tokens do Flex. Atualmente, com uma gramática simplificada, verifica se todos os tokens são conhecidos pela linguagem.
    *   **Saída (com o `main.c` atual):**
        *   Se todos os tokens forem reconhecidos: imprime a mensagem "Sintaxe OK." para a saída padrão (`stdout`).
        *   Se um erro léxico for encontrado: imprime uma mensagem de erro para a saída de erro (`stderr`).

2.  **Interpretador (Python - `interpreter/cadernoscript_interpreter.py`):**
    *   **Entrada:** Nos alvos de execução do `Makefile` (como `make run_validos`), após o Validador C ser executado no arquivo de exemplo, o `Makefile` instrui o Interpretador Python a ler o **mesmo arquivo de script CadernoScript original** diretamente do disco. Este arquivo é passado como entrada padrão (`stdin`) para o script Python quando o argumento `-` é utilizado.
    *   **Análise Sintática Detalhada e Análise Semântica:** O Interpretador Python contém seu próprio parser recursivo descendente que analisa a estrutura completa de cada comando CadernoScript. Ele também realiza a análise semântica.
    *   **Execução:** Avalia as instruções, gerenciando variáveis, calculando expressões (respeitando a precedência de operadores), controlando o fluxo de condicionais e loops, e executando comandos como `escreva` (com a mecânica do "lápis") e `leia`. Reporta erros de sintaxe específicos da estrutura dos comandos ou erros de execução/semânticos.

**Fluxo de Execução (Conforme Gerenciado pelo `Makefile` nos Alvos `run_...`):**

1.  O `Makefile` executa `bin/validador_cadernoscript < examples/arquivo_exemplo.caderno`.
    *   O validador verifica os tokens. Se tudo OK, imprime "Sintaxe OK." no `stdout`.
2.  Se o validador C não retornar um status de erro, o `Makefile` então executa:
    `python3 interpreter/cadernoscript_interpreter.py - < examples/arquivo_exemplo.caderno`.
    *   O interpretador Python lê o `arquivo_exemplo.caderno` (novamente, do disco) e o executa.

## Como Compilar e Executar

Este projeto utiliza `make` para gerenciar a compilação do validador.

**Pré-requisitos:**
*   `gcc` (ou um compilador C compatível)
*   `flex`
*   `bison`
*   `python3`
*   `make`

**Comandos do Makefile:**

1.  **Compilar o validador:**
    Navegue até a raiz do projeto e execute:
    ```bash
    make
    ```
    Isso compilará os fontes em `src/` e colocará o executável `validador_cadernoscript` em `bin/`. Os arquivos intermediários (`.o`, `.tab.c`, etc.) serão colocados em `build/`.

2.  **Limpar arquivos de compilação:**
    Para remover os diretórios `build/` e `bin/` e os arquivos gerados:
    ```bash
    make clean
    ```

3.  **Testar apenas a validação sintática dos exemplos válidos:**
    Este comando executa o validador C com o arquivo `exemplos_validos.caderno`.
    ```bash
    make test_validation_validos
    ```

4.  **Testar apenas a validação sintática dos exemplos inválidos:**
    Este comando executa o validador C com o arquivo `exemplos_invalidos.caderno`. Espera-se que alguns erros sejam reportados aqui pelo validador C.
    ```bash
    make test_validation_invalidos
    ```

5.  **Executar os exemplos válidos (validador + interpretador):**
    Este comando passa o script `exemplos_validos.caderno` pelo validador e, se bem-sucedido, executa com o interpretador Python.
    ```bash
    make run_validos
    ```

6.  **Executar os exemplos inválidos (validador + interpretador):**
    Tenta executar `exemplos_invalidos.caderno`. Espera-se que o validador C ou o interpretador Python reportem erros.
    ```bash
    make run_invalidos
    ```

7.  **Executar todos os testes (válidos e inválidos):**
    Executa `run_validos` e depois `run_invalidos`.
    ```bash
    make run_all_tests
    ```

**Executando manualmente:**

Após compilar com `make`, você pode executar manualmente:

*   **Apenas o validador:**
    ```bash
    bin/validador_cadernoscript < examples/seu_arquivo.caderno
    ```
    (Saída esperada em `stdout`: "Sintaxe OK." se não houver erro léxico. Erros em `stderr`.)

*   **Apenas o interpretador (assumindo que o script é válido):**
    ```bash
    python3 interpreter/cadernoscript_interpreter.py - < examples/seu_arquivo.caderno
    ```

## Exemplos de Código CadernoScript

Abaixo estão alguns exemplos curtos para ilustrar a sintaxe e as principais características da CadernoScript. Para um conjunto mais completo de testes, consulte os arquivos na pasta `examples/`.

**1. Declaração de Variáveis e Saída Simples:**
```cadernoscript
# Declarando variáveis de diferentes tipos
-> guarde mensagem como texto : "Bem-vindo!"
-> guarde ano como numero : 2024
-> guarde ativo como logico : verdadeiro

# Usando o lápis para escrever
-> aponte_lapis por 3 usos
-> escreva (mensagem)
-> escreva ("Estamos no ano:", ano)
-> escreva ("Status ativo:", ativo)
```

Este exemplo mostra a declaração de variáveis dos tipos texto, numero e logico, e o uso do comando escreva (que depende do aponte_lapis por N usos).

**2. Operações e Condicionais:**
```cadernoscript
-> aponte_lapis por 1 uso # Lápis para a saída do condicional
-> guarde pontuacao como numero : 75
-> guarde meta como numero : 60

se (pontuacao >= meta e meta > 50) entao
    -> escreva ("Parabens, meta atingida e eh uma boa meta!")
senao
    -> escreva ("Continue tentando ou ajuste a meta!")
fim_se
```
Demonstra uma estrutura condicional se/senao/fim_se com uma condição composta (e) e comparação numérica.

**3. Loop enquanto e Atribuição:**
```cadernoscript
-> aponte_lapis por 4 usos # Lápis para as 3 contagens + 1 para "Lancamento!"
-> guarde contador como numero : 3
enquanto (contador > 0) faca
    -> escreva ("Contagem regressiva:", contador)
    -> contador : contador - 1 # Atualizando o valor da variável
fim_enquanto
-> escreva ("Lancamento!")
```

Ilustra o loop enquanto e a reatribuição de valor a uma variável.

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo `LICENSE` (se existir) ou o topo deste README para mais detalhes.