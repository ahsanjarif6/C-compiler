## C Compiler

## Compiler basics

- **Pattern:** Regex describing all the lexemes that can represent a particular token in source language
- **Lexeme:** Sequence of characters in the source program that matches the pattern for a token
- **Token:** Terminal symbols of the source language


## Classes

- **SymbolInfo:** Holds the details of a symbol
- **ScopeTable:** Keeps track of the declared identifier in a scope
- **SymbolTable:** Keeps track of the scopes
- **ErrorHandler:** Prints out errors
- **Scanner:** Converts input C code to a list of tokens
- **Logger:** Prints out log output
- **Parser:** Creates Abstract Syntax Tree using given cfg and tokens from scanner
- **Tokenizer:** Creates token from a lexeme
- **LexicalAnalyzer:** Converts input C code to stream of tokens
- **SyntaxAnalyzer:** Checks if the grammar is syntactically correct
- **SemanticAnalyzer:** Checks if the grammar is semantically correct
- **AssemblyGenerator:** Converts the C code to Intel 8086 Assembly code
- **Optimizer:** Peephole optimization of the generated assembly code
- **CommentGenerator:** Documentation
- **ASTGenerator:** AST Printer
- **CodeGenerator:** AST to C converter

## Tools

- flex 2.6.4
- bison 3.8.2
