#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Declarações do Flex e Bison
extern int yylex();
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
extern int yyparse();

// Flag de erro sintático
int syntax_error_occurred = 0;

char *input_script_buffer = NULL;
size_t input_script_size = 0;

int main(int argc, char **argv) {
    char line_buffer[2048];
    size_t current_capacity = 0;

    // Aloca buffer inicial
    input_script_buffer = malloc(1);
    if (!input_script_buffer) {
        perror("Erro: Falha ao alocar memória");
        return 1;
    }
    input_script_buffer[0] = '\0';
    current_capacity = 1;

    // Lê todo o script da entrada padrão
    while (fgets(line_buffer, sizeof(line_buffer), stdin)) {
        size_t line_len = strlen(line_buffer);
        if (input_script_size + line_len + 1 > current_capacity) {
            size_t new_capacity = (input_script_size + line_len + 1) * 2;
            if (new_capacity < current_capacity + 2048) {
                new_capacity = current_capacity + 2048;
            }
            char *new_buffer_ptr = realloc(input_script_buffer, new_capacity);
            if (!new_buffer_ptr) {
                perror("Erro: Falha ao realocar buffer do script");
                free(input_script_buffer);
                return 1;
            }
            input_script_buffer = new_buffer_ptr;
            current_capacity = new_capacity;
        }
        strcat(input_script_buffer, line_buffer);
        input_script_size += line_len;
    }

    // Caso o script esteja vazio
    if (input_script_size == 0) {
        free(input_script_buffer);
        return 0;
    }

    // Prepara o parser com o conteúdo lido
    yyin = fmemopen(input_script_buffer, input_script_size, "r");
    if (!yyin) {
        perror("Erro: Falha ao abrir fmemopen");
        free(input_script_buffer);
        return 1;
    }

    // Roda o parser
    yyparse();

    // Se não houve erro, imprime apenas "Sintaxe OK."
    if (!syntax_error_occurred) {
        printf("Sintaxe OK.\n");
    }

    // Libera recursos
    if (yyin) fclose(yyin);
    if (input_script_buffer) free(input_script_buffer);

    return syntax_error_occurred ? 1 : 0;
}
