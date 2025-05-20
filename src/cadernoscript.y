%{
#include <stdio.h>
#include <stdlib.h> 
#include <string.h> 

extern int yylex();
extern int yylineno;
extern char *yytext; 
extern FILE *yyin;
extern int syntax_error_occurred;
void yyerror(const char *s);
%}

%union {
    char* sval;
}

%token T_ARROW T_GUARDE T_COMO T_NUMERO T_TEXTO T_LOGICO T_SE T_ENTAO T_SENAO T_FIM_SE
%token T_ENQUANTO T_FACA T_FIM_ENQUANTO T_POR T_VEZES T_FIM_POR T_ESCREVA T_LEIA
%token T_E T_OU T_NAO T_APONTE_LAPIS T_USOS
%token T_COLON T_LPAREN T_RPAREN T_COMMA T_EQ T_NEQ T_LT T_LTE T_GT T_GTE
%token T_PLUS T_MINUS T_MUL T_DIV
%token <sval> T_IDENTIFICADOR T_NUMERO_LITERAL T_TEXTO_LITERAL T_VERDADEIRO T_FALSO

%start programa_minimo

%%

programa_minimo: /* programa pode ser vazio */
               | lista_de_tokens
               ;

lista_de_tokens: qualquer_token_consumivel
               | lista_de_tokens qualquer_token_consumivel
               ;

qualquer_token_consumivel:
    T_ARROW | T_GUARDE | T_COMO | T_NUMERO | T_TEXTO | T_LOGICO |
    T_SE | T_ENTAO | T_SENAO | T_FIM_SE |
    T_ENQUANTO | T_FACA | T_FIM_ENQUANTO |
    T_POR | T_VEZES | T_FIM_POR |
    T_ESCREVA | T_LEIA | T_E | T_OU | T_NAO |
    T_APONTE_LAPIS | T_USOS |
    T_COLON | T_LPAREN | T_RPAREN | T_COMMA |
    T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE |
    T_PLUS | T_MINUS | T_MUL | T_DIV |
    T_IDENTIFICADOR    { if ($1) free($1); } |
    T_NUMERO_LITERAL { if ($1) free($1); } |
    T_TEXTO_LITERAL  { if ($1) free($1); } |
    T_VERDADEIRO     { if ($1) free($1); } | 
    T_FALSO          { if ($1) free($1); }  
    ;

%%
void yyerror(const char *s) {
    syntax_error_occurred = 1; 
    fprintf(stderr, "Erro na linha %d: ", yylineno);
    if (strncmp(s, "Caracter inesperado:", 20) == 0 ||
        strncmp(s, "Erro Lexico:", 12) == 0 ||
        strcmp(s, "syntax error") != 0 ) { 
        fprintf(stderr, "%s", s); 
    } else { 
        fprintf(stderr, "erro de sintaxe"); 
        if (yytext && strlen(yytext) > 0 && strcmp(yytext, "\n") != 0 && strcmp(yytext, "") != 0) {
            fprintf(stderr, " proximo a '%s'", yytext);
        }
    }
    fprintf(stderr, "\n");
}