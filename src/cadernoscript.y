%{
#include <stdio.h>
#include <stdlib.h> // Para free
#include <string.h> // Para strncmp em yyerror

extern int yylex();
extern int yylineno;
extern char *yytext; // yytext é do Flex
extern FILE *yyin;

// Declaração da flag global definida em main.c
extern int syntax_error_occurred;

void yyerror(const char *s);
%}

// %union para compatibilidade com o sval do lexer (se você ainda o usa)
%union {
    char* sval;
}

// Lista todos os tokens que o Flex pode gerar.
%token T_ARROW T_GUARDE T_COMO T_NUMERO T_TEXTO T_LOGICO T_SE T_ENTAO T_SENAO T_FIM_SE
%token T_ENQUANTO T_FACA T_FIM_ENQUANTO T_POR T_VEZES T_FIM_POR T_ESCREVA T_LEIA
%token T_E T_OU T_NAO T_APONTE_LAPIS T_USOS
%token T_COLON T_LPAREN T_RPAREN T_COMMA T_EQ T_NEQ T_LT T_LTE T_GT T_GTE
%token T_PLUS T_MINUS T_MUL T_DIV

// Tokens que vêm com um valor string do Flex (e precisam de free se o lexer faz strdup)
%token <sval> T_IDENTIFICADOR T_NUMERO_LITERAL T_TEXTO_LITERAL T_VERDADEIRO T_FALSO

%start programa_minimo // Pode ser o mesmo nome da sua regra principal original

%%

programa_minimo: /* programa pode ser vazio */
               | lista_de_tokens
               ;

lista_de_tokens: qualquer_token_consumivel
               | lista_de_tokens qualquer_token_consumivel
               ;

// Esta regra consome qualquer token.
// Se o seu lexer usa strdup para os tokens com <sval>, você precisa do free($1).
// Se T_VERDADEIRO/T_FALSO são apenas códigos de token sem valor de string alocado, remova o free deles.
qualquer_token_consumivel:
    T_ARROW | T_GUARDE | T_COMO | T_NUMERO | T_TEXTO | T_LOGICO |
    T_SE | T_ENTAO | T_SENAO | T_FIM_SE |
    T_ENQUANTO | T_FACA | T_FIM_ENQUANTO |
    T_POR | T_VEZES | T_FIM_POR |
    T_ESCREVA | T_LEIA | T_E | T_OU | T_NAO |
    T_APONTE_LAPIS | T_USOS |
    T_COLON | T_LPAREN | T_RPAREN | T_COMMA |
    T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE |
    T_PLUS | T_MINUS | T_MUL T_DIV |
    T_IDENTIFICADOR    { if ($1) free($1); } |
    T_NUMERO_LITERAL { if ($1) free($1); } |
    T_TEXTO_LITERAL  { if ($1) free($1); } |
    T_VERDADEIRO     { if ($1) free($1); } | // Apenas se strdup foi usado no lexer
    T_FALSO          { if ($1) free($1); }   // Apenas se strdup foi usado no lexer
    ;

%%
void yyerror(const char *s) {
    syntax_error_occurred = 1; // <<< AQUI: Seta a flag global de erro
    fprintf(stderr, "Erro na linha %d: ", yylineno);

    // A lógica original de yyerror para distinguir tipos de erro pode ser mantida.
    // O "Caracter inesperado" geralmente vem de uma regra de erro no Flex,
    // "Erro Lexico" também. O default do Bison é "syntax error".
    if (strncmp(s, "Caracter inesperado:", 20) == 0 ||
        strncmp(s, "Erro Lexico:", 12) == 0 ||
        strcmp(s, "syntax error") != 0 ) { // Se a mensagem não é o "syntax error" genérico
        fprintf(stderr, "%s", s); // Imprime a mensagem como está (pode já ter yytext)
    } else { // Para o "syntax error" genérico do Bison
        fprintf(stderr, "erro de sintaxe"); // Mensagem mais amigável
        if (yytext && strlen(yytext) > 0 && strcmp(yytext, "\n") != 0 && strcmp(yytext, "") != 0) {
            fprintf(stderr, " proximo a '%s'", yytext);
        }
    }
    fprintf(stderr, "\n");
}