#ifndef SYMBOLINFO_H_INCLUDED
#define SYMBOLINFO_H_INCLUDED


#include<bits/stdc++.h>
using namespace std ;
class SymbolInfo{
private:
    string name , type ;
public:
    SymbolInfo* next ;
    string dataType;
    int info;
    int size;
    vector<pair<string,string>>parameters;


    string label;

    
    string asmName; 
    int arrayStart; 
    bool isGlobal;


    static const int VAR = 1;
    static const int FuncDec = 2;
    static const int FuncDef = 3;

    void copy(SymbolInfo* other){
        this->name = other->name;
        this->type = other->type;
        this->next = other->next;
        this->asmName = other->asmName;
        this->arrayStart = other->arrayStart;
        this->isGlobal = other->isGlobal;
        this->dataType = other->dataType;
        this->info = other->info;
        this->size = other->size;
        this->parameters = other->parameters;
    }

    SymbolInfo(){
        next = NULL ;
        name = type = "" ;
    }

    SymbolInfo(string name , string type){
        this->name = name ;
        this->type = type ;
        this->dataType = type;
        this->next = NULL ;
        this->size = 0;
        this->info = 1 ;
    }

    SymbolInfo(string name , string type , SymbolInfo* next){
        this->name = name ;
        this->type = type ;
        this->dataType = type;
        this->next = next ;
        this->size = 0;
        this->info = 1 ;
    }

    SymbolInfo(string dataType){
        this->dataType = dataType;
    }

    SymbolInfo(const SymbolInfo &other)
    {
        this->name = other.name;
        this->type = other.type;
        this->next = other.next;
        this->asmName = other.asmName;
        this->arrayStart = other.arrayStart;
        this->isGlobal = other.isGlobal;
        this->dataType = other.dataType;
        this->info = other.info;
        this->size = other.size;
        this->parameters = other.parameters;
    }

    ~SymbolInfo(){
        //delete next ;
    }

    string getName(){
        return name ;
    }

    string getType(){
        return type ;
    }

    void setName(string name){
        this->name = name ;
    }

    void setType(string type){
        this->type = type ;
    }

    void addParam(string name , string dataType){
        parameters.push_back({name,dataType});
    }
    
    bool isFunc(){
        return (info != 1) ;
    }

    void copy(SymbolInfo ob){
        this->name = ob.getName();
        this->type = ob.getType();
        this->next = ob.next;
        this->asmName = ob.asmName;
        this->arrayStart = ob.arrayStart;
        this->isGlobal = ob.isGlobal;
        this->dataType = ob.dataType;
        this->info = ob.info;
        this->size = ob.size;
        this->parameters = ob.parameters;
        this->isGlobal = ob.isGlobal;
    }


    string getAsmName(){
        return asmName;
    }

    string getAsmName(int idx){
        if(isGlobal){
            return asmName+"[SI+"+to_string(idx)+"]";
        }
        int offset = arrayStart + idx*2;
        return "[BP-"+to_string(offset)+"]";
    }

    void setAsmName(string asmName,bool global=false, int arrayStart=0)
    {
        this->asmName = asmName;
        this->isGlobal = global;
        this->arrayStart = arrayStart;
    }
};
#endif
