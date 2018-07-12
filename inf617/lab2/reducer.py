#!/usr/bin/env python3
import sys

previousKey = None
count = 0

for line in sys.stdin:
    key, value = line.strip().split("\t", 1)
    if key != previousKey:
        if previousKey is not None:
            print("%s\t%d" % (previousKey, count))
        previousKey = key
        count = 0
    count += 1

if previousKey is not None:
    print("%s\t%d" % (previousKey, count))
