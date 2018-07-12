import sys, random
from lab1utils import loadImage, gridFromImage, setChunkBorder, imageFromGrid, saveImage, whoIsHere, reduce

def sequentialSearch(image_grid):
    res = {"wally": [0, 0], "wilma": [0, 0], "wizard": [0, 0], "odlaw": [0, 0]}
    for i in range(len(image_grid)):
        who, prob = whoIsHere(image_grid[i])
        if(prob > res[who][0]):
            res[who][0] = prob
            res[who][1] = image_grid[i]
    return res

def myMap(chunk):
    who, prob = whoIsHere(chunk)
    yield (who, (prob, chunk))

def myReduce(key, values):
    best = None
    for value in values:
        if best is None or value[0] > best[0]:
            best = value
    return key, best

def parallelSearch(image_grid):
    map_result = map(myMap, image_grid)
    result = reduce(myReduce, map_result)
    return dict((w, (p, c)) for w, (p, c) in result)

def main():
    image = loadImage(sys.argv[1])
    image_grid = gridFromImage(image, 16)

    # res = sequentialSearch(image_grid)
    res = parallelSearch(image_grid)

    print("We found Wally! We are %lf%% sure!" % (float(res["wally"][0])*100))
    print("We found Wilma! We are %lf%% sure!" % (float(res["wilma"][0])*100))
    print("We found Wizard! We are %lf%% sure!" % (float(res["wizard"][0])*100))
    print("We found Odlaw! We are %lf%% sure!" % (float(res["odlaw"][0])*100))

    setChunkBorder(res["wally"][1], [255, 0, 0])
    setChunkBorder(res["wilma"][1], [0, 255, 255])
    setChunkBorder(res["wizard"][1], [255, 0, 255])
    setChunkBorder(res["odlaw"][1], [0, 255, 0])

    image = imageFromGrid(image_grid, 16)
    saveImage("output.png", image)

if __name__ == '__main__':
    main()

