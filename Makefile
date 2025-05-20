CC = gcc
CFLAGS = -g -Wall
LDFLAGS = -lfl

FLEX = flex
BISON = bison

SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin
INTERPRETER_DIR = interpreter
EXAMPLES_DIR = examples

LEX_SRC = $(SRC_DIR)/cadernoscript.l
BISON_SRC = $(SRC_DIR)/cadernoscript.y
MAIN_C_SRC = $(SRC_DIR)/main.c

BISON_OUTPUT_C = $(BUILD_DIR)/cadernoscript.tab.c
BISON_OUTPUT_H = $(BUILD_DIR)/cadernoscript.tab.h
LEX_OUTPUT_C = $(BUILD_DIR)/lex.yy.c

BISON_OBJ = $(BUILD_DIR)/cadernoscript.tab.o
LEX_OBJ = $(BUILD_DIR)/lex.yy.o
MAIN_C_OBJ = $(BUILD_DIR)/main.o
OBJS = $(LEX_OBJ) $(BISON_OBJ) $(MAIN_C_OBJ)

TARGET_VALIDADOR_NAME = validador_cadernoscript
TARGET_VALIDADOR = $(BIN_DIR)/$(TARGET_VALIDADOR_NAME)

PYTHON_INTERPRETER = python3
INTERPRETER_SCRIPT = $(INTERPRETER_DIR)/cadernoscript_interpreter.py

.PHONY: all clean directories test_validation run_example test_lex_bison

all: directories $(TARGET_VALIDADOR)

directories:
	@echo "Verificando/Criando diretorios..."
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BIN_DIR)

$(TARGET_VALIDADOR): $(OBJS) | $(BIN_DIR)
	@echo "Linkando $(TARGET_VALIDADOR_NAME)..."
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

$(BISON_OUTPUT_C) $(BISON_OUTPUT_H): $(BISON_SRC) | $(BUILD_DIR)
	@echo "Executando Bison em $(BISON_SRC)..."
	$(BISON) -d -o $(BISON_OUTPUT_C) $(BISON_SRC)
	@if [ -f $(SRC_DIR)/cadernoscript.tab.h ]; then \
		echo "Movendo $(SRC_DIR)/cadernoscript.tab.h para $(BUILD_DIR)/"; \
		mv $(SRC_DIR)/cadernoscript.tab.h $(BISON_OUTPUT_H); \
	else \
		echo "Aviso: $(SRC_DIR)/cadernoscript.tab.h não encontrado para mover. Bison pode ter colocado diretamente em $(BUILD_DIR)."; \
	fi

$(LEX_OUTPUT_C): $(LEX_SRC) $(BISON_OUTPUT_H) | $(BUILD_DIR)
	@echo "Executando Flex em $(LEX_SRC)..."
	$(FLEX) -o $(LEX_OUTPUT_C) $(LEX_SRC)

$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.c $(BISON_OUTPUT_H)
	@echo "Compilando $< para $@..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(BISON_OUTPUT_H)
	@echo "Compilando $< para $@..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -c $< -o $@

clean:
	@echo "Limpando arquivos de build e binários..."
	rm -rf $(BUILD_DIR)
	rm -rf $(BIN_DIR)
	@echo "Limpando arquivos gerados no diretório src (se existirem)..."
	rm -f $(SRC_DIR)/lex.yy.c $(SRC_DIR)/cadernoscript.tab.c $(SRC_DIR)/cadernoscript.tab.h

test_validation: $(TARGET_VALIDADOR)
	@echo "Testando validação com $(EXAMPLES_DIR)/meu_programa.caderno..."
	$(TARGET_VALIDADOR) < $(EXAMPLES_DIR)/meu_programa.caderno

run_example: $(TARGET_VALIDADOR)
	@echo "Executando validador e interpretador com meu_programa.caderno..."
	@$(TARGET_VALIDADOR) < $(EXAMPLES_DIR)/meu_programa.caderno > /dev/null && \
	$(PYTHON_INTERPRETER) $(INTERPRETER_SCRIPT) - < $(EXAMPLES_DIR)/meu_programa.caderno || \
	echo "Erro de sintaxe. Interpretador não será executado."

# Novo: Roda o arquivo de testes mínimos
run_minimos: $(TARGET_VALIDADOR)
	@echo "Executando validador e interpretador com testes_minimos.caderno..."
	@$(TARGET_VALIDADOR) < $(EXAMPLES_DIR)/testes_minimos.caderno > /dev/null && \
	$(PYTHON_INTERPRETER) $(INTERPRETER_SCRIPT) - < $(EXAMPLES_DIR)/testes_minimos.caderno || \
	echo "Erro de sintaxe. Interpretador não será executado."

# Roda ambos os testes
run_all_examples: run_example run_minimos
	@echo "Todos os exemplos foram executados."

test_lex_bison: directories $(LEX_OUTPUT_C) $(BISON_OUTPUT_C) $(BISON_OUTPUT_H)
	@echo "Flex e Bison executados. Arquivos gerados em $(BUILD_DIR):"
	@ls -l $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/cadernoscript.tab.c $(BUILD_DIR)/cadernoscript.tab.h