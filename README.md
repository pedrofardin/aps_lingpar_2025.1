# IncluaLang - Uma Linguagem de Programação Inclusiva

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) <!-- Você pode escolher outra licença se preferir -->

## Motivação

IncluaLang é uma linguagem de programação experimental projetada com foco na **inclusão** e **acessibilidade**, especialmente para falantes nativos de português e iniciantes em programação. O objetivo principal é reduzir a barreira inicial do aprendizado, utilizando:

*   **Palavras-chave em português:** Tornando o código mais intuitivo para quem não domina o inglês.
*   **Sintaxe clara e explícita:** Minimizar símbolos crípticos e ambiguidades, facilitando a leitura e o entendimento do fluxo do programa.
*   **Estrutura simples:** Foco nos conceitos fundamentais da programação (variáveis, condicionais, loops).

Este projeto foi desenvolvido como parte da disciplina de **[Nome da Disciplina]** em **[Nome da Instituição, se aplicável]** no semestre **[Semestre/Ano]**, visando cumprir os objetivos de criação de uma linguagem com análise léxica/sintática (Flex/Bison) e um mecanismo de execução.

## Características Principais

*   **Sintaxe em Português:** Palavras-chave como `guarde`, `como`, `se`, `entao`, `senao`, `enquanto`, `faca`, `por`, `vezes`, `escreva`, `leia`, `verdadeiro`, `falso`, `e`, `ou`, `nao`.
*   **Clareza Estrutural:** Cada instrução principal inicia com o marcador `->` para fácil identificação.
*   **Atribuição Explícita:** Uso do símbolo `:` para atribuição de valores (`variavel : expressao`).
*   **Comparação Intuitiva:** Uso do símbolo `=` para comparação de igualdade (evitando a confusão comum entre `=` e `==`).
*   **Fim de Bloco Conciso:** Uso de `...` para indicar o fim de blocos de código (`se`, `enquanto`, `por`), simplificando a sintaxe de fechamento.
*   **Tipos Básicos:** Suporte inicial para `numero` (inteiros/decimais), `texto`, `logico` (booleano). O tipo `lista` está definido na gramática para expansão futura.
*   **Estruturas Essenciais:** Inclui declaração de variáveis, atribuição, condicionais (`se`/`senao se`/`senao`) e loops (`enquanto`/`por N vezes`).
*   **Sem Funções (Inicialmente):** Foco na programação imperativa básica para simplificar o escopo inicial.
*   **Comentários:** Usa `#` para comentários de linha única.

## Gramática EBNF (Versão 6)

A estrutura da IncluaLang é formalmente definida pela seguinte gramática EBNF:

```ebnf
(* IncluaLang EBNF - V6: Sem Funções/Acentos, '->', Atribuição ':', Comp '=', Fim '...', Loop 'por' *)

programa ::= { instrucao | comentario_linha } ;

instrucao ::= declaracao | comando ;

declaracao ::= declaracao_variavel ;
comando ::= atribuicao | estrutura_controle | comando_io ;

(* Instruções principais iniciam com '->' *)

declaracao_variavel ::= '->' 'guarde' IDENTIFICADOR 'como' tipo [ ':' expressao ] ;
tipo ::= 'numero' | 'texto' | 'logico' | 'lista' ;

atribuicao ::= '->' IDENTIFICADOR ':' expressao ; (* Atribuição usa ':' *)

estrutura_controle ::= condicional | loop_enquanto | loop_por_vezes ;

condicional ::= '->' 'se' '(' expressao_logica ')' 'entao'
                    bloco_comandos
                [ '->' 'senao' 'se' '(' expressao_logica ')' 'entao'
                    bloco_comandos ]*
                [ '->' 'senao'
                    bloco_comandos ]
                '->' '...' ; (* Fim de bloco com '...' *)

loop_enquanto ::= '->' 'enquanto' '(' expressao_logica ')' 'faca'
                      bloco_comandos
                  '->' '...' ; (* Fim de bloco com '...' *)

(* Loop contado usa 'por' *)
loop_por_vezes ::= '->' 'por' expressao_numerica 'vezes' 'faca'
                   bloco_comandos
                   '->' '...' ;   (* Fim de bloco com '...' *)

bloco_comandos ::= { instrucao } ;

(* --- SEÇÃO DE FUNÇÕES REMOVIDA --- *)

comando_io ::= comando_escrever | comando_ler ;
comando_escrever ::= '->' 'escreva' '(' expressao { ',' expressao } ')' ;
comando_ler ::= '->' 'leia' '(' IDENTIFICADOR ')' ;

expressao ::= expressao_logica ;

expressao_logica ::= expressao_comparativa { ('e' | 'ou') expressao_comparativa }
                  | 'nao' expressao_comparativa ;

expressao_comparativa ::= expressao_aritmetica [ ('=' | '!=' | '<' | '<=' | '>' | '>=') expressao_aritmetica ] ;
                      (* Comparação de igualdade usa '=' *)

expressao_aritmetica ::= termo { ('+' | '-') termo } ;
termo ::= fator { ('*' | '/') fator } ;
fator ::= numero_literal | texto_literal | logico_literal | IDENTIFICADOR
        | '(' expressao ')' ;

numero_literal ::= DIGITO { DIGITO } [ '.' DIGITO { DIGITO } ] ;
texto_literal ::= '"' { CARACTERE_VALIDO_SEM_ACENTO } '"' ;
logico_literal ::= 'verdadeiro' | 'falso' ;

comentario_linha ::= '#' { QUALQUER_CARACTERE_EXCETO_NOVA_LINHA } NOVA_LINHA ;

(* --- Definições Léxicas Implícitas --- *)
IDENTIFICADOR                ::= [a-zA-Z_] [a-zA-Z0-9_]* ;
DIGITO                       ::= '0'..'9' ;
CARACTERE_VALIDO_SEM_ACENTO  ::= ? (* ASCII imprimível exceto " *) ;
NOVA_LINHA                   ::= '\n' ;
TOKEN_INICIO_LINHA           ::= '->' ;
TOKEN_ATRIBUICAO             ::= ':' ;
TOKEN_COMPARACAO_IGUAL       ::= '=' ;
TOKEN_COMPARACAO_DIFERENTE   ::= '!=' ;
TOKEN_COMPARACAO_MENOR       ::= '<' ;
TOKEN_COMPARACAO_MENOR_IGUAL ::= '<=' ;
TOKEN_COMPARACAO_MAIOR       ::= '>' ;
TOKEN_COMPARACAO_MAIOR_IGUAL ::= '>=' ;
TOKEN_LOGICO_E               ::= 'e' ;
TOKEN_LOGICO_OU              ::= 'ou' ;
TOKEN_LOGICO_NAO             ::= 'nao' ;
TOKEN_FIM_BLOCO              ::= '...' ;
KEYWORD_POR                  ::= 'por' ;
(* Outras palavras-chave: guarde, como, numero, texto, logico, lista, se, entao, senao,
   enquanto, faca, vezes, escreva, leia, verdadeiro, falso *)
