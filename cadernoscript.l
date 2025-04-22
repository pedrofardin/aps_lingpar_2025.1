/* cadernoscript.l - Lexer with distinct terminators */
%{
#include <stdio.h>
#include <string.h>
#include "cadernoscript.tab.h" // Make sure this matches Bison output

extern void yyerror(const char *s);
%}

%option noyywrap
%option yylineno

DIGITO          [0-9]
LETRA           [a-zA-Z_]
IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO})*
NUMERO_LITERAL  {DIGITO}+(\.{DIGITO}+)?
TEXTO_LITERAL   \"[^\"\n]*\"
COMENTARIO      #.*

%%
 /* -- Keywords -- */
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
"verdadeiro"    { yylval.sval = strdup(yytext); return T_VERDADEIRO; }
"falso"         { yylval.sval = strdup(yytext); return T_FALSO; }

"fim_se"        { return T_FIM_SE; }
"fim_enquanto"  { return T_FIM_ENQUANTO; }
"fim_por"       { return T_FIM_POR; }


 /* -- Literals -- */
{NUMERO_LITERAL} { yylval.sval = strdup(yytext); return T_NUMERO_LITERAL; }
{TEXTO_LITERAL}  { yylval.sval = strdup(yytext); return T_TEXTO_LITERAL; }

 /* -- Identifier -- */
{IDENTIFICADOR}  { yylval.sval = strdup(yytext); return T_IDENTIFICADOR; }

 /* -- Operators -- */
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

 /* -- Comments and Whitespace -- */
{COMENTARIO}    { /* Ignore */ }
[ \t\r]+        { /* Ignore whitespace/CR */ } /* Keep \r ignore just in case */
\n              { /* Ignore newline */ }

 /* -- Error Handling -- */
.               {
                    fprintf(stderr, "!!! LEXER ERROR RULE !!! char: ASCII %d ('%c') text: \"%s\"\n",
                           (unsigned char)yytext[0], yytext[0], yytext);
                    char msg[256];
                    sprintf(msg, "Caracter inesperado: '%c'", yytext[0]);
                    yyerror(msg);
                }
%%