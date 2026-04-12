#include<stdio.h>
#include<dlfcn.h>
#include<string.h>

typedef int(*func) (int,int);
int main(){
    char op[6];
    int num1,num2;
    while(scanf("%5s %d %d",op,&num1,&num2)==3){
        char filename[5+3+1+strlen(op)];
        strcpy(filename,"./lib");
        strcat(filename,op);
        strcat(filename,".so");

        void* function=dlopen(filename,RTLD_LAZY);
        func temp=dlsym(function,op);
        int ans=temp(num1,num2);
        printf("%d\n",ans);
        dlclose(function);
    }
}