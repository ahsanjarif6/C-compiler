#ifndef SYMBOLTABLE_H_INCLUDED
#define SYMBOLTABLE_H_INCLUDED

#include "1905092_ScopeTable.h"
#include "1905092_SymbolInfo.h"

class SymbolTable{
private:
    
public:
    ScopeTable* cur_scope ;
    int num_buckets ;
    int cnt ;

    SymbolTable(int m){
        cnt = 1 ;
        cur_scope = new ScopeTable(m , cnt) ;
        num_buckets = m ;
    }

    ~SymbolTable(){
        while(cur_scope){
            ScopeTable* t = cur_scope ;
            cur_scope = cur_scope->parent_scope ;
            delete t ;
        }
    }

    void EnterScope(){
        cnt ++ ;
        ScopeTable* new_scope = new ScopeTable(num_buckets , cnt) ;
        new_scope->parent_scope = cur_scope ;
        cur_scope = new_scope ;
    }

    void ExitScope(){
        if(cur_scope->number == 1){
            cout << "    ScopeTable# " << 1 << " cannot be removed" << endl ;
            return ;
        }
        //cout << "    ScopeTable# " << cur_scope->number << " removed" << endl ;
        if(cur_scope){
            ScopeTable* t = cur_scope ;
            cur_scope = cur_scope->parent_scope ;
            delete t ;
        }
    }

    bool Insert(SymbolInfo ob){
        //cout << "ekhane dhukse" << endl;
        return cur_scope->Insert(ob) ;
    }

    bool Remove(SymbolInfo ob){
        SymbolInfo* symInfo = cur_scope->LookUp(ob.getName()) ;
        if(symInfo){
            pair< int , int > p = cur_scope->Pos(ob.getName()) ;
            int h = p.first ;
            int k = p.second ;
            cout << "    Deleted " << "'" << ob.getName() << "'" << " from ScopeTable# " << cur_scope->number << " at position " << h << ", " << k << endl ;
            cur_scope->Delete(ob.getName()) ;
            //cnt -- ;
            return true ;
        }
        cout << "    " << "Not found in the current ScopeTable" << endl ;
        return false ;
        // bool ok = cur_scope->Delete(ob.getName()) ;
        // if(ok){
        //     cnt -- ;

        // }
        // return ok ;
    }

    SymbolInfo* LookUp(string s){
        ScopeTable* t = cur_scope ;
        while(t){
            SymbolInfo* symInfo = t->LookUp(s) ;
            if(symInfo){
                pair< int , int > p = t->Pos(s) ;
                int h = p.first ;
                int k = p.second ;
                //cout << "    " << "'" << s << "'" << " found in ScopeTable# " << t->number << " at position " << h << ", " << k << endl ;
                return symInfo ;
            }
            t = t->parent_scope ;
        }
        //cout << "    " << "'" << s << "'" << " not found in any of the ScopeTables" << endl ;
        return NULL ;
    }

    void PrintCurrent(FILE* logout){
        cur_scope->Print(logout) ;
    }

    void PrintAll(FILE* logout){
        ScopeTable* t = cur_scope ;
        while(t){
            t->Print(logout) ;
            t = t->parent_scope ;
        }
    }
};

#endif 
