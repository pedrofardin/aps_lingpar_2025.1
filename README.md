# CadernoScript

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) <!-- Você pode escolher outra licença se preferir -->

## Motivação

**CadernoScript** foi pensada para ser tão intuitiva quanto um caderno de anotações. A organização visual é chave:

*   **Linhas Claras:** Cada instrução executável começa com `->`, como um marcador de linha ou um bullet point, garantindo que você veja imediatamente o fluxo do programa.
*   **Linguagem Natural:** Usamos português (`guarde`, `se`, `enquanto`) para que o código "fale" a sua língua, eliminando a barreira do inglês.
*   **Blocos Definidos:** Estruturas como `se`, `enquanto` e `por` formam blocos lógicos, iniciados por `entao` ou `faca` e finalizados com `...`, de forma semelhante a como você agruparia notas relacionadas sob um tópico em seu caderno.

Essa estrutura "caderno" visa aproveitar a familiaridade e a clareza que todos associam a uma boa organização, tornando a programação acessível e direta, especialmente para quem está começando.

Este projeto foi desenvolvido como parte da disciplina de **[Linguagens e Paradigmas]**, visando cumprir os objetivos de criação de uma linguagem com análise léxica/sintática (Flex/Bison) e um mecanismo de execução.

## Características Principais

*   **Sintaxe em Português:** Palavras-chave como `guarde`, `como`, `se`, `entao`, `senao`, `enquanto`, `faca`, `por`, `vezes`, `escreva`, `leia`, `verdadeiro`, `falso`, `e`, `ou`, `nao`.
*   **Clareza Estrutural:** Cada instrução principal inicia com o marcador `->` para fácil identificação.
*   **Atribuição Explícita:** Uso do símbolo `:` para atribuição de valores (`variavel : expressao`).
*   **Comparação Intuitiva:** Uso do símbolo `=` para comparação de igualdade (evitando a confusão comum entre `=` e `==`).
*   **Fim de Bloco Conciso:** Uso de `...` para indicar o fim de blocos de código (`se`, `enquanto`, `por`), simplificando a sintaxe de fechamento.
*   **Tipos Básicos:** Suporte inicial para `numero` (inteiros/decimais), `texto`, `logico` (booleano).
*   **Estruturas Essenciais:** Inclui declaração de variáveis, atribuição, condicionais (`se`/`senao se`/`senao`) e loops (`enquanto`/`por N vezes`).
*   **Comentários:** Usa `#` para comentários de linha única.

## Gramática EBNF

A estrutura da IncluaLang é formalmente definida pela seguinte gramática EBNF:

```ebnf
programa ::= { instrucao | comentario_linha } ;

instrucao ::= declaracao | comando ;

declaracao ::= declaracao_variavel ;
comando ::= atribuicao | estrutura_controle | comando_io ;

declaracao_variavel ::= '->' 'guarde' IDENTIFICADOR 'como' tipo [ ':' expressao ] ;
tipo ::= 'numero' | 'texto' | 'logico' ;

atribuicao ::= '->' IDENTIFICADOR ':' expressao ;

estrutura_controle ::= condicional | loop_enquanto | loop_por_vezes ;

condicional ::= '->' 'se' '(' expressao_logica ')' 'entao'
                    bloco_comandos
                [ '->' 'senao' 'se' '(' expressao_logica ')' 'entao'
                    bloco_comandos ]*
                [ '->' 'senao'
                    bloco_comandos ]
                '->' '...' ;

loop_enquanto ::= '->' 'enquanto' '(' expressao_logica ')' 'faca'
                      bloco_comandos
                  '->' '...' ;

loop_por_vezes ::= '->' 'por' expressao_numerica 'vezes' 'faca'
                   bloco_comandos
                   '->' '...' ;

bloco_comandos ::= { instrucao } ;

comando_io ::= comando_escrever | comando_ler ;
comando_escrever ::= '->' 'escreva' '(' expressao { ',' expressao } ')' ;
comando_ler ::= '->' 'leia' '(' IDENTIFICADOR ')' ;

expressao ::= expressao_logica ;

expressao_logica ::= expressao_comparativa { ('e' | 'ou') expressao_comparativa }
                  | 'nao' expressao_comparativa ;

expressao_comparativa ::= expressao_aritmetica [ ('=' | '!=' | '<' | '<=' | '>' | '>=') expressao_aritmetica ] ;

expressao_aritmetica ::= termo { ('+' | '-') termo } ;
termo ::= fator { ('*' | '/') fator } ;
fator ::= numero_literal | texto_literal | logico_literal | IDENTIFICADOR
        | '(' expressao ')' ;

numero_literal ::= DIGITO { DIGITO } [ '.' DIGITO { DIGITO } ] ;
texto_literal ::= '"' { CARACTERE_VALIDO_SEM_ACENTO } '"' ;
logico_literal ::= 'verdadeiro' | 'falso' ;

comentario_linha ::= '#' { QUALQUER_CARACTERE_EXCETO_NOVA_LINHA } NOVA_LINHA ;

IDENTIFICADOR                ::= [a-zA-Z_] [a-zA-Z0-9_]* ;
DIGITO                       ::= '0'..'9' ;
CARACTERE_VALIDO_SEM_ACENTO  ::= ? ;
NOVA_LINHA                   ::= '\n' ;
