# -*- coding: utf-8 -*-
import pygame
import os
from pygame.locals import *
from PIL import Image
from sys import exit
import VNitems
import numpy as np

intermediate_home = os.path.abspath("./intermediate_code.txt")

    lines = f.readlines()

params = lines[1].split()
dpi = (int(params[0]), int(params[1]))
image_multiple = float(lines[2])/100
params = lines[3].split()
textbox_pos = (int(params[0]), int(params[1]))
textbox_size = (800 - int(params[0]), 600 - int(params[1]))
textbox_alpha = int(params[2])
textbox_rgb = (int(params[3]), int(params[4]), int(params[5]))
params = lines[4].split()
font_size = int(params[0])
#font_rgb = (int(params[1]), int(params[2]), int(params[3]))
font_rgb = (255, 255, 255)
#font_path = params[4]
font_path = "hksn.ttf"
params = lines[5].split()
button_size = (int(params[0]), int(params[1]))
button_alpha = int(params[2])
button_rgb = (int(params[3]), int(params[4]), int(params[5]))

var_s = {}
var_b = {}
var_i = {}
var_l = {}

last_s = {}
last_b = {}
last_i = {}
last_index = 7

pygame.init()
screen = pygame.display.set_mode(dpi,0,32)
#pygame.display.set_caption("敖睿成传说")
clock = pygame.time.Clock()

item = VNitems.VNitem(screen, dpi, textbox_pos, textbox_size, textbox_rgb, textbox_alpha, font_path, font_size, \
                      font_rgb, button_size, button_alpha, button_rgb)
setting_buttons = item.get_settings()

length = len(lines)
index = 7

for i in range(length):
    params = lines[i].split()
    if params[0] == 'label':
        var_l[int(params[1])] = i+1

while True:
    for event in pygame.event.get():
        if event.type == QUIT:
            exit()

    params = lines[index].split()
    if params[0] == 'show':
        if params[1] == 'image':
            temp = int(params[2])
            if temp == 0:
                pass
            else:
                name = var_s[temp]

                if len(params) == 3:
                    item.update_image(name)
                elif len(params) == 5:
                    pos = (int(params[3]), int(params[4]))

                    try:
                        temp_image = Image.open(name)
                    except FileNotFoundError:
                        print('Could not load image:', name)
                        raise SystemExit
                    size = (int(image_multiple * temp_image.size[0]), int(image_multiple * temp_image.size[1]))

                    item.update_image(name, pos, size, -1)
                else:
                    print('illegal parameter numbers in line %d' % (index + 1))
                    raise SystemExit
        elif params[1] == 'textbox':
            if len(params) == 4:
                temp = int(params[2])
                if temp == 0:
                    name = ''
                else:
                    name = var_s[temp]
                text = var_s[int(params[3])]
                item.update_text(name,text)
            else:
                print('illegal parameter numbers in line %d' % (index+1))
                raise SystemExit
        elif params[1] == 'button':
            if len(params) == 6:
                label = var_s[int(params[2])]
                dest = var_l[int(params[5])]
                pos = (int(params[3]), int(params[4]))
                item.update_buttons(dest,pos,label)
            else:
                print('illegal parameter numbers in line %d' % (index+1))
                raise SystemExit
        elif params[1] == 'music':
            if len(params) == 3:
                temp = int(params[2])

                if temp == 0:
                    item.stop()
                else:
                    name = var_s[int(params[2])]
                    item.update_BGM(name)
            else:
                print('illegal parameter numbers in line %d' % (index+1))
                raise SystemExit
        else:
            print('illegal command in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'hide':
        if len(params) == 2:
            temp = int(params[1])
            if temp:
                name = var_s[int(params[1])]
                item.delete_image(name)
                item.update()
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'pause':
        if len(params) == 1:
            temp_b = True
            if_load = False
            no_button = (item.get_buttons() == {})
            while temp_b:
                for event in pygame.event.get():
                    if event.type == QUIT:
                        exit()
                    if event.type == MOUSEBUTTONDOWN:
                        click_point = event.dict['pos']
                        if setting_buttons['save'].is_over(click_point):
                            np.save('./save/save0.npy', last_index)
                            np.save('./save/save1.npy', last_s)
                            np.save('./save/save2.npy', last_b)
                            np.save('./save/save3.npy', last_i)
                            np.save('./save/save4.npy', item.get_background())
                            np.save('./save/save5.npy', item.get_BGM())
                        elif setting_buttons['load'].is_over(click_point):
                            index = np.load('./save/save0.npy')
                            var_s = np.load('./save/save1.npy', allow_pickle=True).item()
                            var_b = np.load('./save/save2.npy', allow_pickle=True).item()
                            var_i = np.load('./save/save3.npy', allow_pickle=True).item()
                            temp_bg = np.load('./save/save4.npy')
                            temp_bgm = np.load('./save/save5.npy')
                            item.update_image(str(temp_bg))
                            item.update_BGM(str(temp_bgm))
                            item.delete_all_images()
                            item.update()
                            temp_b = False
                            last_index = index
                            if_load = True
                        elif no_button:
                            item.update()
                            temp_b = False
                            last_index = index + 1
                        else:
                            # click_point = event.dict['pos']
                            dict_buttons = item.get_buttons()
                            for key in dict_buttons.keys():
                                temp_button = dict_buttons[key][1]
                                if temp_button.is_over(click_point):
                                    index = dict_buttons[key][0]
                                    item.update()
                                    temp_b = False
                                    last_index = index
                                    break
            last_s = var_s
            last_b = var_b
            last_i = var_i
            last_l = var_l
            if (not no_button) or if_load:
                continue
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'and':
        if len(params) == 4:
            var_b[int(params[1])] = var_b[int(params[2])] and var_b[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'or':
        if len(params) == 4:
            var_b[int(params[1])] = var_b[int(params[2])] or var_b[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'not':
        if len(params) == 3:
            var_b[int(params[1])] = not var_b[int(params[2])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'xor':
        if len(params) == 4:
            var_b[int(params[1])] = var_b[int(params[2])] ^ var_b[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'set':
        if len(params) == 3:
            temp = int(params[2])
            temp_index = int(params[1])
            if temp == 1:
                var_b[temp_index] = True
            elif temp == 0:
                var_b[temp_index] = False
            else:
                print('illegal command in line %d' % (index+1))
                raise SystemExit
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'less':
        if len(params) == 4:
            var_b[int(params[1])] = var_i[int(params[2])] < var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'greater':
        if len(params) == 4:
            var_b[int(params[1])] = var_i[int(params[2])] > var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'leq':
        if len(params) == 4:
            var_b[int(params[1])] = var_i[int(params[2])] <= var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'geq':
        if len(params) == 4:
            var_b[int(params[1])] = var_i[int(params[2])] >= var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'eq':
        if len(params) == 4:
            var_b[int(params[1])] = var_i[int(params[2])] == var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'neq':
        if len(params) == 4:
            var_b[int(params[1])] = var_i[int(params[2])] != var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'mov':
        if len(params) == 3:
            var_i[int(params[1])] = int(params[2])
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'add':
        if len(params) == 4:
            var_i[int(params[1])] = var_i[int(params[2])] + var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'sub':
        if len(params) == 4:
            var_i[int(params[1])] = var_i[int(params[2])] - var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'mul':
        if len(params) == 4:
            var_i[int(params[1])] = var_i[int(params[2])] * var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'div':
        if len(params) == 4:
            var_i[int(params[1])] = var_i[int(params[2])] / var_i[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'concat':
        if len(params) == 4:
            var_s[int(params[1])] = var_s[int(params[2])] + var_s[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'same':
        if len(params) == 4:
            var_b[int(params[1])] = var_s[int(params[2])] == var_s[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'diff':
        if len(params) == 4:
            var_b[int(params[1])] = var_s[int(params[2])] != var_s[int(params[3])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'assign':
        temp_start = lines[index].find('"') + 1
        temp_end = lines[index].find('"', temp_start)
        while(lines[index][temp_end-1] == "\\"):
            temp_end = lines[index].find('"', temp_end+1)
        var_s[int(params[1])] = lines[index][temp_start:temp_end]
    elif params[0] == 'cpi':
        if len(params) == 3:
            var_i[int(params[1])] = var_i[int(params[2])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'cpb':
        if len(params) == 3:
            var_b[int(params[1])] = var_b[int(params[2])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'cps':
        if len(params) == 3:
            var_s[int(params[1])] = var_s[int(params[2])]
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'label':
        if len(params) == 2:
            pass
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'jmp':
        if len(params) == 2:
            index = var_l[int(params[1])]
            continue
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'jne':
        if len(params) == 3:
            if var_b[int(params[1])]:
                index = var_l[int(params[2])]
                continue
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'halt':
        if len(params) == 1:
            print('halt in line %d' % index)
            exit()
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit
    elif params[0] == 'nop':
        if len(params) == 1:
            pass
        else:
            print('illegal parameter numbers in line %d' % (index+1))
            raise SystemExit

    if index != (length - 1):
        index = index + 1

    #clock.tick(300)

    pygame.display.update()