#ifndef SYMBOLINFO_H_INCLUDED
#define SYMBOLINFO_H_INCLUDED


#include<string>
using namespace std ;
class SymbolInfo{
private:
    string name , type ;
public:
    SymbolInfo* next ;

    SymbolInfo(){
        next = NULL ;
        name = type = "" ;
    }

    SymbolInfo(string name , string type , SymbolInfo* next){
        this->name = name ;
        this->type = type ;
        this->next = next ;
    }

    ~SymbolInfo(){
        delete next ;
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
};
#endif
