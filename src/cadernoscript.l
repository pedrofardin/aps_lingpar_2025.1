%{
#include <stdio.h>
#include <string.h> 
#include "cadernoscript.tab.h" 
%}

%option noyywrap yylineno

COMENTARIO      #.*

%%
 /* Palavras-chave e Símbolos */
"->"            { return T_ARROW; }
"guarde"        { return T_GUARDE; }
"como"          { return T_COMO; }
"numero"        { return T_NUMERO; }
"texto"         { return T_TEXTO; }
"logico"        { return T_LOGICO; }
"se"            { return T_SE; }
"entao"         { return T_ENTAO; }
"senao"         { return T_SENAO; }
"enquanto"      { return T_ENQUANTO; }
"faca"          { return T_FACA; }
"por"           { return T_POR; }
"vezes"         { return T_VEZES; }
"escreva"       { return T_ESCREVA; }
"leia"          { return T_LEIA; }
"e"             { return T_E; }
"ou"            { return T_OU; }
"nao"           { return T_NAO; }
"aponte_lapis"  { return T_APONTE_LAPIS; }
"usos"          { return T_USOS; }
"verdadeiro"    { yylval.sval = strdup(yytext); return T_VERDADEIRO; } 
"falso"         { yylval.sval = strdup(yytext); return T_FALSO; }     

"fim_se"        { return T_FIM_SE; }
"fim_enquanto"  { return T_FIM_ENQUANTO; }
"fim_por"       { return T_FIM_POR; }

 /* Literais e Identificadores */
[0-9]+          { yylval.sval = strdup(yytext); return T_NUMERO_LITERAL; }
\"[^\"\n]*\"    { yylval.sval = strdup(yytext); return T_TEXTO_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return T_IDENTIFICADOR; }

 /* Operadores e Pontuação */
":"             { return T_COLON; }
"("             { return T_LPAREN; }
")"             { return T_RPAREN; } 
","             { return T_COMMA; }
"="             { return T_EQ; }
"!="            { return T_NEQ; }
"<"             { return T_LT; }
"<="            { return T_LTE; }
">"             { return T_GT; }
">="            { return T_GTE; }
"+"             { return T_PLUS; }
"-"             { return T_MINUS; }
"*"             { return T_MUL; }
"/"             { return T_DIV; }

 /* Comentários e Espaço em Branco */
{COMENTARIO}    { /* Ignora */ }
[ \t\r]+        { /* Ignora */ }
\n              { /* Apenas conta a linha (yylineno é incrementado automaticamente por Flex) */ }
                /* Se você precisar que o Bison veja \n como um token, retorne um token aqui. */
                /* Caso contrário, apenas ignorar é bom para a validação da sintaxe dos comandos. */

 /* Erro Léxico */
.               { 
                  char error_msg[100];
                  sprintf(error_msg, "Erro Lexico: Caracter invalido '%c'", yytext[0]);
                  yyerror(error_msg); // Chama yyerror para padronizar o tratamento de erro
                  // Não retorne nada aqui, yyerror deve lidar com a flag de erro.
                  // Ou, se yyerror não parar a análise, você pode precisar de uma estratégia.
                  // No entanto, com fmemopen, yyparse() deve parar após o primeiro erro sério.
                }
%%