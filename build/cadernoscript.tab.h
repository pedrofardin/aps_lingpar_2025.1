/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_BUILD_CADERNOSCRIPT_TAB_H_INCLUDED
# define YY_YY_BUILD_CADERNOSCRIPT_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_ARROW = 258,                 /* T_ARROW  */
    T_GUARDE = 259,                /* T_GUARDE  */
    T_COMO = 260,                  /* T_COMO  */
    T_NUMERO = 261,                /* T_NUMERO  */
    T_TEXTO = 262,                 /* T_TEXTO  */
    T_LOGICO = 263,                /* T_LOGICO  */
    T_SE = 264,                    /* T_SE  */
    T_ENTAO = 265,                 /* T_ENTAO  */
    T_SENAO = 266,                 /* T_SENAO  */
    T_FIM_SE = 267,                /* T_FIM_SE  */
    T_ENQUANTO = 268,              /* T_ENQUANTO  */
    T_FACA = 269,                  /* T_FACA  */
    T_FIM_ENQUANTO = 270,          /* T_FIM_ENQUANTO  */
    T_POR = 271,                   /* T_POR  */
    T_VEZES = 272,                 /* T_VEZES  */
    T_FIM_POR = 273,               /* T_FIM_POR  */
    T_ESCREVA = 274,               /* T_ESCREVA  */
    T_LEIA = 275,                  /* T_LEIA  */
    T_E = 276,                     /* T_E  */
    T_OU = 277,                    /* T_OU  */
    T_NAO = 278,                   /* T_NAO  */
    T_APONTE_LAPIS = 279,          /* T_APONTE_LAPIS  */
    T_USOS = 280,                  /* T_USOS  */
    T_COLON = 281,                 /* T_COLON  */
    T_LPAREN = 282,                /* T_LPAREN  */
    T_RPAREN = 283,                /* T_RPAREN  */
    T_COMMA = 284,                 /* T_COMMA  */
    T_EQ = 285,                    /* T_EQ  */
    T_NEQ = 286,                   /* T_NEQ  */
    T_LT = 287,                    /* T_LT  */
    T_LTE = 288,                   /* T_LTE  */
    T_GT = 289,                    /* T_GT  */
    T_GTE = 290,                   /* T_GTE  */
    T_PLUS = 291,                  /* T_PLUS  */
    T_MINUS = 292,                 /* T_MINUS  */
    T_MUL = 293,                   /* T_MUL  */
    T_DIV = 294,                   /* T_DIV  */
    T_IDENTIFICADOR = 295,         /* T_IDENTIFICADOR  */
    T_NUMERO_LITERAL = 296,        /* T_NUMERO_LITERAL  */
    T_TEXTO_LITERAL = 297,         /* T_TEXTO_LITERAL  */
    T_VERDADEIRO = 298,            /* T_VERDADEIRO  */
    T_FALSO = 299                  /* T_FALSO  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 14 "src/cadernoscript.y"

    char* sval;

#line 112 "build/cadernoscript.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_BUILD_CADERNOSCRIPT_TAB_H_INCLUDED  */
