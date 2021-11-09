import numpy as np
import matplotlib.pyplot as plt
import cv2

class GenCoe:
    def __init__(self, dir:str, filename:str, mode="gray"):
        self.dir = dir
        self.filename = filename
        loc = self.dir + "\\" + self.filename
        self.img = cv2.imread(loc, cv2.IMREAD_UNCHANGED)
        self.height, self.weight, g = (self.img.shape)
        self.grayinfo = np.empty((self.height * self.weight)).astype(np.int32)
        self.alphainfo = np.empty((self.height * self.weight)).astype(np.int32)
        if mode == "gray":
            self.gray()
            
    def readimage(self, dir, filename, mode="gray"):
        GenCoe.__init__(dir, filename, mode);
        
    def gray(self):
        def list_aver(list):
            aver = 0
            for item in list:
                aver += item
            aver /= len(list)
            return aver
        for row_idx in range(self.height):
            for col_idx in range(self.weight):
                self.grayinfo[row_idx * self.weight + col_idx] = (int)(list_aver(self.img[row_idx][col_idx][0:3]/16))
                self.alphainfo[row_idx * self.weight + col_idx] = (int)(self.img[row_idx][col_idx][3]/128)
                
    def get_grayinfo(self):
        return self.grayinfo
    
    def get_alphainfo(self):
        return self.alphainfo
    
    def to_binary(num, bitlen=-1):
        res = bin(num)[2:]
        if bitlen == -1:
            return res
        else:
            for i in range(bitlen - len(res)):
                res = '0' + res
            return res
        
    def generate_coe(dir, filename, alphainfo, *grayinfos):
        coefile_location = dir + "\\" + filename
        depth = len(alphainfo)
        with open(coefile_location, 'w') as f:
            f.write("memory_initialization_radix = 2;\n")
            f.write("memory_initialization_vector = \n")
            for i in range(depth):
                rowinfo = ""
                rowinfo += str(alphainfo[i])
                for grayinfo in grayinfos:
                    rowinfo += GenCoe.to_binary(grayinfo[i], bitlen=4)
                f.write(rowinfo + ",\n")
        print("Generate COE file successfully, the depth is " + str(depth))
            
    
if __name__ == "__main__":
    ori_dir = "D:\\fpga\\project\PlaneWar\\src\\img\\origin"
    des_dir = "D:\\fpga\\project\PlaneWar\\src\\img"
    me1 = GenCoe(ori_dir, "me1.png")
    me2 = GenCoe(ori_dir, "me2.png")
    me_destroy_1 = GenCoe(ori_dir, "me_destroy_1.png")
    me_destroy_3 = GenCoe(ori_dir, "me_destroy_3.png")
    me_destroy_4 = GenCoe(ori_dir, "me_destroy_4.png")
    GenCoe.generate_coe(des_dir, "me.coe", me1.get_alphainfo(), me1.get_grayinfo(), me2.get_grayinfo(),
        me_destroy_1.get_grayinfo(), me_destroy_3.get_grayinfo(), me_destroy_4.get_grayinfo())
    