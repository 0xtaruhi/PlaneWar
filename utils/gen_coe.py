import numpy as np
import matplotlib.pyplot as plt
import cv2

class GenCoe:
    def __init__(self, dir:str, filename:str, mode="gray"):
        self.dir = dir
        self.filename = filename
        loc = self.dir + "\\" + self.filename
        self.img = cv2.imread(loc, cv2.IMREAD_UNCHANGED)
        self.height, self.width, g = (self.img.shape)
        self.grayinfo = np.empty((self.height * self.width)).astype(np.int32)
        self.alphainfo = np.empty((self.height * self.width)).astype(np.int32)
        self.colorinfo = np.empty((self.height * self.width, 3)).astype(np.int32)
        self.monoinfo = np.empty((self.height, self.width)).astype(np.int8)
        if mode == "gray":
            self.gray()
        elif mode == "mono":
            self.mono()
        elif mode == "color":
            self.color()
            
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
            for col_idx in range(self.width):
                self.grayinfo[row_idx * self.width + col_idx] = (int)(list_aver(self.img[row_idx][col_idx][0:3]/16))
                self.alphainfo[row_idx * self.width + col_idx] = (int)(self.img[row_idx][col_idx][3]/128)
                
    def color(self):
        for row_idx in range(self.height):
            for col_idx in range(self.width):
                self.colorinfo[row_idx * self.width + col_idx][0] = (int)(self.img[row_idx][col_idx][2] / 16)
                self.colorinfo[row_idx * self.width + col_idx][1] = (int)(self.img[row_idx][col_idx][1] / 16)
                self.colorinfo[row_idx * self.width + col_idx][2] = (int)(self.img[row_idx][col_idx][0] / 16)
                self.alphainfo[row_idx * self.width + col_idx] = (int)(self.img[row_idx][col_idx][3] / 128)
                
    def mono(self):
        for row_idx in range(self.height):
            for col_idx in range(self.width):
                # self.monoinfo[row_idx][col_idx] = (int)(self.img[row_idx][col_idx][3] / 128)
                pixel = self.img[row_idx][col_idx]
                self.monoinfo[row_idx][col_idx] = 1 if (int(pixel[0]) + int(pixel[1]) + int(pixel[2]) < 300) else 0
                
    def get_grayinfo(self):
        return self.grayinfo
    
    def get_alphainfo(self):
        return self.alphainfo
    
    def get_monoinfo(self):
        return self.monoinfo
    
    def get_colorinfo(self):
        return self.colorinfo
    
    def to_binary(num, bitlen=-1):
        res = bin(num)[2:]
        if bitlen == -1:
            return res
        else:
            for i in range(bitlen - len(res)):
                res = '0' + res
            return res
        
    def generate_coe(dir, filename, *infos):
        coefile_location = dir + "\\" + filename
        depth = len(infos[0][1])
        with open(coefile_location, 'w') as f:
            f.write("memory_initialization_radix = 2;\n")
            f.write("memory_initialization_vector = \n")
            for i in range(depth):
                rowinfo = ""
                for info in infos:
                    if(info[0] == 'gray'):
                        rowinfo += GenCoe.to_binary(info[1][i], bitlen=4)
                    elif(info[0] == 'alpha'):
                        rowinfo += str(info[1][i])
                    elif(info[0] == 'mono'):
                        for j in range(len(info[1][i])):
                            rowinfo += str(info[1][i][j]) + ",\n"
                    elif(info[0] == 'color'):
                        rowinfo += GenCoe.to_binary(info[1][i][0], bitlen=4)
                        rowinfo += GenCoe.to_binary(info[1][i][1], bitlen=4)
                        rowinfo += GenCoe.to_binary(info[1][i][2], bitlen=4)
                if info[0] == 'mono':
                    f.write(rowinfo)
                else:
                    f.write(rowinfo + ",\n")
        print("Generate COE file " + filename + " successfully, the depth is " + str(depth))
            
if __name__ == "__main__":
    ori_dir = "D:\\fpga\\project\PlaneWar\\src\\img\\origin"
    des_dir = "D:\\fpga\\project\PlaneWar\\src\\img"
    def gen_me():
        me1 = GenCoe(ori_dir, "me1.png")
        me2 = GenCoe(ori_dir, "me2.png")
        me_destroy_1 = GenCoe(ori_dir, "me_destroy_1.png")
        me_destroy_3 = GenCoe(ori_dir, "me_destroy_3.png")
        me_destroy_4 = GenCoe(ori_dir, "me_destroy_4.png")
        # GenCoe.generate_coe(des_dir, 'me.coe', ('alpha', me1.get_alphainfo()), ('gray', me1.get_grayinfo()), \
        #                     ('alpha', me2.get_alphainfo()), ('gray', me2.get_grayinfo()), \
        #                     ('gray', me_destroy_1.get_grayinfo()), ('gray', me_destroy_3.get_grayinfo()), \
        #                     ('gray', me_destroy_4.get_grayinfo()))
        GenCoe.generate_coe(des_dir, 'me.coe', ('alpha', me1.get_alphainfo()), ('gray', me1.get_grayinfo()),\
            ('alpha', me2.get_alphainfo()), ('gray', me2.get_grayinfo()),\
                ('alpha', me_destroy_1.get_alphainfo()), ('gray', me_destroy_1.get_grayinfo()), \
                    ('alpha', me_destroy_3.get_alphainfo()), ('gray', me_destroy_3.get_grayinfo()))

    def gen_enemy1():
        enemy1 = GenCoe(ori_dir, "enemy1.png")
        enemy1_down1 = GenCoe(ori_dir, "enemy1_down1.png")
        enemy1_down2 = GenCoe(ori_dir, "enemy1_down2.png")
        enemy1_down3 = GenCoe(ori_dir, "enemy1_down3.png")
        # enemy1_down4 = GenCoe(ori_dir, "enemy1_down4.png")
        # GenCoe.generate_coe(des_dir, 'enemy1.coe', ('alpha', enemy1.get_alphainfo()), ('gray', enemy1.get_grayinfo()), \
        #     ('gray', enemy1_down1.get_grayinfo()), ('gray', enemy1_down2.get_grayinfo()), \
        #         ('alpha', enemy1_down3.get_alphainfo()), ('gray', enemy1_down3.get_grayinfo()))
        GenCoe.generate_coe(des_dir, 'enemy1.coe', ('alpha', enemy1.get_alphainfo()), ('gray', enemy1.get_grayinfo()), \
            ('alpha', enemy1_down1.get_alphainfo()), ('gray', enemy1_down1.get_grayinfo()), \
                ('alpha', enemy1_down2.get_alphainfo()), ('gray', enemy1_down2.get_grayinfo()), \
                    ('alpha', enemy1_down3.get_alphainfo()), ('gray', enemy1_down3.get_grayinfo()))
        
    def gen_enemy2():
        enemy2 = GenCoe(ori_dir, "enemy2.png")
        enemy2_hit = GenCoe(ori_dir, "enemy2_hit.png")
        enemy2_down1 = GenCoe(ori_dir, "enemy2_down1.png")
        enemy2_down2 = GenCoe(ori_dir, "enemy2_down2.png")
        enemy2_down3 = GenCoe(ori_dir, "enemy2_down3.png")
        GenCoe.generate_coe(des_dir, 'enemy2.coe', \
            ('alpha', enemy2.get_alphainfo()), ('gray', enemy2.get_grayinfo()),\
                ('alpha', enemy2_hit.get_alphainfo()), ('gray', enemy2_hit.get_grayinfo()),\
                    ('alpha', enemy2_down1.get_alphainfo()), ('gray', enemy2_down1.get_grayinfo()),\
                        ('alpha', enemy2_down2.get_alphainfo()), ('gray', enemy2_down2.get_grayinfo()),\
                            ('alpha', enemy2_down3.get_alphainfo()), ('gray', enemy2_down3.get_grayinfo()))
            
    
    def gen_enemy3():
        enemy3_n1 = GenCoe(ori_dir, 'enemy3_n1.png')
        enemy3_n2 = GenCoe(ori_dir, 'enemy3_n2.png')
        enemy3_hit = GenCoe(ori_dir, 'enemy3_hit.png')
        enemy3_down1 = GenCoe(ori_dir, 'enemy3_down1.png')
        enemy3_down2 = GenCoe(ori_dir, 'enemy3_down2.png')
        enemy3_down3 = GenCoe(ori_dir, 'enemy3_down3.png')
        enemy3_down4 = GenCoe(ori_dir, 'enemy3_down4.png')
        enemy3_down5 = GenCoe(ori_dir, 'enemy3_down5.png')
        GenCoe.generate_coe(des_dir, 'enemy3.coe', \
            ('alpha', enemy3_n1.get_alphainfo()), ('gray', enemy3_n1.get_grayinfo()), \
                # ('alpha', enemy3_n2.get_alphainfo()), ('gray', enemy3_n2.get_grayinfo()), \
                    ('alpha', enemy3_hit.get_alphainfo()), ('gray', enemy3_hit.get_grayinfo()), \
                        # ('alpha', enemy3_down1.get_alphainfo()), ('gray', enemy3_down1.get_grayinfo()), \
                            # ('alpha', enemy3_down2.get_alphainfo()), ('gray', enemy3_down2.get_grayinfo()), \
                                ('alpha', enemy3_down3.get_alphainfo()), ('gray', enemy3_down3.get_grayinfo()), \
                                    # ('alpha', enemy3_down4.get_alphainfo()), ('gray', enemy3_down4.get_grayinfo()), \
                                        ('alpha', enemy3_down5.get_alphainfo()), ('gray', enemy3_down5.get_grayinfo()))
        
    def gen_startinfo():
        startinfo = GenCoe(ori_dir, 'startinfo.png', mode="mono")
        GenCoe.generate_coe(des_dir, 'startinfo.coe', ('mono', startinfo.get_monoinfo()))
    # gen_enemy1()
    
    def gen_bomb():
        bomb_supply = GenCoe(ori_dir, 'bomb_supply.png', mode='color')
        GenCoe.generate_coe(des_dir, 'bomb.coe', ('alpha', bomb_supply.get_alphainfo()),('color', bomb_supply.get_colorinfo()))
        
    def gen_bullet_supply():
        bullet_supply = GenCoe(ori_dir, 'bullet_supply.png', mode='color')
        GenCoe.generate_coe(des_dir, 'bullet_supply.coe', ('alpha', bullet_supply.get_alphainfo()), ('color', bullet_supply.get_colorinfo()))

    def gen_number():
        number_dir = "D:\\fpga\\project\\PlaneWar\\src\\img\\origin\\numbers"
        for i in range(10):
            filename = str(i) + ".png"
            number = GenCoe(number_dir, filename, mode='mono')
            GenCoe.generate_coe(des_dir, str(i) + ".coe", ('mono', number.get_monoinfo()))
            
    gen_me()