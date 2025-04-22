/* cadernoscript.y - Using distinct terminators */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *s);
%}

%union { char *sval; }

/* Declare Tokens */
%token T_ARROW T_GUARDE T_COMO T_SE T_ENTAO T_SENAO
%token T_ENQUANTO T_FACA T_POR T_VEZES T_ESCREVA T_LEIA
%token T_E T_OU T_NAO
%token T_COLON T_LPAREN T_RPAREN T_COMMA
%token T_EQ T_NEQ T_LT T_LTE T_GT T_GTE
%token T_PLUS T_MINUS T_MUL T_DIV
%token T_NUMERO T_TEXTO T_LOGICO

/* *** ADDED: New Terminator Tokens *** */
%token T_FIM_SE T_FIM_ENQUANTO T_FIM_POR

/* --- REMOVED --- %token T_ELLIPSIS */

%token <sval> T_IDENTIFICADOR T_NUMERO_LITERAL T_TEXTO_LITERAL T_VERDADEIRO T_FALSO
%type <sval> tipo logico_literal numero_literal texto_literal

/* Operator Precedence */
%right T_NAO %left T_E T_OU %nonassoc T_EQ T_NEQ T_LT T_LTE T_GT T_GTE %left T_PLUS T_MINUS %left T_MUL T_DIV

%start programa

%%

programa: /* empty */
        | instrucao_list_principal
        ;

instrucao_list_principal : instrucao
                         | instrucao_list_principal instrucao
                         ;

/* An instruction must start with T_ARROW */
instrucao: T_ARROW instrucao_corpo
         ;

instrucao_corpo: declaracao_corpo     { printf("Parsed: declaracao (Line %d)\n", yylineno); }
               | comando_corpo        { printf("Parsed: comando (Line %d)\n", yylineno); }
               ;

declaracao_corpo: declaracao_variavel_corpo { printf("Parsed: declaracao_variavel (Line %d)\n", yylineno); } ;
declaracao_variavel_corpo: T_GUARDE T_IDENTIFICADOR T_COMO tipo opt_inicializacao { printf("  Declaring variable %s as %s (Line %d)\n", $2, $4, yylineno); free($2); free($4); } ;
opt_inicializacao: /* empty */ | T_COLON expressao { printf("    With initialization (Line %d)\n", yylineno); } ;
tipo: T_NUMERO { $$ = strdup("numero"); } | T_TEXTO { $$ = strdup("texto"); } | T_LOGICO { $$ = strdup("logico"); } ;

comando_corpo: atribuicao_corpo { printf("Parsed: atribuicao (Line %d)\n", yylineno); }
             | estrutura_controle_corpo { printf("Parsed: estrutura_controle (Line %d)\n", yylineno); }
             | comando_io_corpo { printf("Parsed: comando_io (Line %d)\n", yylineno); }
             ;

atribuicao_corpo: T_IDENTIFICADOR T_COLON expressao { printf("  Assigning to variable %s (Line %d)\n", $1, yylineno); free($1); } ;

estrutura_controle_corpo: condicional_corpo
                        | loop_enquanto_corpo
                        | loop_por_vezes_corpo
                        ;

condicional_corpo: T_SE T_LPAREN expressao_logica T_RPAREN T_ENTAO
                      bloco_comandos
                   lista_senao
                   /* *** CHANGED: Use T_FIM_SE *** */
                   T_FIM_SE
                 { printf("Parsed: condicional (se..entao..) (Line %d)\n", yylineno); }
               ;

/* PROBLEM: lista_senao still starts with T_ARROW. This might cause remaining conflicts */
/* We might need -> senao_bloco ... fim_se */
/* Let's leave it for now and see if only loop terminators were enough */
lista_senao: /* empty */ { printf("    No senao block (Line %d)\n", yylineno); }
           | T_ARROW T_SENAO bloco_comandos { printf("    Senao block (Line %d)\n", yylineno); }
           | T_ARROW T_SENAO T_SE T_LPAREN expressao_logica T_RPAREN T_ENTAO bloco_comandos lista_senao
             { printf("    Senao se block (Line %d)\n", yylineno); }
           ;


loop_enquanto_corpo: T_ENQUANTO T_LPAREN expressao_logica T_RPAREN T_FACA
                         bloco_comandos
                     /* *** CHANGED: Use T_FIM_ENQUANTO *** */
                     T_FIM_ENQUANTO
                   { printf("Parsed: loop_enquanto (Line %d)\n", yylineno); }
                 ;

loop_por_vezes_corpo: T_POR expressao_aritmetica T_VEZES T_FACA
                          bloco_comandos
                      /* *** CHANGED: Use T_FIM_POR *** */
                      T_FIM_POR
                    { printf("Parsed: loop_por_vezes (Line %d)\n", yylineno); }
                  ;


/* Block is zero or more instructions */
bloco_comandos: /* empty */
              | instrucao_list_bloco
              ;

instrucao_list_bloco : instrucao
                     | instrucao_list_bloco instrucao
                     ;


comando_io_corpo: comando_escrever_corpo | comando_ler_corpo ;
comando_escrever_corpo: T_ESCREVA T_LPAREN expressao_list T_RPAREN { printf("Parsed: comando_escrever (Line %d)\n", yylineno); } ;
expressao_list: expressao | expressao_list T_COMMA expressao ;
comando_ler_corpo: T_LEIA T_LPAREN T_IDENTIFICADOR T_RPAREN { printf("Parsed: comando_ler (%s) (Line %d)\n", $3, yylineno); free($3); } ;


/* --- Expression Rules (remain the same) --- */
expressao: expressao_logica { printf("  Parsed: expressao (Line %d)\n", yylineno); } ;
expressao_logica: expressao_comparativa | expressao_logica T_E expressao_comparativa { printf("    Op: E (Line %d)\n", yylineno); } | expressao_logica T_OU expressao_comparativa { printf("    Op: OU (Line %d)\n", yylineno); } | T_NAO expressao_comparativa { printf("    Op: NAO (Line %d)\n", yylineno); } ;
expressao_comparativa: expressao_aritmetica | expressao_aritmetica T_EQ expressao_aritmetica { printf("    Op: = (Line %d)\n", yylineno); } | expressao_aritmetica T_NEQ expressao_aritmetica { printf("    Op: != (Line %d)\n", yylineno); } | expressao_aritmetica T_LT expressao_aritmetica { printf("    Op: < (Line %d)\n", yylineno); } | expressao_aritmetica T_LTE expressao_aritmetica { printf("    Op: <= (Line %d)\n", yylineno); } | expressao_aritmetica T_GT expressao_aritmetica { printf("    Op: > (Line %d)\n", yylineno); } | expressao_aritmetica T_GTE expressao_aritmetica { printf("    Op: >= (Line %d)\n", yylineno); } ;
expressao_aritmetica: termo | expressao_aritmetica T_PLUS termo { printf("    Op: + (Line %d)\n", yylineno); } | expressao_aritmetica T_MINUS termo { printf("    Op: - (Line %d)\n", yylineno); } ;
termo: fator | termo T_MUL fator { printf("    Op: * (Line %d)\n", yylineno); } | termo T_DIV fator { printf("    Op: / (Line %d)\n", yylineno); } ;
fator: numero_literal { printf("    Factor: Number (%s) (Line %d)\n", $1, yylineno); free($1); } | texto_literal { printf("    Factor: Text (%s) (Line %d)\n", $1, yylineno); free($1); } | logico_literal { printf("    Factor: Logical (%s) (Line %d)\n", $1, yylineno); free($1); } | T_IDENTIFICADOR { printf("    Factor: Identifier (%s) (Line %d)\n", $1, yylineno); free($1); } | T_LPAREN expressao T_RPAREN { printf("    Factor: (expression) (Line %d)\n", yylineno); } ;
numero_literal: T_NUMERO_LITERAL { $$ = $1; } ;
texto_literal: T_TEXTO_LITERAL   { $$ = $1; } ;
logico_literal: T_VERDADEIRO     { $$ = $1; } | T_FALSO          { $$ = $1; } ;


%%
/* Standard C code (yyerror, main) */
void yyerror(const char *s) { fprintf(stderr, "Erro na linha %d: ", yylineno); if (strncmp(s, "Caracter inesperado:", 20) == 0) { fprintf(stderr, "%s\n", s); } else { fprintf(stderr, "Erro de Sintaxe"); if (yytext && strlen(yytext) > 0) { fprintf(stderr, " proximo a '%s'", yytext); } else { fprintf(stderr, " (%s)", s); } fprintf(stderr, "\n"); } exit(1); }
int main(int argc, char **argv) { if (argc > 1) { yyin = fopen(argv[1], "r"); if (!yyin) { perror(argv[1]); return 1; } } else { printf("Lendo da entrada padrao...\n"); yyin = stdin; } if (yyparse() == 0) { printf("Analise Sintatica concluida com sucesso!\n"); } else { printf("Analise Sintatica falhou.\n"); } if (yyin != stdin) { fclose(yyin); } return 0; }