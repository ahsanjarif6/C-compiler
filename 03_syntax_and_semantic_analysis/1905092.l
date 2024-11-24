%option noyywrap

%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT
%x SINGLE_LINE_STRING
%x MULTI_LINE_STRING 
%x CHARACTER

%{
#pragma once
#include<bits/stdc++.h>
#include "1905092_SymbolTable.h"
#include "1905092_SymbolInfo.h" 
#include "1905092_ScopeTable.h"
#include "y.tab.h"

using namespace std;

int start=1;
int line_count=1;
int error_count = 0 ;
string comment ;
string tokStr ;
string logStr ;
extern FILE *logout;
//extern SymbolTable *table;


char* allCap(char* s){
	char* t = new char [strlen(s)] ;
	for(int i = 0 ; i < strlen(s) ; i ++ ){
		t[i] = toupper(s[i]) ;
	}
	return t ;
}

char specialChar(char c){
	char ch = c ;
	if(c == 'n') ch = '\n' ;
	if(c == 't') ch = '\t' ;
	if(c == 'a') ch = '\a' ;
	if(c == 'f') ch = '\f' ;
	if(c == 'r') ch = '\r' ;
	if(c == 'b') ch = '\b' ;
	if(c == 'v') ch = '\v' ;
	if(c == '0') ch = '\0' ;
	return ch ;
}
%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
CHAR [0-9a-zA-Z]
NEWLINE \n

%%

\'\\[ntafrbv0\'\"\\]\'		{
								char c = yytext[2] ;
								char ch = specialChar(c) ;
								// fprintf(tokenout , "<CONST_CHAR, %c>\n" , ch) ;
								// fprintf(logout , "Line# %d: Token <CONST_CHAR> Lexeme %c found\n" , line_count , ch) ;
							}

\'[^\n\t\a\f\r\b\v\0\'\"\\]\'		{
										char ch = yytext[1] ;
										// fprintf(tokenout , "<CONST_CHAR, %c>\n" , ch) ;
										// fprintf(logout , "Line# %d: Token <CONST_CHAR> Lexeme %c found\n" , line_count , ch) ;
									}


(\'{CHAR}{CHAR}+(\'))	{
						error_count ++ ;
						//fprintf(logout , "Error at line# %d: MULTICHAR_CONST_CHAR %s\n" , line_count , yytext ) ;
					}

(\'({CHAR}|(\')))	{
						error_count ++ ;
						//fprintf(logout , "Error at line# %d: UNFINISHED_CONST_CHAR %s\n" , line_count , yytext ) ;
					}


"//"	{
			BEGIN SINGLE_LINE_COMMENT ;
			comment.clear() ;
			comment += "//" ;
			start = line_count ;
		}
<SINGLE_LINE_COMMENT>["\\"][^\n]	{
										//cout << comment << endl ;
										comment += yytext ;
									}

<SINGLE_LINE_COMMENT>(["\\"]{NEWLINE})		{	
												//cout << comment << endl ;
												comment += yytext ;
												line_count ++ ;
											}

<SINGLE_LINE_COMMENT>{NEWLINE}		{
										//cout << comment << endl ;
										//fprintf(logout , "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n" , start , comment.c_str() ) ;
										BEGIN INITIAL ;
										line_count ++ ;
									}


<SINGLE_LINE_COMMENT><<EOF>>	{
									//fprintf(logout , "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n" , start , comment.c_str() ) ;
									BEGIN INITIAL ;
								}

<SINGLE_LINE_COMMENT>.	{		
								//cout << yytext << endl ;
								comment += yytext ;
						}

"/*"	{
			BEGIN MULTI_LINE_COMMENT ;
			comment.clear() ;
			comment += "/*" ;
			start = line_count ;
		}

		
<MULTI_LINE_COMMENT>"*/"		{
									comment += "*/" ;
									//fprintf(logout , "Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n" , start , comment.c_str() ) ;
									BEGIN INITIAL ;
								}

<MULTI_LINE_COMMENT>{NEWLINE}		{
										comment += yytext ;
										//comment += '\n' ;
										line_count ++ ;
									}

<MULTI_LINE_COMMENT><<EOF>>	{
									//fprintf(logout , "Error at line# %d: UNFINISHED_COMMENT %s\n" , line_count , comment.c_str() ) ;
									BEGIN INITIAL ;
									error_count ++ ;
							}

<MULTI_LINE_COMMENT>.	{
								comment += yytext ;
						}

"\""	{
			BEGIN SINGLE_LINE_STRING ;
			tokStr.clear() ;
			logStr.clear() ;
			start = line_count ;
			logStr += "\"" ;
		}

<SINGLE_LINE_STRING>"\""	{
								logStr += "\"" ;
								//fprintf(tokenout , "<SINGLE LINE STRING, %s>\n" , tokStr.c_str()) ;
								//fprintf(logout , "Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n" , start , logStr.c_str() ) ;
								BEGIN INITIAL ;
							}

<SINGLE_LINE_STRING>(["\\"][n|t|f|b|a|v|r|0|'|"])	{
														char ch = yytext[1] ;
														ch = specialChar(ch) ;
														tokStr += ch ;
														logStr += "\\" ;
														logStr += yytext[1] ;
													}

<SINGLE_LINE_STRING><<EOF>>	{
								//fprintf(logout , "Error at line# %d: UNFINISHED_STRING %s\n" , line_count , logStr.c_str());
								BEGIN INITIAL ;
								error_count ++ ;
							}

<SINGLE_LINE_STRING>["\\"]{NEWLINE}		{
											//cout << "how" << endl ;
											logStr += "\\" ;
											logStr += '\n' ;
											BEGIN MULTI_LINE_STRING ;
											line_count ++ ;
										}

<SINGLE_LINE_STRING>{NEWLINE}	{
									//fprintf(logout , "Error at line# %d: UNFINISHED_STRING %s\n" , line_count , logStr.c_str());
									line_count ++ ;
									BEGIN INITIAL ;
									error_count ++ ;
								}

<SINGLE_LINE_STRING>.	{
							tokStr += yytext ;
							logStr += yytext ;
						}

<MULTI_LINE_STRING>"\""		{
								logStr += "\"" ;
								//fprintf(tokenout , "<MULTI LINE STRING, %s>\n" , tokStr.c_str()) ;
								//fprintf(logout , "Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n" , start , logStr.c_str() ) ;
								BEGIN INITIAL ;
							}

<MULTI_LINE_STRING>["\\"]{NEWLINE}		{	
											//cout << "hoa\n" ;
											logStr += "\\" ;
											logStr += '\n' ;
											line_count ++ ;
										}

<MULTI_LINE_STRING>(["\\"][n|t|f|b|a|v|r|0|'|"])	{	
														
														char ch = yytext[1] ;
														ch = specialChar(ch) ;
														tokStr += ch ;
														logStr += "\\" ;
														logStr += yytext[1] ;
													}

<MULTI_LINE_STRING>{NEWLINE}	{
									//fprintf(logout , "Error at line# %d: UNFINISHED_STRING %s\n" , line_count , logStr.c_str());
									line_count ++ ;
									BEGIN INITIAL ;
									error_count ++ ;
								}

<MULTI_LINE_STRING><<EOF>>	{
								//fprintf(logout , "Error at line# %d: UNFINISHED_STRING %s\n" , line_count , logStr.c_str());
								BEGIN INITIAL ;
								error_count ++ ;
							}

<MULTI_LINE_STRING>.	{	//cout << "how " << yytext << endl ;
							tokStr += yytext ;
							logStr += yytext ;
						}

{WHITESPACE}+	{}


{NEWLINE} {line_count++;}



"if"		{return IF;}
"else"		{return ELSE;}
"for"		{return FOR;}
"while" 	{return WHILE;}
"do"		{return DO;}
"break"		{return BREAK;}
"int"		{
				fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
				SymbolInfo* si = new SymbolInfo(yytext , "INT") ;
				yylval.symbolInfo = si ;
				return INT;
			}
"char"		{return CHAR;}
"float"		{
				fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
				SymbolInfo* si = new SymbolInfo(yytext , "FLOAT") ;
				yylval.symbolInfo = si ;
				return FLOAT;
			}
"double"	{return DOUBLE;}
"void"		{
				fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
				SymbolInfo* si = new SymbolInfo(yytext , "VOID") ;
				yylval.symbolInfo = si ;
				return VOID;
			}
"return"	{
				fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
				return RETURN;
			}
"switch"	{return SWITCH;}
"case"		{return CASE;}
"default"	{return DEFAULT;}
"continue"  {return CONTINUE;}

({LETTER}|"_")({LETTER}|{DIGIT}|"_")*		{
										// fprintf(tokenout , "<ID, %s>\n" , yytext) ;
										fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
										// SymbolInfo si ;
										// si.setName(yytext) ;
										// si.setType("ID") ;
										// if(st.Insert(si))
										// 	st.PrintAll(logout) ;
										// else
										// 	fprintf(logout , "\t%s already exists in the current ScopeTable\n" , yytext) ;
										//cout << yytext << " paisi" << endl ;
										SymbolInfo* si = new SymbolInfo(yytext , "ID") ;
										yylval.symbolInfo = si ;
										return ID ;
									}
		
{DIGIT}+ 	{
				// fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
				//insert in symbol table and print symbol table content(only non empty buckets)
				//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
				//st.insert(si);
				//cout << yytext << " paisi" << endl ;
				SymbolInfo* si = new SymbolInfo(yytext , "CONST_INT") ;
				yylval.symbolInfo = si ;
				return CONST_INT;
			}


{DIGIT}*(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?		{
												// fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
												fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
												SymbolInfo* si = new SymbolInfo(yytext , "CONST_FLOAT") ;
												yylval.symbolInfo = si ;
												return CONST_FLOAT;
											}


({DIGIT}*\.{DIGIT}*)+({DIGIT}*\.{DIGIT}*)+([Ee][+-]?{DIGIT}+)?	{
																	error_count ++ ;
																	//fprintf(logout , "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n" , line_count , yytext);
																}

{DIGIT}*(\.{DIGIT}*)?([Ee][+-]?{DIGIT}*\.{DIGIT}*)	{
														error_count ++ ;
														//fprintf(logout , "Error at line# %d: ILLFORMED_NUMBER %s\n" , line_count , yytext);
													}																

{DIGIT}+({LETTER}|{DIGIT}|"_")+		{
										error_count ++ ;
										//fprintf(logout , "Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n" , line_count , yytext);
									}



"++"	{return INCOP;}
"--"	{return DECOP;}



"+"		|
"-"		{
			
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo* si = new SymbolInfo(yytext , "ADDOP") ;
			yylval.symbolInfo = si ;
			return ADDOP ;
		}


"*"		|
"/"		|
"%"		{	
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo* si = new SymbolInfo(yytext , "MULOP") ;
			yylval.symbolInfo = si ;
			return MULOP;
		}

"<"		|
"<="	|
">"		|
">="	|
"=="	|
"!="	{	
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo* si = new SymbolInfo(yytext , "RELOP") ;
			yylval.symbolInfo = si ;
			return RELOP;
		}

"="		{
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo* si = new SymbolInfo(yytext , "ASSIGNOP");
			yylval.symbolInfo = si;
			return ASSIGNOP;
		}

"&&"	|
"||"	{	
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo* si = new SymbolInfo(yytext , "LOGICOP") ;
			yylval.symbolInfo = si ;
			return LOGICOP;
		}

"&"		|
"|"		|
"^"		|
"<<"	|
">>"	{
			// fprintf(tokenout,"<BITOP, %s>\n",yytext);
			// fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
		}

"!"		{
			// fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
			return NOT;
		}

"("		{
			// fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
			return LPAREN;
		}

")"		{
			// fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
			return RPAREN;
		}

"{"		{
			// fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
			//st.EnterScope() ;
			// table->EnterScope();
			return LCURL;
		}

"}"		{
			// fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			//st.ExitScope() ;
			// table->PrintAll(logout);
			// table->ExitScope();
			return RCURL;
		}

"["		{
			// fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
			return LTHIRD;
		}

"]"		{
			// fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
			return RTHIRD;
		}

","		{
			// fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
			return COMMA;
		}
	
";"		{
			// fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			return SEMICOLON;
		}

.		{	
			error_count ++ ;
			// fprintf(logout , "Error at line# %d: UNRECOGNIZED_CHAR %s\n" , line_count , yytext);
		}

%%
