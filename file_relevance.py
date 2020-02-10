#!/usr/bin/python
#The program checks if a given file (path) has been modified in the last N (time) minutes
#using python stat module

import os, getopt, sys, stat, time

def usage():
  print "Usage:"
  print "-p   path to a file"
  print "-t   minutes of relevance"

if (len(sys.argv[1:]) != 4):
  usage()
  sys.exit(1)

try:
  options, args = getopt.getopt(sys.argv[1:], 'p:t:h', ['path=','time='])
except getopt.GetoptError as err:
  print str(err)
  usage()
  sys.exit(1)

for opt, arg in options:
  if opt in ('-p', '--path'):
    var_path = arg
  elif opt in ('-t', '--time'):
    var_time = int(arg)
  elif opt in ('-h', '--help'):
    usage()
    sys.exit()
  else:
    assert False, "unhandled option"

mtime = os.stat(var_path).st_mtime

if (time.time() - mtime <= var_time * 60):
  print "1"
else:
  print "0"

