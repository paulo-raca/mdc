#!/usr/bin/env python
import sys
import re

for line in sys.stdin:
    for word in re.findall(r'(\w+)', line):
        print("%s\t%d" % (word, 1))
