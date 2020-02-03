import math

isPalindrom = 0
isPrime = 0

def main():
  j = m1 = m2 = max = 0
  erat=[]
  for i in range(10001, 99999, 2):
    if isPrime(i):
      erat.append(i)
      j+=1

  for i1 in range(0, j):
    for i2 in range(i1, j):
      p = erat[i1] * erat[i2]
      if isPalindrome(p) and p > max:
        max = p
	m1 = erat[i1]
	m2 = erat[i2]

  print "The number of primes in the interval is " + str(j)
  print "The multipliers are " + str(m1) + " * " + str(m2)
  print "The palindrome is " + str(max)

def isPalindrome(orig):
  reversed = 0
  n = orig;
  while n > 0:
    reversed = reversed * 10 + n % 10
    n/=10
  return orig==reversed

def isPrime(orig):
  if orig == 2:
    return 1
  if orig == 3:
    return 1
  if orig%2 == 0:
    return 0
  if orig%3 == 0:
    return 0
  i = 5
  w = 2
  while i*i <= orig:
    if orig%i == 0:
      return 0
    i+=w
    w=6-w
  return 1

main()

