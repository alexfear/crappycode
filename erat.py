#!/bin/python
import math
N=20
prime=[True]*N
for i in range(2,int(math.sqrt(N))):
  if prime[i]:
    j=i*i
    while j<N:
      prime[j]=False
      j+=i
for i in range(20):
	if prime[i]:
		print(i)
