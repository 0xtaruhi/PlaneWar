'''
Description  : 
Author       : Zhengyi Zhang
Date         : 2021-11-02 15:41:55
LastEditTime : 2021-11-02 18:59:57
LastEditors  : Zhengyi Zhang
FilePath     : \PlaneWar\temp\gen_coe.py
'''

import numpy as np
import matplotlib.pyplot as plt
import cv2

img = cv2.imread("D:\\fpga\\project\\PlaneWar\\src\\img\\origin\\me1.png", cv2.IMREAD_UNCHANGED)
plt.imshow(img)

def list_aver(list):
    aver = 0
    for item in list:
        aver = aver + item
    aver = aver / len(list)
    return aver

def gray(img):
    height, weight, g = (img.shape)
    gray_info = []
    for row in range(height):
        row_info = []
        for col in range(weight):
            row_info.append([(int)(list_aver(img[row][col][0:3])/16), (int)(img[row][col][3]/128)])
        gray_info.append(row_info)
    return gray_info

with open("D:\\fpga\\project\\PlaneWar\\temp\\me1.coe", 'w') as f:
    f.write("memory_initialization_radix = 2;\n")
    f.write("memory_initialization_vector = \n")
    gray_info = gray(img)
    for row in range(len(gray_info)):
        for col in range(len(gray_info[0])):
            binary_str = bin(gray_info[row][col][0])[2:]
            if len(binary_str) < 4:
                l = 4 - len(binary_str)
                binary_str = l*'0' + binary_str
            alpha = gray_info[row][col][1]
            binary_str = binary_str + str(alpha)
            f.write(binary_str+",\n")
            