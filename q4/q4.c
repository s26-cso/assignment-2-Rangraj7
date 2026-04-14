#include<stdio.h>
#include<dlfcn.h>
#include<string.h>

typedef int(*func) (int,int);
int main(){
    char op[6];
    int num1,num2;
    while(1){
        int check=scanf("%5s %d %d",op,&num1,&num2);    //scanf returns 3 if successfully reads all the 3 values
        if(check==EOF || check!=3)break;
        char filename[5+3+1+strlen(op)];
        strcpy(filename,"./lib");
        strcat(filename,op);
        strcat(filename,".so");

        void* lib=dlopen(filename,RTLD_LAZY);  //trying to open the library at runtime
        if(lib){   //if there's some error while loading the library don't check for the function inside it
            func function=dlsym(lib,op);   //check for the the function inside the library module
            if(function){   //if the function found then execute it with the given values of num1 and num2
                int ans=function(num1,num2);
                printf("%d\n",ans);
            }
            dlclose(lib);  //close the library after each execution so that memory limit doesn't exceed 2 gb limit
        }
    }
    return 0;
}