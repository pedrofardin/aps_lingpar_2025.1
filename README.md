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
*   **Mecânica do Lápis:** O comando `escreva` depende do "lápis" estar apontado. O comando `-> aponte_lapis [por N usos]` gerencia esse recurso.

## Estrutura do Projeto

*   `src/`: Contém os arquivos fonte do validador C (arquivos `.l` do Flex, `.y` do Bison, e `main.c`).
*   `interpreter/`: Contém o script Python `cadernoscript_interpreter.py` responsável pela execução semântica dos comandos.
*   `examples/`: Contém arquivos de exemplo `.caderno` para demonstrar e testar a linguagem.
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

expressao ::= (* Definição detalhada de expressões com precedência... *)
              IDENTIFICADOR | LITERAL_NUMERO | LITERAL_TEXTO | LITERAL_LOGICO | "(" expressao ")"
              (* ... operadores aritméticos, lógicos, comparativos ... *)

IDENTIFICADOR ::= letra { letra | digito | "_" }
LITERAL_NUMERO ::= digito { digito } [ "." digito { digito } ]
LITERAL_TEXTO ::= "\"" { QUALQUER_CARACTERE_EXCETO_ASPAS_E_NOVA_LINHA } "\""
LITERAL_LOGICO ::= "verdadeiro" | "falso"

*(Para a EBNF completa e detalhada, consulte a documentação ou o arquivo EBNF específico no repositório, se houver.)*

## Arquitetura

A CadernoScript opera em um pipeline de duas etapas principais:

1.  **Validador (C com Flex & Bison):**
    *   Localizado em `src/` e compilado para `bin/validador_cadernoscript`.
    *   **Análise Léxica (Flex):** O arquivo `cadernoscript.l` define as regras para quebrar o código fonte `.caderno` em uma sequência de tokens.
    *   **Análise Sintática (Bison):** O arquivo `cadernoscript.y` define a gramática da linguagem e verifica se a sequência de tokens forma instruções válidas.
    *   **Saída:** Se a sintaxe estiver correta, o validador imprime o script original para `stdout` e uma mensagem "Sintaxe OK" para `stderr`. Se houver erros, ele os reporta para `stderr`.

2.  **Interpretador (Python):**
    *   Localizado em `interpreter/cadernoscript_interpreter.py`.
    *   Recebe o script CadernoScript validado via `stdin`.
    *   Processa cada instrução, realizando as ações semânticas: gerenciando variáveis, avaliando expressões, controlando o fluxo de condicionais e loops, e executando comandos como `escreva` (respeitando a mecânica do "lápis").

O fluxo de execução é tipicamente:
`entrada.caderno` | `validador_cadernoscript` | (stdout) -> (stdin) | `python3 cadernoscript_interpreter.py -` | (saída do programa)

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

3.  **Testar apenas a validação sintática de um exemplo:**
    Este comando executa o validador com um arquivo de exemplo e mostra se a sintaxe está OK (mensagem em `stderr`) e o script original (em `stdout`).
    ```bash
    make test_validation
    ```
    (Atualmente configurado para usar `examples/meu_programa.caderno`)

4.  **Executar um exemplo completo (validador + interpretador):**
    Este comando passa o script pelo validador e, se a sintaxe estiver correta, envia o script para o interpretador Python.

    ```bash
    make run_example
    ```
    Usa: `examples/meu_programa.caderno`

5. **Executar os testes mínimos da linguagem:**
    Roda um conjunto compacto de testes cobrindo declaração, atribuição, controle de fluxo, lápis e operadores.

    ```bash
    make run_minimos
    ```
    Usa: `examples/testes_minimos.caderno`

6. **Executar todos os exemplos disponíveis:**
    Executa tanto o exemplo principal quanto os testes mínimos em sequência.

    ```bash
    make run_all_examples
    ```

**Executando manualmente:**

Após compilar com `make`, você pode executar manualmente:

*   **Apenas o validador:**
    ```bash
    bin/validador_cadernoscript < examples/seu_arquivo.caderno
    ```
    (Verifique `stderr` para status e `stdout` para o script se OK)

*   **Validador e interpretador em pipeline:**
    ```bash
    bin/validador_cadernoscript < examples/seu_arquivo.caderno | python3 interpreter/cadernoscript_interpreter.py -
    ```

## Exemplo de Código (`examples/meu_programa.caderno`)

```cadernoscript
# Teste CadernoScript
-> guarde msg como texto : "Bem-vindo ao CadernoScript!"
-> guarde contador como numero : 0
-> guarde ativo como logico : verdadeiro

-> aponte_lapis por 3 usos
-> escreva (msg)
-> escreva ("Contador inicial:", contador, " | Ativo:", ativo)

se (contador < 5 e ativo = verdadeiro) entao
    -> escreva ("Dentro do SE, o contador eh menor que 5 e ativo eh verdadeiro.")
    -> contador : contador + 10
senao
    -> escreva ("Dentro do SENAO.")
fim_se

-> escreva ("Apos o SE, contador:", contador) # Lapis deve acabar aqui, proximo 'escreva' pode ser suprimido

-> aponte_lapis # Usa padrao (ex: 5 usos)
enquanto (contador > 0 e contador < 15) faca
    -> escreva ("No ENQUANTO, contador:", contador)
    -> contador : contador - 3
    se (contador < 2) entao
        -> escreva ("Alerta: Contador muito baixo dentro do ENQUANTO!")
    fim_se
fim_enquanto

-> escreva ("Apos ENQUANTO, contador:", contador)

por 2 vezes faca
    -> escreva ("Iteracao do loop POR VEZES.")
fim_por

-> escreva ("Fim do programa exemplo!")

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo `LICENSE` (se existir) ou o topo deste README para mais detalhes.