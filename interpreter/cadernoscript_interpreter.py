import sys
from abc import ABC, abstractmethod
import os

ponta_do_lapis_restante = 0
USOS_PADRAO_LAPIS = 5

class SymbolTableCS:
    def __init__(self):
        self.table = {}

    def create(self, identifier, value, cs_type):
        if identifier in self.table:
            raise NameError(f"Variavel '{identifier}' ja definida")
        if cs_type not in ['numero', 'texto', 'logico']:
            raise TypeError(f"Tipo desconhecido '{cs_type}' para variavel '{identifier}'")
        self.table[identifier] = (value, cs_type)

    def getter(self, identifier):
        if identifier not in self.table:
            raise NameError(f"Variavel '{identifier}' nao definida")
        return self.table[identifier]

    def setter(self, identifier, value_to_set):
        if identifier not in self.table:
            raise NameError(f"Variavel '{identifier}' nao definida")
        _current_value, declared_cs_type = self.table[identifier]
        value_cs_type_str = None
        if isinstance(value_to_set, bool): value_cs_type_str = 'logico'
        elif isinstance(value_to_set, int): value_cs_type_str = 'numero'
        elif isinstance(value_to_set, str): value_cs_type_str = 'texto'
        else:
            raise TypeError(f"Erro Interno: Tipo Python nao suportado '{type(value_to_set).__name__}' para atribuicao na variavel '{identifier}'")
        if declared_cs_type != value_cs_type_str:
            raise TypeError(f"Erro de tipo: nao pode atribuir valor do tipo '{value_cs_type_str}' para variavel '{identifier}' declarada como '{declared_cs_type}'")
        self.table[identifier] = (value_to_set, declared_cs_type)

class NodeCS(ABC):
    def __init__(self, value, children=None, lineno=0): # Adicionado lineno
        self.value = value
        self.children = children if children is not None else []
        self.lineno = lineno # Armazena o número da linha

    @abstractmethod
    def Evaluate(self, symbol_table: SymbolTableCS):
        pass

class BlocoCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        for child in self.children:
            child.Evaluate(symbol_table)

class GuardeCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        identifier_name = self.children[0].value
        cs_declared_type = self.children[1].value
        inicial_value = None
        if len(self.children) > 2:
            value_tuple = self.children[2].Evaluate(symbol_table)
            inicial_value, python_inicial_type = value_tuple
            if cs_declared_type != python_inicial_type:
                raise TypeError(f"Erro de tipo na linha {self.lineno}: nao pode inicializar variavel '{identifier_name}' do tipo '{cs_declared_type}' com valor do tipo '{python_inicial_type}'")
        else:
            if cs_declared_type == 'numero': inicial_value = 0
            elif cs_declared_type == 'texto': inicial_value = ""
            elif cs_declared_type == 'logico': inicial_value = False
        symbol_table.create(identifier_name, inicial_value, cs_declared_type)

class AtribuicaoCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        identifier_name = self.children[0].value
        try:
            value_tuple = self.children[1].Evaluate(symbol_table)
            value_to_assign, _ = value_tuple
            symbol_table.setter(identifier_name, value_to_assign)
        except TypeError as e:
            raise TypeError(f"{e} (atribuicao na linha {self.lineno})")
        except NameError as e:
            raise NameError(f"{e} (atribuicao na linha {self.lineno})")


class EscrevaCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        global ponta_do_lapis_restante
        if ponta_do_lapis_restante <= 0:
            print(f"AVISO (Linha {self.lineno}): Lapis sem ponta! Use '-> aponte_lapis'. Saida suprimida.", file=sys.stderr)
            return
        outputs = []
        for child_expr in self.children:
            value_tuple = child_expr.Evaluate(symbol_table)
            value_to_print, value_type = value_tuple
            if value_type == 'logico':
                outputs.append("verdadeiro" if value_to_print else "falso")
            else:
                outputs.append(str(value_to_print))
        print(" ".join(outputs))
        ponta_do_lapis_restante -= 1
        if ponta_do_lapis_restante < 0: ponta_do_lapis_restante = 0

class LeiaCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        identifier_name = self.children[0].value
        _, declared_cs_type = symbol_table.getter(identifier_name)
        try:
            user_input = input()
            if declared_cs_type == 'numero': value_to_set = int(user_input)
            elif declared_cs_type == 'logico':
                if user_input.lower() == 'verdadeiro': value_to_set = True
                elif user_input.lower() == 'falso': value_to_set = False
                else: raise ValueError("Entrada para logico deve ser 'verdadeiro' ou 'falso'")
            elif declared_cs_type == 'texto': value_to_set = user_input
            else: raise TypeError(f"Tipo de variavel desconhecido '{declared_cs_type}' para leia")
            symbol_table.setter(identifier_name, value_to_set)
        except ValueError as e:
            raise TypeError(f"Entrada invalida '{user_input}' para variavel '{identifier_name}' do tipo {declared_cs_type} na linha {self.lineno}. Detalhe: {e}")
        except Exception as e:
            raise Exception(f"{e} (leia na linha {self.lineno})")


class AponteLapisCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        global ponta_do_lapis_restante, USOS_PADRAO_LAPIS
        if self.children:
            usos_tuple = self.children[0].Evaluate(symbol_table)
            usos_val, usos_type = usos_tuple
            if usos_type != 'numero':
                raise TypeError(f"'aponte_lapis por N usos' requer N do tipo numero (linha {self.lineno}), obteve {usos_type}")
            if usos_val < 0:
                 raise ValueError(f"Numero de usos para 'aponte_lapis' nao pode ser negativo (linha {self.lineno}), obteve {usos_val}")
            ponta_do_lapis_restante = usos_val
        else:
            ponta_do_lapis_restante = USOS_PADRAO_LAPIS
        print(f"INFO (Linha {self.lineno}): Lapis apontado! {ponta_do_lapis_restante} usos restantes.", file=sys.stderr)


class SeCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        condition_tuple = self.children[0].Evaluate(symbol_table)
        condition_val, condition_type = condition_tuple
        if condition_type != 'logico':
            raise TypeError(f"Condicao do 'se' deve ser do tipo logico (linha {self.lineno}), obteve {condition_type}")
        if condition_val:
            self.children[1].Evaluate(symbol_table)
        elif len(self.children) > 2 and self.children[2] is not None:
            self.children[2].Evaluate(symbol_table)

class EnquantoCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        while True:
            condition_tuple = self.children[0].Evaluate(symbol_table)
            condition_val, condition_type = condition_tuple
            if condition_type != 'logico':
                raise TypeError(f"Condicao do 'enquanto' deve ser do tipo logico (linha {self.lineno}), obteve {condition_type}")
            if not condition_val:
                break
            self.children[1].Evaluate(symbol_table)

class PorVezesCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        count_tuple = self.children[0].Evaluate(symbol_table)
        count_val, count_type = count_tuple
        if count_type != 'numero':
            raise TypeError(f"Contador do 'por vezes' deve ser do tipo numero (linha {self.lineno}), obteve {count_type}")
        if count_val < 0:
            raise ValueError(f"Contador do 'por vezes' nao pode ser negativo (linha {self.lineno}), obteve {count_val}")
        for _ in range(count_val):
            self.children[1].Evaluate(symbol_table)

class BinOpCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        left_tuple = self.children[0].Evaluate(symbol_table)
        right_tuple = self.children[1].Evaluate(symbol_table)
        left_val, left_type = left_tuple
        right_val, right_type = right_tuple
        op = self.value
        err_line = self.lineno # Linha da operação binária
        
        try:
            if op in ['+', '-', '*', '/']:
               if left_type != 'numero' or right_type != 'numero':
                    raise TypeError(f"Operador aritmetico '{op}' requer operandos do tipo numero, obteve {left_type} e {right_type}")
            if op in ['e', 'ou']:
                if left_type != 'logico' or right_type != 'logico':
                     raise TypeError(f"Operador logico '{op}' requer operandos do tipo logico, obteve {left_type} e {right_type}")
            if op in ['<', '<=', '>', '>='] and left_type != right_type:
                if not (left_type == 'numero' and right_type == 'numero'):
                     pass 

            if op == "+": return (left_val + right_val, 'numero')
            elif op == "-": return (left_val - right_val, 'numero')
            elif op == "*": return (left_val * right_val, 'numero')
            elif op == "/":
                if right_val == 0: raise ZeroDivisionError("Divisao por zero")
                return (int(left_val / right_val), 'numero')
            elif op == "e": return (left_val and right_val, 'logico')
            elif op == "ou": return (left_val or right_val, 'logico')
            elif op == "=": return (left_val == right_val, 'logico')
            elif op == "!=": return (left_val != right_val, 'logico')
            elif op == "<": return (left_val < right_val, 'logico')
            elif op == "<=": return (left_val <= right_val, 'logico')
            elif op == ">": return (left_val > right_val, 'logico')
            elif op == ">=": return (left_val >= right_val, 'logico')
            else:
                raise ValueError(f"Operador binario CadernoScript invalido: {op}")
        except TypeError as e:
            raise TypeError(f"{e} (operacao na linha {err_line})")
        except ZeroDivisionError as e:
            raise ZeroDivisionError(f"{e} (operacao na linha {err_line})")


class UnOpCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        child_tuple = self.children[0].Evaluate(symbol_table)
        child_val, child_type = child_tuple
        op = self.value
        err_line = self.lineno

        try:
            if op == '-' and child_type != 'numero':
                raise TypeError(f"Operador unario '-' requer operando do tipo numero, obteve {child_type}")
            if op == 'nao' and child_type != 'logico':
                raise TypeError(f"Operador unario 'nao' requer operando do tipo logico, obteve {child_type}")

            if op == "-": return (-child_val, 'numero')
            elif op == "nao": return (not child_val, 'logico')
            elif op == "+": return (child_val, child_type)
            else:
                raise ValueError(f"Operador unario CadernoScript invalido: {op}")
        except TypeError as e:
            raise TypeError(f"{e} (operacao na linha {err_line})")


class IdentifierCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS):
        try:
            return symbol_table.getter(self.value)
        except NameError as e:
            raise NameError(f"{e} (usado na linha {self.lineno})")


class NumeroLiteralCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS = None):
        return (self.value, 'numero')

class TextoLiteralCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS = None):
        return (self.value, 'texto')

class LogicoLiteralCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS = None):
        return (self.value, 'logico')

class TipoCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS = None):
        return self.value

class NoOpCS(NodeCS):
    def Evaluate(self, symbol_table: SymbolTableCS = None):
        pass

class TokenCS:
    def __init__(self, type: str, value, lineno=0):
        self.type = type
        self.value = value
        self.lineno = lineno
    def __repr__(self):
        return f"TokenCS({self.type}, {repr(self.value)}, L{self.lineno})"

class TokenizerCS:
    def __init__(self, source: str):
        self.source = source
        self.position = 0
        self.lineno = 1
        self.current_char = self.source[self.position] if self.position < len(self.source) else None
        self.next_token_obj = None
        self.RESERVED_KEYWORDS = {
            "guarde": "GUARDE", "como": "COMO",
            "se": "SE", "entao": "ENTAO", "senao": "SENAO", "fim_se": "FIM_SE",
            "enquanto": "ENQUANTO", "faca": "FACA", "fim_enquanto": "FIM_ENQUANTO",
            "por": "POR", "vezes": "VEZES", "fim_por": "FIM_POR",
            "escreva": "ESCREVA", "leia": "LEIA",
            "e": "OP_E", "ou": "OP_OU", "nao": "OP_NAO",
            "aponte_lapis": "APONTE_LAPIS", "usos": "USOS"
        }
        self.select_next()

    def advance(self):
        if self.current_char == '\n':
            self.lineno += 1
        self.position += 1
        if self.position < len(self.source):
            self.current_char = self.source[self.position]
        else:
            self.current_char = None

    def skip_whitespace_and_comments(self):
        while self.current_char is not None:
            if self.current_char.isspace():
                self.advance()
            elif self.current_char == '#':
                while self.current_char is not None and self.current_char != '\n':
                    self.advance()
            else:
                break
    
    def get_integer(self):
        result = ""
        while self.current_char is not None and self.current_char.isdigit():
            result += self.current_char
            self.advance()
        return int(result)

    def get_string_literal(self):
        self.advance() 
        result = ""
        while self.current_char is not None and self.current_char != '"':
            result += self.current_char
            self.advance()
        if self.current_char != '"':
            raise SyntaxError(f"String literal nao terminada na linha {self.lineno}")
        self.advance() 
        return result

    def get_identifier_or_keyword(self):
        token_lineno = self.lineno 
        result = ""
        while self.current_char is not None and \
              (self.current_char.isalnum() or self.current_char == '_'):
            result += self.current_char
            self.advance()
        
        if result == "verdadeiro": return TokenCS("LOGICO_LITERAL", True, token_lineno)
        if result == "falso": return TokenCS("LOGICO_LITERAL", False, token_lineno)
        if result == "numero": return TokenCS("TIPO_LITERAL", "numero", token_lineno)
        if result == "texto": return TokenCS("TIPO_LITERAL", "texto", token_lineno)
        if result == "logico": return TokenCS("TIPO_LITERAL", "logico", token_lineno)
            
        token_category = self.RESERVED_KEYWORDS.get(result) 
        if token_category:
            return TokenCS(token_category, result, token_lineno)
        else:
            if result and (result[0].isalpha() or result[0] == '_'):
                return TokenCS("IDENTIFIER", result, token_lineno)
            else:
                if result: 
                    raise SyntaxError(f"Identificador invalido '{result}' na linha {token_lineno}")
        
        if self.current_char is not None:
             raise SyntaxError(f"Logica de tokenizacao falhou para '{result}' perto de '{self.current_char}' na linha {self.lineno}")
        return TokenCS("EOF", None, self.lineno)


    def select_next(self):
        current_select_lineno = self.lineno
        self.skip_whitespace_and_comments()
        current_select_lineno = self.lineno # Update after skipping

        if self.current_char is None:
            self.next_token_obj = TokenCS("EOF", None, current_select_lineno)
            return

        if self.current_char == '-' and self.position + 1 < len(self.source) and self.source[self.position+1] == '>':
            self.advance()
            self.advance()
            self.next_token_obj = TokenCS("ARROW", "->", current_select_lineno)
            return
        
        if self.current_char.isdigit():
            self.next_token_obj = TokenCS("NUMERO_LITERAL", self.get_integer(), current_select_lineno)
            return
        
        if self.current_char == '"':
            self.next_token_obj = TokenCS("TEXTO_LITERAL", self.get_string_literal(), current_select_lineno)
            return

        if self.current_char.isalnum() or self.current_char == '_':
            self.next_token_obj = self.get_identifier_or_keyword()
            # get_identifier_or_keyword já define o lineno do token que retorna
            return

        simple_ops = {
            ':': "COLON", '(': "LPAREN", ')': "RPAREN", ',': "COMMA",
            '+': "OP_PLUS", '-': "OP_MINUS", '*': "OP_MUL", '/': "OP_DIV",
            '=': "OP_EQ", 
        }
        if self.current_char in simple_ops:
            op_char = self.current_char
            self.advance()
            self.next_token_obj = TokenCS(simple_ops[op_char], op_char, current_select_lineno)
            return

        if self.current_char == '!' and self.position + 1 < len(self.source) and self.source[self.position+1] == '=':
            self.advance(); self.advance()
            self.next_token_obj = TokenCS("OP_NEQ", "!=", current_select_lineno)
            return
        if self.current_char == '<' and self.position + 1 < len(self.source) and self.source[self.position+1] == '=':
            self.advance(); self.advance()
            self.next_token_obj = TokenCS("OP_LTE", "<=", current_select_lineno)
            return
        if self.current_char == '>' and self.position + 1 < len(self.source) and self.source[self.position+1] == '=':
            self.advance(); self.advance()
            self.next_token_obj = TokenCS("OP_GTE", ">=", current_select_lineno)
            return
        
        if self.current_char == '<':
            self.advance()
            self.next_token_obj = TokenCS("OP_LT", "<", current_select_lineno)
            return
        if self.current_char == '>':
            self.advance()
            self.next_token_obj = TokenCS("OP_GT", ">", current_select_lineno)
            return
            
        raise SyntaxError(f"Caracter inesperado '{self.current_char}' na linha {self.lineno}")


class ParserCS:
    def __init__(self, tokenizer: TokenizerCS):
        self.tokenizer = tokenizer
        self.current_token = self.tokenizer.next_token_obj

    def error(self, expected_type=None, found_token=None):
        found_token = found_token or self.current_token
        msg_line = found_token.lineno if found_token else self.tokenizer.lineno
        if expected_type:
            raise SyntaxError(f"Erro de sintaxe na linha {msg_line}: Esperado {expected_type}, mas encontrado {found_token.type if found_token else 'N/A'} ('{found_token.value if found_token else 'N/A'}')")
        else:
            raise SyntaxError(f"Erro de sintaxe na linha {msg_line}: Token inesperado {found_token.type if found_token else 'N/A'} ('{found_token.value if found_token else 'N/A'}')")

    def eat(self, token_type):
        if self.current_token.type == token_type:
            consumed_token = self.current_token
            self.tokenizer.select_next()
            self.current_token = self.tokenizer.next_token_obj
            return consumed_token
        else:
            self.error(expected_type=token_type)
    
    def parse_programa(self) -> BlocoCS:
        statements = []
        prog_lineno = self.current_token.lineno
        while self.current_token.type != "EOF":
            statements.append(self.parse_instrucao())
        return BlocoCS("PROGRAM_ROOT", statements, lineno=prog_lineno)

    def parse_instrucao(self) -> NodeCS:
        start_token = self.current_token
        if self.current_token.type == "ARROW":
            self.eat("ARROW")
            return self.parse_instrucao_com_seta_subjacente(start_token.lineno)
        elif self.current_token.type in ["SE", "ENQUANTO", "POR"]:
            return self.parse_estrutura_controle_inicio_sem_seta(start_token.lineno)
        else:
            self.error(expected_type="ARROW ou inicio de estrutura de controle")
            
    def parse_estrutura_controle_inicio_sem_seta(self, lineno) -> NodeCS:
        if self.current_token.type == "SE": return self.parse_condicional(lineno)
        elif self.current_token.type == "ENQUANTO": return self.parse_loop_enquanto(lineno)
        elif self.current_token.type == "POR": return self.parse_loop_por_vezes(lineno)
        else: self.error()

    def parse_instrucao_com_seta_subjacente(self, lineno) -> NodeCS:
        if self.current_token.type == "GUARDE": return self.parse_declaracao(lineno)
        elif self.current_token.type == "IDENTIFIER": return self.parse_atribuicao(lineno)
        elif self.current_token.type == "ESCREVA": return self.parse_comando_escrever(lineno)
        elif self.current_token.type == "LEIA": return self.parse_comando_ler(lineno)
        elif self.current_token.type == "APONTE_LAPIS": return self.parse_aponte_lapis(lineno)
        else: self.error(expected_type="GUARDE, IDENTIFIER (para atribuicao), ESCREVA, LEIA, ou APONTE_LAPIS")

    def parse_declaracao(self, lineno) -> GuardeCS:
        self.eat("GUARDE")
        ident_node = IdentifierCS(self.eat("IDENTIFIER").value, lineno=lineno)
        self.eat("COMO")
        tipo_token = self.eat("TIPO_LITERAL")
        tipo_node = TipoCS(tipo_token.value, lineno=tipo_token.lineno)
        expr_node = None
        if self.current_token.type == "COLON":
            self.eat("COLON")
            expr_node = self.parse_expressao()
        children = [ident_node, tipo_node]
        if expr_node: children.append(expr_node)
        return GuardeCS("GUARDE", children, lineno=lineno)

    def parse_atribuicao(self, lineno) -> AtribuicaoCS:
        ident_node = IdentifierCS(self.eat("IDENTIFIER").value, lineno=lineno)
        self.eat("COLON")
        expr_node = self.parse_expressao()
        return AtribuicaoCS("ATRIBUICAO", [ident_node, expr_node], lineno=lineno)

    def parse_comando_escrever(self, lineno) -> EscrevaCS:
        self.eat("ESCREVA")
        self.eat("LPAREN")
        expr_list = []
        if self.current_token.type != "RPAREN":
            expr_list.append(self.parse_expressao())
            while self.current_token.type == "COMMA":
                self.eat("COMMA")
                expr_list.append(self.parse_expressao())
        self.eat("RPAREN")
        return EscrevaCS("ESCREVA", expr_list, lineno=lineno)

    def parse_comando_ler(self, lineno) -> LeiaCS:
        self.eat("LEIA")
        self.eat("LPAREN")
        ident_node = IdentifierCS(self.eat("IDENTIFIER").value, lineno=self.current_token.lineno)
        self.eat("RPAREN")
        return LeiaCS("LEIA", [ident_node], lineno=lineno)

    def parse_aponte_lapis(self, lineno) -> AponteLapisCS:
        self.eat("APONTE_LAPIS")
        usos_expr_node = None
        if self.current_token.type == "POR":
            self.eat("POR")
            usos_expr_node = self.parse_expressao_aritmetica(self.current_token.lineno)
            self.eat("USOS")
        return AponteLapisCS("APONTE_LAPIS", [usos_expr_node] if usos_expr_node else [], lineno=lineno)

    def parse_condicional(self, lineno) -> SeCS:
        self.eat("SE")
        self.eat("LPAREN")
        cond_node = self.parse_expressao_logica(self.current_token.lineno)
        self.eat("RPAREN")
        self.eat("ENTAO")
        bloco_entao = self.parse_bloco_comandos()
        bloco_senao = None
        if self.current_token.type == "SENAO":
            self.eat("SENAO")
            bloco_senao = self.parse_bloco_comandos()
        self.eat("FIM_SE")
        children = [cond_node, bloco_entao]
        if bloco_senao: children.append(bloco_senao)
        return SeCS("SE", children, lineno=lineno)

    def parse_loop_enquanto(self, lineno) -> EnquantoCS:
        self.eat("ENQUANTO")
        self.eat("LPAREN")
        cond_node = self.parse_expressao_logica(self.current_token.lineno)
        self.eat("RPAREN")
        self.eat("FACA")
        bloco_faca = self.parse_bloco_comandos()
        self.eat("FIM_ENQUANTO")
        return EnquantoCS("ENQUANTO", [cond_node, bloco_faca], lineno=lineno)

    def parse_loop_por_vezes(self, lineno) -> PorVezesCS:
        self.eat("POR")
        contador_expr_node = self.parse_expressao_aritmetica(self.current_token.lineno)
        self.eat("VEZES")
        self.eat("FACA")
        bloco_faca = self.parse_bloco_comandos()
        self.eat("FIM_POR")
        return PorVezesCS("POR_VEZES", [contador_expr_node, bloco_faca], lineno=lineno)

    def parse_bloco_comandos(self) -> BlocoCS:
        statements = []
        block_lineno = self.current_token.lineno
        stop_tokens = ["SENAO", "FIM_SE", "FIM_ENQUANTO", "FIM_POR", "EOF"]
        while self.current_token.type not in stop_tokens:
            statements.append(self.parse_instrucao())
            if self.current_token.type in stop_tokens: break
        if not statements:
            return BlocoCS("BLOCO_VAZIO", [NoOpCS("NOOP", lineno=block_lineno)], lineno=block_lineno)
        return BlocoCS("BLOCO", statements, lineno=block_lineno)

    def parse_expressao(self) -> NodeCS:
        # Lineno para expressões é mais complexo, pegamos do primeiro token da expressão
        return self.parse_expressao_logica(self.current_token.lineno)

    def parse_expressao_logica(self, lineno) -> NodeCS:
        if self.current_token.type == "OP_NAO":
            op_token = self.eat("OP_NAO")
            node = UnOpCS(op_token.value, [self.parse_expressao_logica(self.current_token.lineno)], lineno=lineno)
            return node
        node = self.parse_expressao_comparativa(lineno)
        while self.current_token.type in ["OP_E", "OP_OU"]:
            op_token = self.eat(self.current_token.type)
            right_node = self.parse_expressao_comparativa(self.current_token.lineno)
            node = BinOpCS(op_token.value, [node, right_node], lineno=node.lineno) # Usa lineno do nó esquerdo
        return node
        
    def parse_expressao_comparativa(self, lineno) -> NodeCS:
        node = self.parse_expressao_aritmetica(lineno)
        if self.current_token.type in ["OP_EQ", "OP_NEQ", "OP_LT", "OP_LTE", "OP_GT", "OP_GTE"]:
            op_token = self.eat(self.current_token.type)
            right_node = self.parse_expressao_aritmetica(self.current_token.lineno)
            node = BinOpCS(op_token.value, [node, right_node], lineno=node.lineno)
        return node

    def parse_expressao_aritmetica(self, lineno) -> NodeCS:
        node = self.parse_termo(lineno)
        while self.current_token.type in ["OP_PLUS", "OP_MINUS"]:
            op_token = self.eat(self.current_token.type)
            right_node = self.parse_termo(self.current_token.lineno)
            node = BinOpCS(op_token.value, [node, right_node], lineno=node.lineno)
        return node

    def parse_termo(self, lineno) -> NodeCS:
        node = self.parse_fator(lineno)
        while self.current_token.type in ["OP_MUL", "OP_DIV"]:
            op_token = self.eat(self.current_token.type)
            right_node = self.parse_fator(self.current_token.lineno)
            node = BinOpCS(op_token.value, [node, right_node], lineno=node.lineno)
        return node

    def parse_fator(self, lineno) -> NodeCS:
        token = self.current_token
        current_lineno = token.lineno # Linha do token atual que forma o fator
        if token.type == "NUMERO_LITERAL":
            self.eat("NUMERO_LITERAL")
            return NumeroLiteralCS(token.value, lineno=current_lineno)
        elif token.type == "TEXTO_LITERAL":
            self.eat("TEXTO_LITERAL")
            return TextoLiteralCS(token.value, lineno=current_lineno)
        elif token.type == "LOGICO_LITERAL":
            self.eat("LOGICO_LITERAL")
            return LogicoLiteralCS(token.value, lineno=current_lineno)
        elif token.type == "IDENTIFIER":
            self.eat("IDENTIFIER")
            return IdentifierCS(token.value, lineno=current_lineno)
        elif token.type == "LPAREN":
            self.eat("LPAREN")
            node = self.parse_expressao() # parse_expressao pegará seu próprio lineno
            self.eat("RPAREN")
            return node # O nó da expressão já tem seu lineno
        elif token.type in ["OP_PLUS", "OP_MINUS"]:
            op_token = self.eat(token.type)
            factor_node = self.parse_fator(self.current_token.lineno)
            return UnOpCS(op_token.value, [factor_node], lineno=current_lineno)
        else:
            self.error(expected_type="LITERAL, IDENTIFICADOR, LPAREN ou OPERADOR UNARIO")

def run_cadernoscript(source_code: str):
    global ponta_do_lapis_restante, USOS_PADRAO_LAPIS
    ponta_do_lapis_restante = 0 
    USOS_PADRAO_LAPIS = 5
    tokenizer = TokenizerCS(source_code)
    parser = ParserCS(tokenizer)
    ast_root = parser.parse_programa()
    symbol_table = SymbolTableCS()
    try:
        ast_root.Evaluate(symbol_table)
    except Exception as e:
        error_line = parser.current_token.lineno if hasattr(parser, 'current_token') and parser.current_token else 'desconhecida'
        # Tenta obter a linha do erro da própria exceção, se for uma exceção customizada com linha
        if hasattr(e, '__cause__') and hasattr(e.__cause__, 'lineno'): # Exemplo, não padrão
             error_line = e.__cause__.lineno
        elif hasattr(e, 'lineno'): # Se a exceção em si tiver um atributo lineno
             error_line = e.lineno
        
        print(f"Erro de Execucao (linha aprox. {error_line}): {type(e).__name__} - {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python cadernoscript_interpreter.py <arquivo_cadernoscript.cs | -> para stdin")
        sys.exit(1)
    input_source = ""
    if sys.argv[1] == '-':
        input_source = sys.stdin.read()
    else:
        try:
            with open(sys.argv[1], 'r', encoding='utf-8') as f:
                input_source = f.read()
        except FileNotFoundError:
            print(f"Erro: Arquivo '{sys.argv[1]}' nao encontrado.", file=sys.stderr)
            sys.exit(1)
        except Exception as e:
            print(f"Erro ao ler arquivo '{sys.argv[1]}': {e}", file=sys.stderr)
            sys.exit(1)
    if not input_source.strip():
        print("Aviso: Arquivo de entrada ou stream esta vazio.", file=sys.stderr)
    else:
        run_cadernoscript(input_source)