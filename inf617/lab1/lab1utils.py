import cv2
import numpy as np
from itertools import groupby, starmap, chain

faces = np.load('faces.npz')
wallies  = [faces["wally1"], faces["wally2"]] 
odlaws   = [faces["odlaw1"], faces["odlaw2"]] 
wilmas   = [faces["wilma1"], faces["wilma2"]] 
wizards  = [faces["wizard1"], faces["wizard2"]] 

def reduce(func, iterable):
    iterable = chain(*list(map(list, iterable)))
    iterable = groupby(sorted(list(iterable), key=lambda x: x[0]), key=lambda x: x[0])
    iterable = map(lambda x: (x[0], list(map(lambda x: x[1], x[1]))), iterable)
    return starmap(func, iterable)
    
def isXHere(X, img):
    max_prob = 0
    for face in X:
        result = cv2.matchTemplate(img, face, cv2.TM_CCOEFF_NORMED)
        _, prob,_,_ = cv2.minMaxLoc(result)
        max_prob = max(max_prob, prob)
    return max_prob

def whoIsHere(img):
    chars = {
        "wally"  : isXHere(wallies, img),
        "odlaw"  : isXHere( odlaws, img),
        "wilma"  : isXHere( wilmas, img),
        "wizard" : isXHere(wizards, img)
    }
    maxChar = max(chars, key=lambda x: chars[x])
    return (maxChar, chars[maxChar])

def setChunkBorder(chunk, color):
    chunk[0:5,:] = color
    chunk[:,0:5] = color
    chunk[-5:-1,:] = color
    chunk[:,-5:-1] = color

def loadImage(name):
    return cv2.imread(name)

def saveImage(name, image):
    return cv2.imwrite(name, image)


def gridFromImage(image, size):
    grid = np.array([np.array_split(i, size) for i in np.array_split(image, size, axis=1)])
    return grid.reshape(size**2, *grid.shape[2:])

def imageFromGrid(grid, size):
    return np.concatenate([np.concatenate(grid.reshape(size, size, *grid.shape[1:])[i,:]) for i in range(size)], axis=1)