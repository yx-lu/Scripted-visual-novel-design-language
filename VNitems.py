import pygame
import os
from pygame.locals import *
from sys import exit
import platform

sign_set = u'''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-=[]:;{}+_,.?!()@<>""''/\\'''

dpi = (800, 600)

avatar_pos=200,540

textbox_size = (800, 160)
textbox_alpha = 180
textbox_rgb = (0,0,0)
line_num = 35

font_path = 'hksn.ttf'
font_size = 24
font_rgb = (255,255,255)
off_x = 35
off_y = 10

button_size = (200,40)
setting_button_size = (50,30)
button_rgb = (0,0,255)
button_alpha = 180

if platform.system() == 'Windows':
    win = 1
else:
    win = 0

class Button(object):
    def __init__(self, pos, size, bg_rgb=button_rgb, b_alpha=button_alpha, label='', f_path=font_path, \
                 f_size=font_size, f_rgb=font_rgb, image=None):
        self.pos = pos
        self.size = size
        self.surface = pygame.Surface(size)
        self.label = label
        self.f_rgb = f_rgb
        self.alpha = b_alpha

        self.image = self.load_image(image, bg_rgb)
        self.font = self.load_font(f_path, f_size)
        self.combination()

    def load_image(self, image, bgcolor):
        ## Use a image
        if image != None:
            try:
                image_convert = pygame.image.load(image).convert_alpha()
            except pygame.error:
                print('Could not load the image')
                raise SystemExit
            image_convert = pygame.transform.scale(image_convert, self.size)
            return image_convert
        ## Use the pure color
        else:
            try:
                self.surface.fill(bgcolor)
                self.surface.set_alpha(self.alpha)
            except pygame.error:
                print('Cannot use the color')
                raise SystemExit
            return self.surface

    def load_font(self, f_path, f_size):
        try:
            font = pygame.font.Font(f_path, f_size)
        except pygame.error:
            print('Could not load the font')
            raise SystemExit
        return font

    def combination(self):
        button = self.image
        label_surface = self.font.render(self.label, True, self.f_rgb)
        x_pos = (button.get_width() - label_surface.get_width()) / 2
        y_pos = (button.get_height() - label_surface.get_height()) / 2
        button.blit(label_surface, (x_pos, y_pos))
        self.surface.blit(button, (0, 0))

    ## draw this button on the screen
    def render(self, surface):
        x, y = self.pos
        w, h = self.surface.get_size()
        x -= w/2
        y -= h/2
        surface.blit(self.surface, (x, y))

    ## check if a point is in this button
    def is_over(self, point):
        x, y = self.pos
        w, h = self.surface.get_size()
        x -= w/2
        y -= h/2
        rect = pygame.Rect((x, y), self.size)
        return rect.collidepoint(point)

    def get_pos(self):
        return self.pos

    def get_surface(self):
        return self.surface

    def get_rect(self):
        return self.surface.get_rect()

class VNitem(object):
    def __init__(self, surface, s_size, t_pos, t_size=textbox_size, t_rgb=textbox_rgb, t_alpha=textbox_alpha, \
                 f_path=font_path, f_size=font_size, f_rgb=font_rgb, b_size=button_size, b_alpha=button_alpha, \
                 b_rgb=button_rgb):
        self.dpi = s_size
        self.t_size = t_size
        self.BGM = ''
        self.bg_name = ''
        self.BGM_name = ''
        self.buttons = {}
        self.images = {}
        self.bg_color = t_rgb
        self.fg_color = f_rgb
        self.f_path = f_path
        self.f_size = f_size
        self.t_alpha = t_alpha
        self.t_pos = t_pos

        self.b_size = b_size
        self.b_alpha = b_alpha
        self.b_rgb = b_rgb

        self.surface = surface
        self.font = self.init_font()
        self.textbox, self.textbox_rect = self.init_textbox()

    def init_textbox(self):
        size = self.t_size
        textbox = pygame.Surface(size)
        textbox.fill(self.bg_color)
        alpha = self.t_alpha
        textbox.set_alpha(alpha)
        return textbox , textbox.get_rect()

    def init_font(self):
        path = self.f_path
        size = self.f_size
        try:
            font = pygame.font.Font(path, size)
        except pygame.error:
            print('Could not load font:', path)
            raise SystemExit
        return font

    def update(self):
        self.update_image(self.bg_name)

        if self.images:
            for key in self.images:
                try:
                    name = key
                    pos = self.images[key]['pos']
                    size = self.images[key]['size']
                except KeyError:
                    print('The images argvs are not enough')
                    raise SystemExit
                else:
                    image = self.update_image(name,pos,size,-1)

        self.buttons = {}

    def delete_image(self, name):
        if name in self.images:
            self.images.pop(name)

    def update_image(self, name, pos=(0,0), size=None, colorkey=None):
        if not size:
            self.bg_name = name
            temp_pos = (0,0)

        try:
            image = pygame.image.load(name)
        except pygame.error:
            print('Could not load image:', name)
            raise SystemExit
        image = image.convert()

        if size:
            x, y = pos
            w, h = size
            temp_pos = (x - w/2, y - h/2)

            image = pygame.transform.scale(image,size)
            if name not in self.images:
                temp_dict1 = {}
                temp_dict2 = {}
                temp_dict2['pos'] = pos
                temp_dict2['size'] = size
                temp_dict1[name] = temp_dict2
                self.images.update(temp_dict1)
        else:
            image = pygame.transform.scale(image,self.dpi)

        if colorkey is not None:
            if colorkey is -1:
                colorkey = image.get_at((0, 0))
            image.set_colorkey(colorkey, RLEACCEL)

        self.surface.blit(image, temp_pos)

    def delete_button(self, label):
        if label in self.buttons:
            self.buttons.pop(label)

    def update_buttons(self, dest, pos, label):
        temp_dict = {}
        temp_dict[label] = (dest, Button(pos, self.b_size, self.b_rgb, self.b_alpha, label, self.f_path, \
                                         self.f_size, self.fg_color))
        self.buttons.update(temp_dict)
        temp_dict[label][1].render(self.surface)

    def update_BGM(self, name):
        class NoneSound:
            def play(self): pass
        if not pygame.mixer:
            return NoneSound()
        if self.BGM_name == name:
            return
        try:
            pygame.mixer.music.load(name)
        except pygame.error:
            print('Could not load music:', name)
            raise SystemExit
        self.BGM_name = name
        self.play()

    def play(self):
        pygame.mixer.music.play(1,0.0)

    def stop(self):
        pygame.mixer.music.stop()

    def text_to_list(self, text):
        width = 0
        text_list = []
        text_str = ''
        for i in text:
            if i in sign_set or i.isdigit() or i.isspace():
                width += 1
            else:
                width += 2
            text_str += i
            if width >= line_num * 2 - 1:
                text_list.append(text_str)
                text_str = ''
                width = 0
        text_list.append(text_str)
        return text_list

    def update_text(self, name, text):
        self.textbox.fill(self.bg_color)
        text_lines = self.text_to_list(text)
        if name != '':
            name += ' :'
        text_lines.insert(0,name)
        v_size = 30

        for k in range(len(text_lines)):
            temp_line = text_lines[k]
            font_surface = self.font.render(temp_line, True, self.fg_color, self.bg_color)
            pos_x = off_x
            pos_y = off_y + k * v_size
            self.textbox.blit(font_surface, (pos_x, pos_y))

        #x, y = pos
        #w, h = self.t_size
        #self.t_pos = (x - w/2, y - h/2)
        self.surface.blit(self.textbox, self.t_pos)

    def get_buttons(self):
        return self.buttons

    def get_screen(self):
        return self.surface

    def get_BGM(self):
        return self.BGM_name

    def get_background(self):
        return self.bg_name

    def get_images(self):
        return self.images