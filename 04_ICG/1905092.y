%{
#pragma once
#include<bits/stdc++.h>
#include "1905092_SymbolTable.h"
#include "1905092_ScopeTable.h"
#include "1905092_SymbolInfo.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *logout;
FILE *logError;
ofstream errorOut , dataSegOut;
fstream  codeSegOut; 
extern int yylineno;
extern int line_count;
int err_count = 0;
bool arrayIndex=false;
bool globalScope=true;
bool isMain=true;
int offset =0 ;
int labelCount=0;
SymbolTable *table = new SymbolTable(11) ;
vector<SymbolInfo*>*List = NULL;
bool debug = true;

void yyerror(char *s)
{
	//write your code
}

string newLabel(){
    return "L_" + to_string(labelCount++);
}

string newLabel(string labelName)
{
    return labelName+"_" + to_string(labelCount++);
}

void printHelp(string s){
	codeSegOut << s << '\n';
}

void genFuncStartCode(string funcName){
	codeSegOut << "\t" << funcName << " PROC\n";
    if (funcName == "main")
    {
        codeSegOut << "\tMOV AX, @DATA\n\tmov DS, AX\n";
        isMain = true;
    }else{
        isMain = false;
        printHelp("\tPUSH BP"); // SAVE BP 
    }
    printHelp("\tMOV BP, SP");
}

void genFuncEndCode(string funcName){
	if (funcName == "main")
    {
        codeSegOut << "\tMOV AH, 4CH" << '\n';
        codeSegOut << "\tINT 21H" << '\n';
    }else{
        printHelp("\tPOP BP");
        codeSegOut << "\tRET\n";
        isMain = true;
    }
    codeSegOut << "\t" << funcName << " ENDP\n\n";
}

void openFiles()
{
    dataSegOut.open("code.asm",ios_base::out);
    codeSegOut.open("codeSegOut.txt",ios::out);
	dataSegOut << ".MODEL SMALL\n.STACK 100h\n.DATA\n\n";
	dataSegOut << "\tCR EQU 0DH\n"
	"\tLF EQU 0AH\n"
	"\tnumber DB \"00000$\"\n";
	codeSegOut << ".CODE\n";
}

void genNewLine(){
	string str = "\nnew_line proc\n"
    "push ax\n"
    "push dx\n"
    "mov ah,2\n"
    "mov dl,cr\n"
    "int 21h\n"
    "mov ah,2\n"
    "mov dl,lf\n"
    "int 21h\n"
    "pop dx\n"
    "pop ax\n"
    "ret\n"
	"new_line endp\n";
    codeSegOut << str << endl;
}

void genPrint(){
	string str = "print_output proc\n"
    "push ax\n"
    "push bx\n"
    "push cx\n"
    "push dx\n"
    "push si\n"
    "lea si,number\n"
    "mov bx,10\n"
    "add si,4\n"
    "cmp ax,0\n"
    "jnge negate\n"
    "print:\n"
    "xor dx,dx\n"
    "div bx\n"
    "mov [si],dl\n"
    "add [si],'0'\n"
    "dec si\n"
    "cmp ax,0\n"
    "jne print\n"
    "inc si\n"
    "lea dx,si\n"
    "mov ah,9\n"
    "int 21h\n"
    "pop si\n"
    "pop dx\n"
    "pop cx\n"
    "pop bx\n"
    "pop ax\n"
    "ret\n"
    "negate:\n"
    "push ax\n"
    "mov ah,2\n"
    "mov dl,'-'\n"
    "int 21h\n"
    "pop ax\n"
    "neg ax\n"
    "jmp print\n"
	"print_output endp\n";
    codeSegOut << str << endl;
}

void programStart(){
	dataSegOut << ".MODEL SMALL\n.STACK 100h\n.DATA\n\n";
	codeSegOut << ".CODE\n";
}

void generateCodeDotAsmFile()
{
	genNewLine();
	genPrint();
	codeSegOut << "END MAIN" << '\n';
	codeSegOut.close();
	codeSegOut.open("codeSegOut.txt",ios::in);
	if(codeSegOut.is_open()){
		string line;
		while(getline(codeSegOut,line))
			dataSegOut << line << '\n';
	}
	dataSegOut.close();
	codeSegOut.close();
	remove("codeSegOut.txt");
}


// string varName(SymbolInfo* varInfo , int index=-1){
// 	cout << varInfo->getName() << ' ' << varInfo->size << '\n';
// 	if(varInfo->isGlobal){
// 		if(varInfo->size){
// 			// printHelp("LEA SI, " + varInfo->getName());
// 			// printHelp("ADD SI, " + to_string(2 * index));
// 			// return "[SI]";
// 		}
// 		else{
// 			return varInfo->getName();
// 		}
// 	}
// 	else{
// 		if(varInfo->size){
// 			string s = "[";
// 			s += "BP-" + to_string(varInfo->offset + 2 * index);
// 			s += "]";
// 			return s;
// 		}
// 		else{
// 			string s = "[";
// 			s += "BP-" + to_string(varInfo->offset);
// 			s += "]";
// 			return s;
// 		}
// 	}
// }

string getVarAddress(SymbolInfo *var, bool pop = false)
{
    if (pop)
    {
        if (var->size && !var->isGlobal)
            printHelp("\tPOP BX");
    }
    return var->asmName;
}

void genUnaryOpCode(SymbolInfo *info, bool inc = true)
{
    string op = inc ? "INC" : "DEC";
    string address = getVarAddress(info, true);
    printHelp("\tPUSH " + address);
    printHelp("\t" + op + " " + address);
}

string relopJumpCode(string relop){
    if(relop == "<") return "JL";
    if(relop == "<=") return "JLE";
    if(relop == ">") return "JG";
    if(relop == ">=") return "JGE";
    if(relop == "==") return "JE";
    if(relop == "!=") return "JNE";
}


// have to change this part 
void genVarDec(SymbolInfo *varInfo)
{	
	//cout << varInfo->getName() << ' ' << offset << endl;
    if (globalScope)
    {
        dataSegOut << "\t" << varInfo->getName();
        dataSegOut << " DW " ;
        if (varInfo->size)
        {
            dataSegOut << varInfo->size << " DUP(\"0000H\")";
        }
        else
        {
            dataSegOut << " 1 DUP(\"0000H\")" ;
        }
        // varInfo->isGlobal = true;
		varInfo->setAsmName(varInfo->getName(), true);
        dataSegOut << endl;
    }
    else
    {
		//cout << varInfo->getName() << ' ' << offset << '\n';
        if (varInfo->size)
        {
			string baseAddress = "W. [BP-" + to_string(offset) + "]";
            varInfo->setAsmName(baseAddress, false, offset);
            codeSegOut << "\tSUB SP, " << 2 * varInfo->size << '\n' ;
        }
        else
        {
			string baseAddress = "W. [BP-" + to_string(offset) + "]";
            varInfo->setAsmName(baseAddress, false, offset);
            codeSegOut << "\tSUB SP, 2\n";
        }
    }
}

// SymbolInfo* helper(SymbolInfo* ob){
// 	SymbolInfo* t = new SymbolInfo(ob->getName() , ob->getType());
// 	t->dataType = ob->dataType;
// 	t->info = ob->info;
// 	t->size = ob->size;
// 	t->parameters = ob->parameters;
// 	t->isGlobal = ob->isGlobal;
// 	t->offset = ob->offset;
// 	return t;
// }

void freeVector(vector<SymbolInfo*>* v){
	for(SymbolInfo* si : *v){
		delete si;
	}
	delete v;
}

void printList(vector<SymbolInfo*>* List){
	cout << "List is : " << endl ;
	for(SymbolInfo* si : *List){
		cout << si->getName() << ' ' << si->getType() << endl;
	}
}

string typeCast(SymbolInfo* x , SymbolInfo* y){
	if(x->dataType == y->dataType || (x->dataType == "float" && y->dataType == "int") || x->dataType != "void")
		return x->dataType;
	return y->dataType;
}


string toFuncParamList(vector<SymbolInfo*>* v){
	string s;
	for(int i = 0 ; i < (*v).size() ; i ++ ){
		s += (*v)[i]->dataType + " " + (*v)[i]->getName() ;
		if(i != (int)(*v).size() - 1){
			s += ",";
		}
	}
	return s;
}

string toVarDecList(vector<SymbolInfo*>* v){
	string s;
	for(int i = 0 ; i < (*v).size() ; i ++ ){
		if((*v)[i]->size){
			s += (*v)[i]->getName() + "[" + to_string((*v)[i]->size) + "]" ;
		}
		else{
			s += (*v)[i]->getName() ;
		}
		if(i != (int)(*v).size() - 1){
			s += ",";
		}
	}
	return s;
}

string toSymbolNameList(vector<SymbolInfo*>* v){
	string s;
	for(int i = 0 ; i < (*v).size() ; i ++ ){
		s += (*v)[i]->getName() ;
		if(i != (int)(*v).size() - 1){
			s += ",";
		}
	}
	return s;
}

bool checkParam(string name,string dataType,int line = line_count){
	if(dataType == "void"){
		// function parameter cannot be void error
		err_count ++ ;
		fprintf(logError , "Line# %d: Function parameter cannot be void\n" , line) ;
		return false ;
	}
	SymbolInfo* si = new SymbolInfo(name , dataType);
	bool ok = table->Insert(*si);
	if(ok){
		si = table->LookUp(name);
		si->dataType = dataType;
		return true;
	}
	else{
		// multiple declaration of parameter error
		err_count ++ ;
		fprintf(logError , "Line# %d: Redefinition of parameter '%s'\n" , line, name.c_str());
		// cout << "multiple paisi" << endl;
		return false;
	}
}

void declareFuncParamList(vector<SymbolInfo*>* &List){
	if(List){
		for(SymbolInfo* si : *List){
			checkParam(si->getName(),si->dataType);
		}
		List = NULL;
	}
}

void FunctionDeclaration(string func_name,string return_type,vector<SymbolInfo*>*v = NULL , int line = line_count){
	SymbolInfo* is = table->LookUp(func_name);
	if(is == NULL){
		//doesn't exist in symboltable
		is = new SymbolInfo(func_name , "");
		table->Insert(*is);
		is = table->LookUp(func_name);
		is->setName(func_name);
		is->dataType = return_type;
		is->info = SymbolInfo::FuncDec;
		if(v){
			for(SymbolInfo* si : *v){
				is->addParam(si->getName(),si->dataType);
			}
		}
	}
	else{
		if(is->info == SymbolInfo::FuncDec){
			//redeclaration error
			err_count ++ ;
			fprintf(logError , "Line# %d: Redeclaration of %s\n" , line, func_name.c_str());
		}
	}
}

void FunctionDefinition(string func_name,string return_type,vector<SymbolInfo*>*v = NULL,int line = line_count){
	SymbolInfo* is = table->LookUp(func_name);
	if(is == NULL){
		//doesn't exist in symboltable
		is = new SymbolInfo(func_name , "");
		table->Insert(*is);
		is = table->LookUp(func_name);
		is->setName(func_name);
		is->dataType = return_type;
		is->info = SymbolInfo::FuncDef;
		if(v){
			for(SymbolInfo* si : *v){
				is->addParam(si->getName(),si->dataType);
			}
		}
	}
	else{
		if(is->info == SymbolInfo::FuncDec){
			//function defined previously 
			if(is->dataType != return_type){
				//return type mismatch error
				err_count ++ ;
				fprintf(logError , "Line# %d: Conflicting types for '%s'\n" , line, func_name.c_str());
				return;
			}
			if(v && is->parameters.size() != (*v).size()){
				//no of arguments mismatch error
				err_count ++ ;
				int a = (int)is->parameters.size();
				int b = (int)(*v).size();
				if(a < b)
					fprintf(logError , "Line# %d: Too many arguments to function '%s'\n" , line, func_name.c_str());
				else
					fprintf(logError , "Line# %d: Too few arguments to function '%s'\n" , line, func_name.c_str());
				return;
			}
			if(v){
				for(int i = 0 ; i < is->parameters.size() ; i ++ ){
					string f = is->parameters[i].second;
					string s = (*v)[i]->dataType;
					if(f != s){
						//conflicting argument type error
						string t = is->parameters[i].first;
						err_count ++ ;
						fprintf(logError , "Line# %d: Conflicting types for '%s'\n" , line, t.c_str());
						return;
					}
				}
			}
		}
		else{
			//multiple-declaration error
			err_count ++ ;
			fprintf(logError , "Line# %d: Multiple declaration of %s\n" , line, func_name.c_str());
			return;
		}
	}
}

void callFunc(SymbolInfo* &func , vector<SymbolInfo*>* v = NULL , int line = line_count){
	SymbolInfo* is = table->LookUp(func->getName());
	string func_name = func->getName();
	if(is){
		if(!is->isFunc()){
			// not a function error
			err_count ++ ;
			fprintf(logError , "Line# %d: Not a function %s\n" , line, func_name.c_str());
			return;
		}
		func->dataType = is->dataType;
		if(func->info == SymbolInfo::FuncDef){
			// function not defined error
			fprintf(logError , "Line# %d: '%s' not defined\n" , line, func_name.c_str());
			err_count ++ ;
			return;
		}
		if(v && is->parameters.size() != (*v).size()){
			//no of arguments mismatch error
			err_count ++ ;
			int a = (int)is->parameters.size();
			int b = (int)(*v).size();
			if(a < b)
				fprintf(logError , "Line# %d: Too many arguments to function '%s'\n" , line, func_name.c_str());
			else
				fprintf(logError , "Line# %d: Too few arguments to function '%s'\n" , line, func_name.c_str());
			return;
		}
		if(v){
			for(int i = 0 ; i < is->parameters.size() ; i ++ ){
				string f = is->parameters[i].second;
				string s = (*v)[i]->dataType;
				if(f != s){
					//conflicting argument type error
					err_count ++ ;
					string t = is->parameters[i].first;
					fprintf(logError , "Line# %d: Conflicting types for '%s'\n" , line, t.c_str());
					return;
				}
			}
		}

	}
	else{
		//undeclared function error
		err_count ++ ;
		fprintf(logError , "Line# %d: Undeclared Function %s\n" , line, func_name.c_str());
	}
}

%}

%union{
	SymbolInfo* symbolInfo;
	vector<SymbolInfo*> *v;
	string* str_info;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN 
%token ASSIGNOP NOT INCOP DECOP
%token LPAREN RPAREN SEMICOLON COMMA LCURL RCURL LTHIRD RTHIRD
%token<symbolInfo> CONST_INT CONST_FLOAT ID
%token<symbolInfo> ADDOP MULOP RELOP LOGICOP


%type <symbolInfo> variable factor term unary_expression simple_expression rel_expression logic_expression expression
%type <str_info> expression_statement statement statements compound_statement
%type <str_info> type_specifier var_declaration func_declaration func_definition unit program 
%type <v>  declaration_list parameter_list argument_list arguments


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		fprintf(logout , "start : program\n");
		fprintf(logout , "Total Lines: %d\n" , line_count);
		fprintf(logout , "Total Errors: %d\n" , err_count);
	}
	;

program : program unit {
		fprintf(logout , "program : program unit\n");
		string s = *$1 +"\n"+ *$2;
		$$ = new string(s);
		delete $1;delete $2;
	}
	| unit{
		fprintf(logout,"program : unit\n");
		$$ = $1;
	}
	;
	
unit : var_declaration{
			fprintf(logout,"unit : var_declaration\n");
	 }
     | func_declaration{
			fprintf(logout,"unit : func_declaration\n");
	 }
     | func_definition{
			fprintf(logout,"unit : func_definition\n");
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
			// int var(int a, int b);
			fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
			string s = *$1 + " " + $2->getName() + "(" +toFuncParamList($4) + ");";
			$$ = new string(s);
			FunctionDeclaration($2->getName(),*$1,$4);
			delete $1; delete $2; freeVector($4);
			List = NULL;
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON{
			// int var();
			fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");
			string s = *$1 +" "+$2->getName()+"();";
			$$ = new string(s);
			FunctionDeclaration($2->getName(), *$1);
			delete $1; delete $2;
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
		{	
			globalScope = false;
			offset = 0 ;
			genFuncStartCode($2->getName());
			FunctionDefinition($2->getName(), *$1 , $4);
		} compound_statement
		{
			genFuncEndCode($2->getName());
			fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
			string s = *$1 + " " + $2->getName() + "(" +toFuncParamList($4) + ")" + *$7;
			$$ = new string(s);
			delete $1; delete $2; delete $7; freeVector($4);
			List = NULL;
		}
		| type_specifier ID LPAREN RPAREN
		{
			globalScope = false;
			offset = 0;
			genFuncStartCode($2->getName());
			FunctionDefinition($2->getName(), *$1);
		} compound_statement{
			genFuncEndCode($2->getName());
			fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
			string s = *$1 +" "+$2->getName()+"()"+ *$6;
			$$ = new string(s);
			delete $1;delete $2;delete $6;
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID{
			// void fun(int a, in b);
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID\n");
			string s = toFuncParamList($1) + "," + *$3 + " " + $4->getName();
			SymbolInfo* temp = new SymbolInfo($4->getName(),"");
			temp->dataType = *$3;
			$1->push_back(temp);
			$$ = $1;
			List = $1; // save the parameter to store in function scope
			delete $3; delete $4;
		}
		| parameter_list COMMA type_specifier{
			// void fun(int a, in b);
			fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier\n");
			string s = toFuncParamList($1) + "," + *$3;
			$1->push_back(new SymbolInfo(*$3));
			$$ = $1;
			List = $1;
			delete $3;
		}
 		| type_specifier ID{
			 // void fun(int a)
			fprintf(logout,"parameter_list  : type_specifier ID\n");
			$$ = new vector<SymbolInfo*>();
			SymbolInfo* temp = new SymbolInfo($2->getName(),"");
			temp->dataType = *$1;
			$$->push_back(temp);
			List = $$;
			delete $1; delete $2;
		}
		| type_specifier{
			fprintf(logout,"parameter_list  : type_specifier\n");
			$$ = new vector<SymbolInfo*>();
			SymbolInfo* temp = new SymbolInfo(*$1);
			temp->dataType = *$1;
			$$->push_back(temp);
			delete $1;
		}
 		;

 		
compound_statement : LCURL{table->EnterScope();declareFuncParamList(List);} statements RCURL{
				fprintf(logout,"compound_statement : LCURL statements RCURL\n");
				string s = "{\n"+*$3+"\n}\n";
				$$ = new string(s);
				delete $3;
				table->PrintAll(logout);
				table->ExitScope();
			}
 		    | LCURL {table->EnterScope();} RCURL{
				fprintf(logout,"compound_statement : LCURL RCURL\n");
				$$ = new string("{}");
				table->PrintAll(logout);
				table->ExitScope();
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON{
			fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON\n");
			string s = *$1 +" " +  toVarDecList($2) + ";";
			$$ = new string(s);
			for(SymbolInfo* si : *$2){
				if(*$1 == "void"){
					err_count ++ ;
					fprintf(logError , "Line# %d: Variable or field '%s' declared void\n" , line_count , si->getName().c_str());
					continue;
				}
				bool ok = table->Insert(*si);
				if(!ok){
					// multiple declaration error
					err_count ++ ;
					fprintf(logError , "Line# %d: Multiple declaration of '%s'\n" , line_count , si->getName().c_str());
				}
				else{
					SymbolInfo* newVar = table->LookUp(si->getName());
					newVar->copy(si);
					newVar->dataType = *$1;
					//newVar->setDataType(*$1); // set the data type of the variable
					if(si->size){ // set array size for array type variables
						newVar->size = si->size;
					}
				}
			}
			delete $1; freeVector($2);
		 }
 		 ;
 		 
type_specifier	: INT{
			fprintf(logout,"type_specifier	: INT\n");
			$$ = new string("int");
		}
 		| FLOAT{
			fprintf(logout,"type_specifier	: FLOAT\n");
			$$ = new string("float");
		}
 		| VOID{
			fprintf(logout,"type_specifier	: VOID\n");
			$$ = new string("void");
		}
 		;
 		
declaration_list : declaration_list COMMA ID{
				fprintf(logout,"declaration_list : declaration_list COMMA ID\n");
				string s = toVarDecList($1) + "," + $3->getName();
				if(!globalScope) offset += 2 ;
				genVarDec($3);
				$1->push_back($3); 
				$$ = $1;
		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
				fprintf(logout,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n");
				string s = toVarDecList($1) + "," + $3->getName() + "[" + $5->getName() + "]";
				$3->size = atoi($5->getName().c_str());
				if(!globalScope) offset += 2;
				genVarDec($3);
				if(!globalScope) offset += 2 * ($3->size - 1);
				$1->push_back($3);
				$$ = $1;
				delete $5; //free stuff
		  }
 		  | ID{
				fprintf(logout,"declaration_list : ID\n");
				$$ = new vector<SymbolInfo*>();
				if(!globalScope) offset += 2;
				genVarDec($1);
				$$->push_back($1);
		  }
 		  | ID LTHIRD CONST_INT RTHIRD{
				fprintf(logout,"declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
				$$ = new vector<SymbolInfo*>();
				$1->size = atoi($3->getName().c_str());
				if(!globalScope) offset += 2;
				genVarDec($1);
				if(!globalScope) offset += 2 * ($1->size - 1);
				$$->push_back($1);
				delete $3;
		  }
 		  ;
 		  
statements : statement{
			fprintf(logout,"statements : statement\n");
			$$ = $1;
		}
	   | statements statement{
			fprintf(logout,"statements : statements statement\n");
			string s = *$1 + "\n"+ *$2;
			$$ = new string(s);
			delete $1;delete $2;
	   }
	   ;
	   
statement : var_declaration{
			fprintf(logout,"statement : var_declaration\n");
		}
	  | expression_statement{
			fprintf(logout,"statement : expression_statement\n");
			printHelp("\tPOP AX");

	  }
	  | compound_statement{
			fprintf(logout,"statement : compound_statement\n");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement{
			fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
			string s = "for(" + *$3+ ";" + *$4 + ";" + $5->getName()+ ")" + *$7;
			$$ = new string(s);
			delete $3;delete $4;delete $5;delete $7;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement\n");
			string s = "if(" + $3->getName() + ")" + *$5;
			$$ = new string(s);
			delete $3;delete $5;
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement{
			fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");
			string s = "if(" + $3->getName() + ")" + *$5 + "else " + *$7;
			$$ = new string(s);
			delete $3;delete $5;delete $7;
	  }
	  | WHILE LPAREN expression RPAREN statement{
			fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement\n");
			string s = "while(" + $3->getName() + ")" + *$5;
			$$ = new string(s);
			delete $3;delete $5;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON{
			fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
			string s = "printf(" + $3->getName() + ");";
			SymbolInfo* si = table->LookUp($3->getName());
			if(!si){
				//undeclared variable error
				err_count ++ ;
				fprintf(logError , "Line# %d: Variable '%s' not declared" , line_count ,$3->getName());
			}
			else{
				printHelp("\tMOV AX, "+si->asmName);
				printHelp("\tCALL print_output");
				printHelp("\tCALL new_line");
			}
			$$ = new string(s);
			delete $3;
	  }
	  | RETURN expression SEMICOLON{
			fprintf(logout,"statement : RETURN expression SEMICOLON\n");
			string s = "return " + $2->getName() + ";";
			$$ = new string(s);
			delete $2;
	  }
	  ;
	  
expression_statement 	: SEMICOLON{
				fprintf(logout,"expression_statement : SEMICOLON\n");
				$$ = new string(";");
			}			
			| expression SEMICOLON {
				fprintf(logout,"expression_statement : expression SEMICOLON\n");
				string s = $1->getName() + ";";
				$$ = new string(s);
				delete $1;
			}
			;
	  
variable : ID{
		fprintf(logout,"variable : ID\n");
		SymbolInfo *si = table->LookUp($1->getName());
		if(si){
			//  array used as variable
			if(si->size){
				err_count ++ ;
				fprintf(logError , "Line# %d: '%s' is an array\n" , line_count , $1->getName().c_str());
			}
			$$ = new SymbolInfo(*si);
			$$->asmName = getVarAddress(si); 
			delete $1; 
		}else{
			err_count ++ ;
			fprintf(logError , "Line# %d: Undeclared Function %s\n" , line_count, $1->getName().c_str());
			$$ = $1;
		}
	} 		
	 | ID LTHIRD{arrayIndex = true;} expression RTHIRD{
		fprintf(logout,"variable : ID LSQUARE expression RSQUARE\n");
		string s = $1->getName()+"["+$4->getName()+"]";
		//cout << "var rule e " << $1->getName() << endl ;
		arrayIndex = false;
		SymbolInfo *si = table->LookUp($1->getName());
		if(si){ 
			$1->dataType = (si->dataType);
			if(!si->size){ // var used as array
				err_count ++ ;
				fprintf(logError , "Line# %d: '%s' is a not an array\n" , line_count , $1->getName().c_str());
			}
			if($4->dataType!="int"){
				err_count ++ ;
				fprintf(logError , "Line# %d: Array subscript is not an integer\n" , line_count);
			}
			$1->copy(si);
			printHelp("\tPOP AX");
			printHelp("\tSHL AX, 1");
			printHelp("\tLEA BX, "+si->asmName);
			printHelp("\tSUB BX, AX");
			printHelp("\tPUSH BX");
			$1->asmName = "[BX]";
		}else{
			err_count ++ ;
			fprintf(logError , "Line# %d: Undeclared variable %s\n" , line_count, $1->getName().c_str());
		}
		$1->setName(s);
		$$ = $1;
		delete $4;
	 }
	 ;
	 
 expression : logic_expression{
			fprintf(logout,"expression  : logic_expression\n");
			$$ = $1;
 		}
	   | variable ASSIGNOP logic_expression{
			fprintf(logout,"expression  : variable ASSIGNOP logic_expression\n");
			string s = $1->getName() + "=" + $3->getName();
			SymbolInfo *si = table->LookUp($1->getName());
			if(si){
				if(si->dataType=="int" && $3->dataType=="float"){
					err_count ++ ;
					fprintf(logError , "Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n", line_count) ;
				}
			}
			if($3->dataType=="void"){
					err_count ++ ;
					fprintf(logError , "Line# %d: Void cannot be used in expression \n", line_count) ;
			}
			SymbolInfo* temp = new SymbolInfo(s , "expression");
			temp->dataType = $1->dataType;
			$$ = temp;
			//new
			printHelp("\tPOP AX");
			printHelp("\tMOV "+getVarAddress($1, true)+", AX");
			printHelp("\tPUSH AX");

			delete $1; delete $3;
	   } 	
	   ;
			
logic_expression : rel_expression{
			fprintf(logout,"logic_expression : rel_expression\n");
		}
		 | rel_expression LOGICOP{
			printHelp("\tPOP AX");
			string val;
			if($2->getName() == "&&"){
				val = "1";
			}
			else{
				val = "0";
			}
			printHelp("\tCMP AX, " + val);
			string jmpLabel = newLabel();
			printHelp("\tJNE "+jmpLabel);
			$1->label = jmpLabel;
		 } rel_expression{
			fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression\n");
			string s = $1->getName()+$2->getName()+$4->getName();
			SymbolInfo* temp = new SymbolInfo(s , "logic_expression");
			temp->dataType = "int";
			$$ = temp;

			printHelp("\tPOP AX");
			string val;
			if($2->getName() == "&&"){
				val = "1";
			}
			else{
				val = "0";
			}
			printHelp("\tCMP AX, " + val);
			printHelp("\tJNE " + $1->label);
			if($2->getName() == "&&"){
				val = "1";
			}
			else{
				val = "0";
			}
			printHelp("\tPUSH "+val);
			string endLabel = newLabel();
			printHelp("\tJMP " + endLabel);
			printHelp("\t"+$1->label+":");
			if($2->getName() == "&&"){
				val = "0";
			}
			else{
				val = "1";
			}
			printHelp("\tPUSH " + val);
			printHelp("\t" + endLabel + ":");

			delete $1,$2,$4;
		 }
		 ;
			
rel_expression	: simple_expression {
			fprintf(logout,"rel_expression	: simple_expression\n");
		}
		| simple_expression RELOP simple_expression{
			fprintf(logout,"rel_expression	: simple_expression RELOP simple_expression\n");
			string s = $1->getName()+$2->getName()+$3->getName();
			SymbolInfo* temp = new SymbolInfo(s , "rel_expression");
			temp->dataType = typeCast($1 , $3);
			$$ = temp;

			string trueLabel = newLabel();
			string falseLabel = newLabel();
			string op = relopJumpCode($2->getName());
			printHelp("\tPOP BX");
			printHelp("\tPOP AX");
			printHelp("\tCMP AX, BX");
			printHelp("\t"+op+" "+trueLabel);
			printHelp("\tPUSH 0");
			printHelp("\tJMP " + falseLabel);
			printHelp("\t" + trueLabel + ":");
			printHelp("\tPUSH 1");
			printHelp("\t" + falseLabel + ":");


			delete $1,$2,$3;
		}
		;
				
simple_expression : term{
			fprintf(logout,"simple_expression : term\n");
		}
		  | simple_expression ADDOP term{
			fprintf(logout,"simple_expression : simple_expression ADDOP term\n");
			string s = $1->getName() + $2->getName()  + $3->getName();
			if($1->dataType == "void" || $3->dataType == "void"){
				err_count ++ ;
				fprintf(logError , "Line# %d: Void cannot be used in expression \n", line_count) ;
			}
			SymbolInfo* temp = new SymbolInfo(s , "simple_expression");
			temp->dataType = typeCast($1 , $3);
			$$ = temp;
			//new
			printHelp("\tPOP BX");
			printHelp("\tPOP AX");
			if($2->getName() == "+")
				printHelp("\tADD AX , BX");
			else 
				printHelp("\tSUB AX , BX");
			printHelp("\tPUSH AX");
			delete $1; delete $2; delete $3;
		  }
		  ;
					
term :	unary_expression{
		fprintf(logout,"term :	unary_expression\n");
	}
     |  term MULOP unary_expression{
		fprintf(logout,"term :	term MULOP unary_expression\n");
		string s = $1->getName() + $2->getName()  + $3->getName();
		if($1->dataType == "void" || $3->dataType == "void"){
				err_count ++ ;
				fprintf(logError , "Line# %d: Void cannot be used in expression \n", line_count) ;
		}
		if($2->getName() == "%"){
			if($3->getName() == "0"){
				err_count ++ ;
				fprintf(logError , "Modulus by zero\n" , line_count) ; 
			}
			if($1->dataType != "int" || $3->dataType != "int"){
				err_count ++ ;
				fprintf(logError , "Operands of modulus must be integers\n" , line_count) ; 
			}
			$1->dataType = "int";
			$3->dataType = "int";
		}
		printHelp("\tPOP BX");
		printHelp("\tPOP AX");
		printHelp("\tXOR DX, DX");
		if($2->getName() == "*"){
			printHelp("\tIMUL BX");
		}
		else{
			printHelp("\tIDIV BX");
		}
		if($2->getName() == "%"){
			printHelp("\tPUSH DX");
		}
		else{
			printHelp("\tPUSH AX");
		}
		SymbolInfo* temp = new SymbolInfo(s , "term");
		temp->dataType = typeCast($1 , $3);
		$$ = temp;
		delete $1; delete $2; delete $3;
	 }
     ;

unary_expression : ADDOP unary_expression{
			fprintf(logout,"unary_expression : ADDOP unary_expression\n");
			string s = $1->getName() + $2->getName();
			SymbolInfo* temp = new SymbolInfo(s,"unary_expression");
			temp->dataType = $2->dataType ;
			$$ = temp;
			if($1->getName() == "-"){
				printHelp("\tPOP AX");
				printHelp("\tNEG AX");
				printHelp("\tPUSH AX");
			}
			delete $1; delete $2;
		}
		 | NOT unary_expression {
			fprintf(logout,"unary_expression : NOT unary_expression\n");
			string s = "!"+ $2->getName();
			SymbolInfo* temp = new SymbolInfo(s,"unary_expression");
			temp->dataType = $2->dataType ;
			$$ = temp;


			string l1 = newLabel();
			string l2 = newLabel(); 
			printHelp("\tPOP AX");
			printHelp("\tCMP AX, 0");
			printHelp("\tJE "+l1);
			printHelp("\tPUSH 0");
			printHelp("\tJMP "+l2);
			printHelp("\t"+l1+":");
			printHelp("\tPUSH 1");
			printHelp("\t"+l2+":");
		

			delete $2;
		 }
		 | factor {
			fprintf(logout,"unary_expression : factor\n");
		 }
		 ;
	
factor	: variable{
		fprintf(logout,"factor	: variable\n");
		printHelp("\tPUSH "+getVarAddress($1, true));
		$$ = $1;
	} 
	| ID LPAREN argument_list RPAREN{
		fprintf(logout,"factor	: ID LPAREN argument_list RPAREN\n");
		string s = $1->getName() + "(" + toSymbolNameList($3) + ")";
		callFunc($1,$3);
		SymbolInfo* temp = new SymbolInfo(s,"function");
		temp->dataType = $1->dataType ;
		$$ = temp;
		delete $1; freeVector($3);
		
	}
	| LPAREN expression RPAREN{
		fprintf(logout,"factor	: LPAREN expression RPAREN\n");
		string s = "(" + $2->getName() + ")";
		SymbolInfo* temp = new SymbolInfo(s , "factor");
		temp->dataType = $2->dataType;
		$$ = temp;
		delete $2;
	}
	| CONST_INT {
		fprintf(logout,"factor	: CONST_INT\n");
		SymbolInfo* temp = new SymbolInfo($1->getName() , $1->getType());
		temp->dataType = "int";
		$$ = temp;
		//new
		string s = "\tMOV AX , " + temp->getName();
		printHelp(s);
		s = "\tPUSH AX";
		printHelp(s);
	}
	| CONST_FLOAT{
		fprintf(logout,"factor	: CONST_FLOAT\n");
		SymbolInfo* temp = new SymbolInfo($1->getName() , $1->getType());
		temp->dataType = "float";
		$$ = temp;
	}
	| variable INCOP{
		fprintf(logout,"factor	: variable INCOP\n");
		genUnaryOpCode($1);
		string s = $1->getName() + "++";
		SymbolInfo* temp = new SymbolInfo(s , "factor");
		temp->dataType = $1->dataType;
		$$ = temp;
		delete $1;
	}
	| variable DECOP{
		fprintf(logout,"factor	: variable DECOP\n");
		genUnaryOpCode($1,false);
		string s = $1->getName() + "--";
		SymbolInfo* temp = new SymbolInfo(s , "factor");
		temp->dataType = $1->dataType;
		$$ = temp;
		delete $1;
	}
	;
	
argument_list : arguments{
					fprintf(logout,"argument_list : arguments\n");
					string s = toSymbolNameList($1);
					$$ = $1;
				}
				|{
					fprintf(logout,"argument_list : \n");
					$$ = new vector<SymbolInfo*>();
				}
			  ;
	
arguments : arguments COMMA logic_expression{
				fprintf(logout,"arguments : arguments COMMA logic_expression\n");
				string s = toSymbolNameList($1) + "," + $3->getName();
				$$->push_back($3);
			}
	      | logic_expression{
			fprintf(logout,"arguments : logic_expression\n");
			$$ = new vector<SymbolInfo*>(); 
			$$->push_back($1);
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
	FILE* fp ;

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	
	cout<<argv[1]<<" opened successfully."<<endl;

	yyin=fp;

	logout = fopen("log.txt" , "w") ;

	logError = fopen("error.txt" , "w");
	
	//table->EnterScope();
	openFiles();

	yyparse();

	generateCodeDotAsmFile();
	
	fclose(yyin) ;

	fclose(logout) ;

	return 0;
}

