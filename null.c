#include <stdio.h>
int main( )
{
int c;
setvbuf(stdin, NULL, _IONBF, 0); //turn off buffering
setvbuf(stdout, NULL, _IONBF, 0); //turn off buffering
while (( c = getchar() ) != EOF )
{
   putchar( c );
   putchar( '\0' );
}

   return 0;
}
