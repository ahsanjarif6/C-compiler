#pragma once
#include<iostream>
#include "1905092_SymbolInfo.h"
#include "1905092_ScopeTable.h"
#include "1905092_SymbolTable.h"
using namespace std ;

int check(string s){
    int c = 0 ;
    for(int i = 0 ; i < s.size() ; i ++ ){
        if(s[i] == ' ' ) c ++ ;
    }
    return c ;
}

string getToken(int c , string s){
    string r ;
    int cnt = 0 ;
    for(int i = 0 ; i < s.size() ; i ++ ){
        if(s[i] == ' '){
            cnt ++ ;
        }
        else{
            if(cnt == c){
                int j = i ;
                while(j < s.size() && s[j] != ' ' ){
                    r += s[j] ;
                    j ++ ;

                }
                break ;
            }
        }
    }
    return r ;
}

int main(){
    freopen("sample_input.txt","r",stdin);
    freopen("out.txt","w",stdout);
    int n ;
    cin >> n ;
    char c ;
    SymbolTable st(n) ;
    int cmd = 1 ;
    while(1){
        string input ;
        getline(cin , input) ;
        c = input[0] ;
        if(c == 'I'){
            int m = check(input) ;
            if(m != 2){
                cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
                cout << "    Number of parameters mismatch for the command I\n" ;
                continue ;
            }
            cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
            string s[2] ;
            s[0] = getToken(1 , input) ;
            s[1] = getToken(2 , input) ;
            SymbolInfo ob(s[0] , s[1] , NULL) ;
            st.Insert(ob) ;
        }
        else if(c == 'L'){
            int m = check(input) ;
            if(m != 1){
                cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
                cout << "    Number of parameters mismatch for the command L\n" ;
                continue ;
            }
            string s = getToken(1 , input) ;
            cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
            st.LookUp(s) ;
        }
        else if(c == 'D'){
            int m = check(input) ;
            if(m != 1){
                cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
                cout << "    Number of parameters mismatch for the command D\n" ;
                continue ;
            }
            string s = getToken(1 , input) ;
            cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
            SymbolInfo symInfo(s , "" , NULL) ;
            st.Remove(symInfo) ;
        }
        else if(c == 'P'){
            int m = check(input) ;
            if(m != 1){
                cout << "Cmd " << cmd ++ << ": "<< input << '\n' ;
                cout << "    Number of parameters mismatch for the command P\n" ;
                continue ;
            }
            cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
            string s = getToken(1 , input) ;
            if(s == "A"){
                st.PrintAll() ;
            }
            else if(s == "C"){
                st.PrintCurrent() ;
            }
            else{

            }
        }
        else if(c == 'S'){
            int m = check(input) ;
            if(m != 0){
                cout << "Cmd " << cmd ++ << ": "<< input << '\n' ;
                cout << "    Number of parameters mismatch for the command P\n" ;
                continue ;
            }
            cout << "Cmd " << cmd ++ << ": " << input  << '\n' ;
            st.EnterScope() ;
        }
        else if(c == 'E'){
            int m = check(input) ;
            if(m != 0){
                cout << "Cmd " << cmd ++ << ": "<< input << '\n' ;
                cout << "    Number of parameters mismatch for the command P\n" ;
                continue ;
            }
            cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
            st.ExitScope() ;
        }
        else if(c == 'Q'){
            cout << "Cmd " << cmd ++ << ": " << input << '\n' ;
            break ;
        }
    }
    return 0 ;
}
