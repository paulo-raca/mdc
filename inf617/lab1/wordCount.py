import sys
from lab1utils import reduce
import re

def myMap(line):
    for word in re.findall(r'(\w+)', line):
        yield (word, 1)

def myReduce(key, values):
    return (key, sum(values))


def main():
    f = open(sys.argv[1])
    lines = f.readlines()
    f.close()

    map_result = map(myMap, lines)
    result = reduce(myReduce, map_result)
    print(list(result))


if __name__ == '__main__':
    main()
