#include <stdio.h>

int isPalindrome(unsigned long orig);
int isPrime(unsigned long orig);

int main(void) {
  long unsigned j=0,m1,m2;
  long unsigned max=0;
  long unsigned erat[10000];

  for(long unsigned i=10001;i<100000;i+=2) if(isPrime(i)) {erat[j]=i;j++;}
  for(long unsigned i1=0;i1<j;i1++){
    for(long unsigned i2=i1;i2<j;i2++){
      long unsigned p=erat[i1]*erat[i2];
      if(isPalindrome(p)&&p>max){
        max=p;
	m1=erat[i1];
	m2=erat[i2];
      }
    }
  }
  printf("The number of primes in the interval: %lu\n",j);
  printf("Max palindrome is: %lu x %lu = %lu\n",m1,m2,max);
}

int isPalindrome(long unsigned orig) {
  long unsigned reversed = 0, n = orig;

  while (n>0) {
    reversed=reversed*10+n%10;
    n/=10;
  }

  return orig==reversed;
}

int isPrime(long unsigned orig){
  if(orig==2) return 1;
  if(orig==3) return 1;
  if(orig%2==0) return 0;
  if(orig%3==0) return 0;
  int unsigned i=5;
  int unsigned w=2;
  while(i*i<=orig) {
    if(orig%i==0) return 0;
    i+=w;
    w=6-w;
  }
  return 1;
}
