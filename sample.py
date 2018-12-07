#/usr/bin/env python
import fnmatch
import os

filter = ['*.iso']
matches = []

for root, dirs, files in os.walk('/Users/alexantonov/Downloads/VMware'):
	for extensions in filter:
		for file in fnmatch.filter(files, extensions):
			matches.append(os.path.join(root, file))

print(matches)
