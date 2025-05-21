# --- Compilador e Flags ---
CC = gcc
CFLAGS = -g -Wall # -g para debug, -Wall para todos os avisos
LDFLAGS = -lfl    # Flag de link para a biblioteca do Flex

# --- Ferramentas ---
FLEX = flex
BISON = bison

# --- Diretórios ---
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin
INTERPRETER_DIR = interpreter
EXAMPLES_DIR = examples

# --- Nomes dos Arquivos de Exemplo Principais ---
VALID_EXAMPLES_FILE = $(EXAMPLES_DIR)/exemplos_validos.caderno
INVALID_EXAMPLES_FILE = $(EXAMPLES_DIR)/exemplos_invalidos.caderno

# --- Arquivos Fonte C ---
LEX_SRC = $(SRC_DIR)/cadernoscript.l
BISON_SRC = $(SRC_DIR)/cadernoscript.y
MAIN_C_SRC = $(SRC_DIR)/main.c

# --- Arquivos Gerados (Caminhos completos) ---
BISON_OUTPUT_C = $(BUILD_DIR)/cadernoscript.tab.c
BISON_OUTPUT_H = $(BUILD_DIR)/cadernoscript.tab.h
LEX_OUTPUT_C = $(BUILD_DIR)/lex.yy.c

# --- Arquivos Objeto (Caminhos completos) ---
BISON_OBJ = $(BUILD_DIR)/cadernoscript.tab.o
LEX_OBJ = $(BUILD_DIR)/lex.yy.o
MAIN_C_OBJ = $(BUILD_DIR)/main.o
OBJS = $(LEX_OBJ) $(BISON_OBJ) $(MAIN_C_OBJ)

# --- Alvo Final (Executável Validador) ---
TARGET_VALIDADOR_NAME = validador_cadernoscript
TARGET_VALIDADOR = $(BIN_DIR)/$(TARGET_VALIDADOR_NAME)

# --- Script Python ---
PYTHON_INTERPRETER = python3
INTERPRETER_SCRIPT = $(INTERPRETER_DIR)/cadernoscript_interpreter.py

# --- Phony Targets (Ações, não arquivos) ---
.PHONY: all clean directories \
        test_validation_validos test_validation_invalidos \
        run_validos run_invalidos run_all_tests \
        test_lex_bison

# --- Alvo Padrão ---
all: directories $(TARGET_VALIDADOR)

# --- Regras de Criação de Diretórios ---
directories:
	@echo "Verificando/Criando diretorios..."
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BIN_DIR)

# --- Regra de Linkagem do Validador ---
$(TARGET_VALIDADOR): $(OBJS) | $(BIN_DIR)
	@echo "Linkando $(TARGET_VALIDADOR_NAME)..."
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

# --- Regra para o Bison ---
$(BISON_OUTPUT_C) $(BISON_OUTPUT_H): $(BISON_SRC) | $(BUILD_DIR)
	@echo "Executando Bison em $(BISON_SRC)..."
	$(BISON) -d -o $(BISON_OUTPUT_C) $(BISON_SRC)
	@if [ -f $(SRC_DIR)/cadernoscript.tab.h ]; then \
		echo "Movendo $(SRC_DIR)/cadernoscript.tab.h para $(BUILD_DIR)/"; \
		mv $(SRC_DIR)/cadernoscript.tab.h $(BISON_OUTPUT_H); \
	else \
		echo "Aviso: $(SRC_DIR)/cadernoscript.tab.h não encontrado para mover. Bison pode ter colocado diretamente em $(BUILD_DIR)."; \
	fi

# --- Regra para o Flex ---
$(LEX_OUTPUT_C): $(LEX_SRC) $(BISON_OUTPUT_H) | $(BUILD_DIR)
	@echo "Executando Flex em $(LEX_SRC)..."
	$(FLEX) -o $(LEX_OUTPUT_C) $(LEX_SRC)

# --- Regras de Compilação de Arquivos .c ---
# Para arquivos .c gerados em BUILD_DIR (lex.yy.c, cadernoscript.tab.c)
$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.c $(BISON_OUTPUT_H)
	@echo "Compilando $< para $@..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -c $< -o $@

# Para arquivos .c em SRC_DIR (main.c)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(BISON_OUTPUT_H)
	@echo "Compilando $< para $@..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -c $< -o $@

# --- Regra de Limpeza ---
clean:
	@echo "Limpando arquivos de build e binários..."
	rm -rf $(BUILD_DIR)
	rm -rf $(BIN_DIR)
	@echo "Limpando arquivos gerados no diretório src (se existirem)..."
	rm -f $(SRC_DIR)/lex.yy.c $(SRC_DIR)/cadernoscript.tab.c $(SRC_DIR)/cadernoscript.tab.h

# --- Alvos de Teste de Validação (apenas validador C) ---
test_validation_validos: $(TARGET_VALIDADOR)
	@echo "--- Testando Validação C com Exemplos Válidos ($(VALID_EXAMPLES_FILE)) ---"
	$(TARGET_VALIDADOR) < $(VALID_EXAMPLES_FILE)

test_validation_invalidos: $(TARGET_VALIDADOR)
	@echo "--- Testando Validação C com Exemplos Inválidos ($(INVALID_EXAMPLES_FILE)) ---"
	@echo "(Esperamos mensagens de erro do validador C para erros léxicos/sintaxe simples)"
	$(TARGET_VALIDADOR) < $(INVALID_EXAMPLES_FILE) || echo "(Validador C reportou erro, como esperado para alguns casos)"


# --- Alvos de Execução Completa (Validador C + Interpretador Python) ---
run_validos: $(TARGET_VALIDADOR)
	@echo ""
	@echo "--- Executando Exemplos Válidos ($(VALID_EXAMPLES_FILE)) ---"
	@echo "Validador C:"
	@if $(TARGET_VALIDADOR) < $(VALID_EXAMPLES_FILE); then \
		echo "[Validador C: OK]"; \
		echo ""; \
		echo "Interpretador Python:"; \
		$(PYTHON_INTERPRETER) $(INTERPRETER_SCRIPT) - < $(VALID_EXAMPLES_FILE); \
	else \
		echo "[Validador C: ERRO (Inesperado para exemplos válidos!)]"; \
		echo "Interpretador Python não será executado."; \
		exit 1; \
	fi

run_invalidos: $(TARGET_VALIDADOR)
	@echo ""
	@echo "--- Executando Exemplos Inválidos ($(INVALID_EXAMPLES_FILE)) ---"
	@echo "Validador C:"
	@if $(TARGET_VALIDADOR) < $(INVALID_EXAMPLES_FILE); then \
		echo "[Validador C: OK (Erro é provavelmente semântico ou sintaxe complexa não pega pelo parser C simples)]"; \
		echo ""; \
		echo "Interpretador Python (esperamos erro aqui):"; \
		! $(PYTHON_INTERPRETER) $(INTERPRETER_SCRIPT) - < $(INVALID_EXAMPLES_FILE) || echo "[Interpretador Python: ERRO NÃO DETECTADO (Inesperado para exemplos inválidos!)]"; \
	else \
		echo "[Validador C: ERRO (Esperado para erros léxicos/sintaxe simples)]"; \
		echo "Interpretador Python não será executado."; \
	fi

# Roda todos os conjuntos de exemplos (válidos e depois inválidos)
run_all_tests: run_validos run_invalidos
	@echo ""
	@echo "--- Todos os conjuntos de exemplos foram processados. ---"
	@echo "Verifique a saida acima para os resultados detalhados de cada conjunto."

# --- Alvo para Testar Geração Flex/Bison ---
test_lex_bison: directories $(LEX_OUTPUT_C) $(BISON_OUTPUT_C) $(BISON_OUTPUT_H)
	@echo "Flex e Bison executados. Arquivos gerados em $(BUILD_DIR):"
	@ls -l $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/cadernoscript.tab.c $(BUILD_DIR)/cadernoscript.tab.h