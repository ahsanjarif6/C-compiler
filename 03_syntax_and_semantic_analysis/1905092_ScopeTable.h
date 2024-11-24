#ifndef SCOPETABLE_H_INCLUDED
#define SCOPETABLE_H_INCLUDED

#include <bits/stdc++.h>
#include "1905092_SymbolInfo.h"
using namespace std ;
class ScopeTable{
private:
    static unsigned long long SDBMHash(string str) {
        unsigned long long hash = 0;
        unsigned long long i = 0;
        unsigned long long len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    }

    string allCap(string input){
        transform(input.begin(), input.end(), input.begin(), ::toupper);
        return input;
    }

public:

    SymbolInfo** chain ;
    ScopeTable* parent_scope ;
    int number ;
    int num_buckets ;

    int hash(string s){
        return SDBMHash(s) % num_buckets ;
    }

    ScopeTable(int m , int c){
        num_buckets = m ;
        chain = new SymbolInfo*[m] ;
        for(int i = 0 ; i < num_buckets ; i ++ ) chain[i] = NULL ;
        number = c ;
        parent_scope = NULL ;
        //cout << "    ScopeTable# " << number << " created" << endl ;
    }

    ~ScopeTable(){
        //cout << "    " << "ScopeTable# " << number << " removed" << endl ;
        for(int i = 0 ; i < num_buckets ; i ++ ){
            SymbolInfo* cur = chain[i] ;
            while(cur){
                SymbolInfo* t = cur ;
                cur = cur->next ;
                delete t ;
            }
        }
    }

    bool Insert(SymbolInfo ob){
        int pos = 1 ;
        int h = hash(ob.getName()) ;
        SymbolInfo* insert_ob = new SymbolInfo(ob.getName() , ob.getType() , NULL) ;
        if(chain[h] == NULL){
            //cout << "    Inserted in ScopeTable# " << number << " at position " << h + 1 << ", " << pos << endl ;
            chain[h] = insert_ob ;
            return true ;
        }
        SymbolInfo* cur = chain[h] ;
        if(cur->getName() == ob.getName()){
            //cout << "    " << "'" << ob.getName() << "'" << " already exists in the current ScopeTable" << endl ;
            return false ;
        }
        pos ++ ;
        while(cur->next){
            pos ++ ;
            if(cur->getName() == ob.getName()){
                //cout << "    " << "'" << ob.getName() << "'" << " already exists in the current ScopeTable" << endl ;
                return false ;
            }
            cur = cur->next ;
        }
        cur->next = insert_ob ;
        //cout << "    Inserted in ScopeTable# " << number << " at position " << h + 1 << ", " << pos << endl ;
        //cout << "okay" << endl;
        return true ;
    }

    SymbolInfo* LookUp(string s){
        int h = hash(s) ;
        SymbolInfo* cur = chain[h] ;
        while(cur){
            if(cur->getName() == s){
                return cur ;
            }
            cur = cur->next ;
        }
        return NULL ;
    }

    pair< int , int > Pos(string s){
        int h = hash(s) ;
        int pos = 0 ;
        SymbolInfo* cur = chain[h] ;
        while(cur){
            pos ++ ;
            if(cur->getName() == s){
                return {h + 1 , pos} ;
            }
            cur = cur->next ;
        }
        return {-1 , -1} ;
    }

    bool Delete(string s){
        int h = hash(s) ;
        SymbolInfo* cur = chain[h] ;
        SymbolInfo* prev = NULL ;
        while(cur){
            if(cur->getName() == s){
                if(prev){
                    prev->next = cur->next ;
                }
                else{
                    chain[h] = cur->next ;
                }
                delete cur ;
                return true ;
            }
            prev = cur ;
            cur = cur->next ;
        }
        return false ;
    }

    void Print(FILE* logout){
        //cout << "    ScopeTable# " << number << endl ;
        fprintf(logout , " \tScopeTable# %d\n" , number) ;
        for(int i = 0 ; i < num_buckets ; i ++ ){
            SymbolInfo* cur = chain[i] ;
            if(cur == NULL) continue; 
            //cout << "    " << i + 1 << "--> " ;
            fprintf(logout , "\t%d--> " , i + 1) ;
            while(cur){
                //cout << "<" << cur->getName() << ',' << cur->getType() << "> " ;
                if(cur->isFunc())  fprintf(logout , "<%s, FUNCTION, %s> " , cur->getName().c_str() , allCap(cur->dataType).c_str()) ;
                else if(cur->size)  fprintf(logout , "<%s, ARRAY, %s> " , cur->getName().c_str() , allCap(cur->dataType).c_str()) ;
                else fprintf(logout , "<%s, %s> " , cur->getName().c_str() , allCap(cur->dataType).c_str()) ;
                cur = cur->next ;
            }
            fprintf(logout , "\n") ;
            //cout << endl ;
        }
    }

};

#endif 