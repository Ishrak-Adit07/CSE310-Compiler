%option noyywrap

%{
    int numOfComments = 0;
%}

%x STRING

%x MULTI_LINE_COMMENT
%x SINGLE_LINE_COMMENT

%x NEWLINE

%{
#include <bits/stdc++.h>
#include <fstream>
#include "2005105_main.cpp"

using namespace std;

int word_count = 0;
int line_count = 1;

int indentation_tab_count = 0;
int newline_tab_count = 0;
int newline_space_count = 0;

int error_count = 0;
int warning_count = 0;

string stringLiteral;
string logStringLiteral;
string tokenStringLiteral;
bool multi_string_state = false;
int multi_line_count = 0;

ofstream logStream("log.txt");
ofstream tokenStream("token.txt");

int commandCount = 0;
int scopeTablesSize = 10;

//Root scopetable for global scope, with new SymbolTable
ScopeTable* scopeTable = new ScopeTable(scopeTablesSize);
SymbolTable* symbolTable = new SymbolTable(scopeTable, scopeTablesSize, logStream);
//actionController ac(symbolTable);

void IncWc(){
	word_count++;
}

void logFileToken(string Token,  string yytext){
	logStream<<"Line# "<<line_count<<": Token <"<<Token<<"> Lexeme "<<yytext<<" found"<<endl;
}

void tokenFileToken(string Token, string yytext){
	tokenStream<<"<"<<Token<<", "<<yytext<<">"<<endl;
}

void logFileError(string errorMessage, string yytext){
	logStream<<"Error at line# "<<line_count<<": "<<errorMessage<<" "<<yytext<<endl;
}

void printAllScopeTable(){
	logStream<<"\t";
	symbolTable->printAllScopeTable(logStream);
}

void manageIDinSymbolTable(string name, string type){
	//name = yytext, //type = Token
    string commandLine;

	if(!symbolTable->Lookup(name, logStream)){
		symbolTable->Insert(name, type, logStream);
		printAllScopeTable();
	}
	else{
		logStream<<"\t"<<name<<" already exists in the current ScopeTable"<<endl;
	}
}

void enterNewScopeTable(){
	symbolTable->EnterScope(logStream);
	indentation_tab_count++;
}
void exitCurrentScopeTable(){
	symbolTable->ExitScope(logStream);
	indentation_tab_count--;
}


%}

WS [ \t\v]+

Letter [a-zA-Z]

Digit [0-9]
Digits {Digit}+
Number1 {Digits}(\.{Digits})?(E[+-]?{Digits})?
Number2 {Digits}?(\.{Digits})(E[+-]?{Digits})?
Number ({Number1}|{Number2})
UnfinishedDecimal {Digits}?(\.)+(E[+-]?{Digits})?
UnfinishedPower {Digits}?(\.{Digits})?(E[+-]?)+
UnfinishedNumbers ({UnfinishedDecimal}|{UnfinishedPower})
NumerousPointerNumber {Digits}?[\.]+({Digits}?[\.]{Digits}?)+(E[+-]?({Digits}?[\.]?{Digits}?)+)?
pointInPowerNumber {Digits}?(\.{Digits})?(E[+-]?{Digits})?(E[+-]?({Digits}?[\.]{Digits}?)+)

Character \'[^\\\n\r\t\a\v\b\f\0\'\"]\'
EscapeCharacter \'(\\)[ntrvbaf0\\\'\"]\'

UnrecognizedCharacter [^ \t\na-zA-Z0-9*/%^&|<>=!'",_.;(){}[\]+-]

InvalidEmptyCharacter \'\'
InvalidCharacter \'[^\\\n\r\t\a\v\b\f\0\'\"]{2,}\'
InvalidEscapeCharacter \'\\[^ \'\r\n]{2,}\'
InvalidCharacters ({InvalidCharacter}|{InvalidEscapeCharacter})

UnfinishedCharacter \'[^\\\n\r\t\a\v\b\f\0\'\"]?[^\'\r\n]*
UnfinishedEscapeCharacter \'(\\)[^\'\r\n]*(\')?
UnfinishedCharacters ({UnfinishedCharacter}|{UnfinishedEscapeCharacter})

Identifier_Chars [_]
ID ({Letter}|{Identifier_Chars})({Letter}|{Digit}|{Identifier_Chars})*
NumberPrefixID {Number}({Letter}|{Digit}|{Identifier_Chars})*

LPAREN \(
RPAREN \)
LCURL \{
RCURL \}
LSQUARE \[
RSQUARE \]
COMMA ,
SEMICOLON ;

IF "if"
FOR "for"
DO "do"
INT "int"

FLOAT "float"
VOID "void"
SWITCH "switch"
DEFAULT "default"

ELSE "else"
WHILE "while"
BREAK "break"
CHAR "char"

DOUBLE "double"
RETURN "return"
CASE "case"
CONTINUE "continue"

BEGIN_MULTILINE_COMMENT "\/\*"
END_MULTILINE_COMMENT "\*\/"

BEGIN_SINGLELINE_COMMENT "//"
END_SINGLELINE_COMMENT	\s*[\n\r<<EOF>>]

SINGLE_QUOTES "\'"
DOUBLE_QUOTES "\""


NOT !

ADDOP [+-]

INC "++"
DEC "--"
INCOP ({INC}|{DEC})

MUL "*"
DIV "/"
MOD "%"
MULOP ({MUL}|{DIV}|{MOD})

AND "&"
OR "|"
XOR "^"
LSHIFT "<<"
RSHIFT ">>"
BITOP ({AND}|{OR}|{XOR}|{LSHIFT}|{RSHIFT})

LT "<"
LE "<="
GT ">"
GE ">="
EQ "=="
NE "!="
RELOP ({LT}|{LE}|{GT}|{GE}|{EQ}|{NE})

ASSIGNOP "="

AND_LOGIC_OP "&&"
OR_LOGIC_OP "||"
LOGICOP ({AND_LOGIC_OP}|{OR_LOGIC_OP})


%%
{WS} {}

{IF} {IncWc(); logFileToken("IF", yytext); tokenFileToken("IF", yytext);}
{FOR} {IncWc(); logFileToken("FOR", yytext); tokenFileToken("FOR", yytext);}
{DO} {IncWc(); logFileToken("DO", yytext); tokenFileToken("DO", yytext);}
{INT} {IncWc(); logFileToken("INT", yytext); tokenFileToken("INT", yytext);}

{FLOAT} {IncWc(); logFileToken("FLOAT", yytext); tokenFileToken("FLOAT", yytext);}
{VOID} {IncWc(); logFileToken("VOID", yytext); tokenFileToken("VOID", yytext);}
{SWITCH} {IncWc(); logFileToken("SWITCH", yytext); tokenFileToken("SWITCH", yytext);}
{DEFAULT} {IncWc(); logFileToken("DEFAULT", yytext); tokenFileToken("DEFAULT", yytext);}

{ELSE} {IncWc(); logFileToken("ELSE", yytext); tokenFileToken("ELSE", yytext);}
{WHILE} {IncWc(); logFileToken("WHILE", yytext); tokenFileToken("WHILE", yytext);}
{BREAK} {IncWc(); logFileToken("BREAK", yytext); tokenFileToken("BREAK", yytext);}
{CHAR} {IncWc(); logFileToken("CHAR", yytext); tokenFileToken("CHAR", yytext);}

{DOUBLE} {IncWc(); logFileToken("DOUBLE", yytext); tokenFileToken("DOUBLE", yytext);}
{RETURN} {IncWc(); logFileToken("RETURN", yytext); tokenFileToken("RETURN", yytext);}
{CASE} {IncWc(); logFileToken("CASE", yytext); tokenFileToken("CASE", yytext);}
{CONTINUE} {IncWc(); logFileToken("CONTINUE", yytext); tokenFileToken("CONTINUE", yytext);}

{Digits} {IncWc(); logFileToken("CONST_INT", yytext); tokenFileToken("CONST_INT", yytext);}
{Number} {IncWc(); logFileToken("CONST_FLOAT", yytext); tokenFileToken("CONST_FLOAT", yytext);}
{Character} {
	IncWc(); string character = yytext; character = character[1];
	logFileToken("CONST_CHAR", character); tokenFileToken("CONST_CHAR", character);
}
{EscapeCharacter} {
	IncWc();
	string escapeCharacter = "";
	if(strcmp(yytext, "\'\\n\'") == 0) escapeCharacter = '\n';
	if(strcmp(yytext, "\'\\r\'") == 0) escapeCharacter = '\r';
	if(strcmp(yytext, "\'\\t\'") == 0) escapeCharacter = '\t';
	if(strcmp(yytext, "\'\\v\'") == 0) escapeCharacter = '\v';
	if(strcmp(yytext, "\'\\a\'") == 0) escapeCharacter = '\a';
	if(strcmp(yytext, "\'\\f\'") == 0) escapeCharacter = '\f';
	if(strcmp(yytext, "\'\\b\'") == 0) escapeCharacter = '\b';
	if(strcmp(yytext, "\'\\0\'") == 0) escapeCharacter = '\0';
	if(strcmp(yytext, "\'\\'\'") == 0) escapeCharacter = '\'';
	if(strcmp(yytext, "\'\\\"\'") == 0) escapeCharacter = '\"';
	if(strcmp(yytext, "\'\\\\\'") == 0) escapeCharacter = '\\';

	logFileToken("CONST_CHAR", escapeCharacter); tokenFileToken("CONST_CHAR", escapeCharacter);
}
{UnfinishedNumbers} {logFileError("UNFINISHED_NUMBER", yytext); error_count++;}
{NumerousPointerNumber} {logFileError("TOO_MANY_DECIMAL_POINTS", yytext); error_count++;}
{pointInPowerNumber} {logFileError("ILLFORMED_NUMBER", yytext); error_count++;}
{InvalidEmptyCharacter} {logFileError("EMPTY_CONST_CHAR", yytext); error_count++;}
{UnfinishedCharacters} {logFileError("UNFINISHED_CONST_CHAR", yytext); error_count++;} 
{InvalidCharacters} {logFileError("MULTICHAR_CONST_CHAR", yytext); error_count++;}
{UnrecognizedCharacter} {logFileError("UNRECOGNIZED_CHAR", yytext); error_count++;}


{NOT} {logFileToken("NOT", yytext); tokenFileToken("NOT", yytext);}
{ADDOP} {logFileToken("ADDOP", yytext); tokenFileToken("ADDOP", yytext);}
{INCOP} {logFileToken("INCOP", yytext); tokenFileToken("INCOP", yytext);}

{MULOP} {logFileToken("MULOP", yytext); tokenFileToken("MULOP", yytext);}
{BITOP} {logFileToken("BITOP", yytext); tokenFileToken("BITOP", yytext);}
{ASSIGNOP} {logFileToken("ASSIGNOP", yytext); tokenFileToken("ASSIGNOP", yytext);}
{LOGICOP} {logFileToken("LOGICOP", yytext); tokenFileToken("LOGICOP", yytext);}
{RELOP} {logFileToken("RELOP", yytext); tokenFileToken("RELOP", yytext);}

{LPAREN} {logFileToken("LPAREN", yytext); tokenFileToken("LPAREN", yytext);}
{RPAREN} {logFileToken("RPAREN", yytext); tokenFileToken("RPAREN", yytext);}

{LCURL} {logFileToken("LCURL", yytext); tokenFileToken("LCURL", yytext); enterNewScopeTable();}
{RCURL} {logFileToken("RCURL", yytext); tokenFileToken("RCURL", yytext); exitCurrentScopeTable();}

{LSQUARE} {logFileToken("LSQUARE", yytext); tokenFileToken("LSQUARE", yytext);}
{RSQUARE} {logFileToken("RSQUARE", yytext); tokenFileToken("RSQUARE", yytext);}

{COMMA} {logFileToken("COMMA", yytext); tokenFileToken("COMMA", yytext);}
{SEMICOLON} {logFileToken("SEMICOLON", yytext); tokenFileToken("SEMICOLON", yytext);}

{ID} {IncWc(); logFileToken("ID", yytext); tokenFileToken("ID", yytext); manageIDinSymbolTable(yytext, "ID");}
{NumberPrefixID} {logFileError("INVALID_ID_SUFFIX_NUM_PREFIX", yytext); error_count++;}

{DOUBLE_QUOTES} {BEGIN(STRING); logStringLiteral += yytext;}
<STRING>{DOUBLE_QUOTES} {
	BEGIN(INITIAL); logStringLiteral += yytext;
	if(!multi_string_state){
		logFileToken("SINGLE LINE STRING", logStringLiteral);
		tokenFileToken("SINGLE LINE STRING", tokenStringLiteral);
	}
	else{
		logFileToken("MULTI LINE STRING", logStringLiteral);
		tokenFileToken("MULTI LINE STRING", tokenStringLiteral);
	}
	
	line_count += multi_line_count;
	multi_line_count = 0;

	multi_string_state = false;
	logStringLiteral="";
	tokenStringLiteral="";
}

<STRING>. {
	logStringLiteral += yytext; 
	tokenStringLiteral += yytext;
}
<STRING>\\. {
	logStringLiteral += yytext;
	if(strcmp(yytext, "\\n") == 0) {tokenStringLiteral += '\n';}
	if(strcmp(yytext, "\\r") == 0) tokenStringLiteral += '\r';
	if(strcmp(yytext, "\\t") == 0) tokenStringLiteral += '\t';
	if(strcmp(yytext, "\\v") == 0) tokenStringLiteral += '\v';
	if(strcmp(yytext, "\\a") == 0) tokenStringLiteral += '\a';
	if(strcmp(yytext, "\\f") == 0) tokenStringLiteral += '\f';
	if(strcmp(yytext, "\\b") == 0) tokenStringLiteral += '\b';
	if(strcmp(yytext, "\\0") == 0) tokenStringLiteral += '\0';
	if(strcmp(yytext, "\\'") == 0) tokenStringLiteral += '\'';
	if(strcmp(yytext, "\\\"") == 0) tokenStringLiteral += '\"';
	if(strcmp(yytext, "\\\\") == 0) tokenStringLiteral += '\\';
}
<STRING>\n {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

	logFileError("UNFINISHED_STRING", logStringLiteral); 
	error_count++;

	line_count++;
	multi_string_state = false;
	logStringLiteral="";
	tokenStringLiteral="";
}
<STRING>\\\n {
	multi_line_count++;
	multi_string_state = true;
	logStringLiteral += "\\\n";
	tokenStringLiteral += "";
}
<STRING><<EOF>> {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

	logFileError("UNFINISHED_STRING", stringLiteral); 
	error_count++;

	multi_string_state = false;
	stringLiteral="";
}



{BEGIN_MULTILINE_COMMENT} {BEGIN(MULTI_LINE_COMMENT); stringLiteral += yytext;}
<MULTI_LINE_COMMENT>{END_MULTILINE_COMMENT} {
	BEGIN(INITIAL); stringLiteral += yytext;
	logFileToken("MULTI LINE COMMENT", stringLiteral);

	line_count += multi_line_count;
	multi_line_count = 0;

	stringLiteral = "";	
}
<MULTI_LINE_COMMENT>. {
	stringLiteral += yytext;
}

<MULTI_LINE_COMMENT>\\. {
		stringLiteral += yytext;
}
<MULTI_LINE_COMMENT>\n {
	multi_line_count++;
	stringLiteral += "\n";
}
<MULTI_LINE_COMMENT><<EOF>> {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

	logFileError("UNFINISHED_COMMENT", stringLiteral); 
	error_count++;

	multi_string_state = false;
	stringLiteral="";
}

{BEGIN_SINGLELINE_COMMENT} {BEGIN(SINGLE_LINE_COMMENT); stringLiteral += yytext; multi_line_count++;}
<SINGLE_LINE_COMMENT>{END_SINGLELINE_COMMENT} {
	BEGIN(NEWLINE);

	logFileToken("SINGLE LINE COMMENT", stringLiteral);

	line_count += multi_line_count;
	multi_line_count = 0;
	stringLiteral = "";	
}
<SINGLE_LINE_COMMENT>. {
    stringLiteral += yytext;
}
<SINGLE_LINE_COMMENT>\\\n {
	multi_line_count++;
	stringLiteral += "\\\n";
}
<SINGLE_LINE_COMMENT><<EOF>> {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

	logFileToken("SINGLE LINE COMMENT", stringLiteral);

	multi_string_state = false;
	stringLiteral="";
}

[\n] {
	BEGIN(NEWLINE);
	line_count++;
	//cout<<line_count<<"  "<<indentation_tab_count<<endl;
}
<NEWLINE>[\t] {
	newline_tab_count++;
}
<NEWLINE>[ ] {
	newline_space_count++;
}
<NEWLINE>[^ \t] {
	if(strcmp(yytext, "}") == 0) indentation_tab_count--;

	int currentTab = newline_tab_count;
	if(newline_space_count%4==0){
		currentTab += (newline_space_count/4);
	}

	if((indentation_tab_count == currentTab) && (newline_space_count%4==0)){
		//No action required
	}
	else if(strcmp(yytext, "\n") == 0){
		//No action required
	}
	else if(newline_space_count == 0){
		logStream<<"Line# "<<line_count<<": warning, "<<indentation_tab_count<<" of tabs needed but got "<<newline_tab_count<<" tabs."<<endl;
		warning_count++;
	}
	else if(newline_space_count != 0){
		logStream<<"Line# "<<line_count<<": Warning, tab requrired but got space."<<endl;
		warning_count++;
	}

	newline_space_count =0;
	newline_tab_count = 0;
	if(strcmp(yytext, "}") == 0) indentation_tab_count++;

	BEGIN(INITIAL);
	yyless(0);
}
<<EOF>> {
	printAllScopeTable();

	logStream<<"Total lines: "<<line_count<<endl;
	logStream<<"Total errors: "<<error_count<<endl;
	logStream<<"Total warnings: "<<warning_count<<endl;

	return 0;
}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
