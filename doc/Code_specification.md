# Code specification

代码应该由两部分组成, 第一部分是一个header, 第二部分是你的源代码.

header通过一对```来包括, 最后加上一个分号;来表示header的结束.

## header

header由一系列的key-value对组成, 有一些缺省的默认值存在, 下面的文档将标出它们并解释这些参数的功能.

你也可以自己定义一些参数.

```
​```
dpi=800,600//(横向,纵向)分辨率
avatar_pos=400,300//头像左上角(横向,纵向)位置
image_multiple=20//图片大小倍数*100, 必须是整数
textbox_pos=0,440//文本框左上位置
textbox_transparency=180//文本框透明度, 值在[0,255]
textbox_rgb=0,0,0//文本框颜色
font_size=20//字体大小
button_size=200,40//按钮(长度,宽度)
button_pos=400,300//(如果只有一个按钮时)按钮左上角(横向,纵向)位置
button_dist=60//按钮左上角之间距离
button_transparency=180//按钮透明度
button_rgb=0,0,0//按钮颜色

//你还可以定义自定义的参数, 格式是key=value, 下面是一些推荐的参数命名
left=
right=
top=
down=
bottom=
topleft=
bottomleft=
topright=
bottomright=
medium=
custom1=
custom2=
custom3=
custom4=
//etc
​```
;
```

## source code

你的源代码需要在开始定义变量(及其初始值), 所有变量均为全局变量.

在剩下的部分, 你将定义一个具有类型frame的表达式, 命名为main, 这个表达式最终会被运行.

type system部分会详细告诉你可选的表达式构造方式.

###关键字

以下是这个语言的关键字, 你不能将它们看作变量名和表达式别名

bool int string image music action menu frame

var if then else silent halt nop show hide play stop say select character scene

left right top bottom topleft bottomleft topright bottomright medium

custom1 custom2 custom3 custom4

以下是变量(常量)名称限定: $(a..z,A..Z,\_)(0..9,a..z,A..Z,\_)^*$

## type system

在每个类型下会给出对应能用的函数和运算符, 注释中的内容是该函数/运算符在中间代码中的对应代码.

### 运算符优先级



```
()
!
\* /
\+ -
&
|
< > <= >= 
!= ==
:=
;
->
,
```

同优先级从左往右计算.

### atomic types

这里的给出的简单类型不是图灵完备的, 你甚至不能写一个循环(递归), 只用于简单的游戏内运算.

程序员定义的原子类型变量本质上是一个ref类型, 用一个语法糖处理(subtyping), 让它看上去像c/c++里面的变量.

特别的, 所有原子类型变量都必须被定义在程序开始而且成为全局变量, 就像早期的c语言一样, 不排除之后会增加在程序中间能定义原子类型变量的语法糖(不过还是看做在程序开始时定义, 因此命名不能重复).

#### bool

一个1位的布尔变量, 值为true或者false. 通过var定义的是对应的ref类型.

```
true : bool
false : bool
! bool : bool//not()
bool & bool : bool//and(,)
bool | bool : bool//or(,)
bool ^ bool : bool//xor(,)

--SAMPLE--

var a=true;//definition of ref bool
a:=false//change the value referenced by a ref bool, which is of type "action"
b=true;//definition of bool

--SUBTYPING--

ref bool <: bool
```

#### int

一个64位的有符号整数, 采用c/c++的溢出方式.

```
1 : int
2147483647 : int
0x80 : int
int+int : int//add(,)
int-int : int//sub(,)
int*int : int//mul(,)
int/int : int//div(,)
int<int : bool//less(,)
int>int : bool//greater(,)
int<=int : bool//leq(,)
int>=int : bool//geq(,)
int==int : bool//eq(,)
int!=int : bool//neq(,)

--SAMPLE--

var a=1;//definition of ref int
var b=0xAA;
b:=a+1;//change the value referenced by a ref int, which is of type "action"
var c=11111111111111111111111111111111;//causes a compile error as it is too large
d=233;//definition of int

--SUBTYPING--

ref int <: int
```

#### string

一个字符串, 用一对引号包围, 字符串内引号使用右划线转义.

$\text{\n}$表示换行

$\text{\\\\}$表示右划线

$\text{\"}$表示引号

```
"abc" : string
string+string : string//cancat(,)
string==string : bool//same(,)
string!=string : bool//diff(,)

--SAMPLE--

var a="aa";//definition of ref string
b="bb";//definition of string

--SUBTYPING--

ref string <: string
```

###simple types

这些类型指向一个地址, 代表着一个外部的内容.

####image

一张图片(的地址), 可以是jpg, png, bmp后缀.

注意, 这张图片是否真的存在只会在运行时被发现, 而不会在编译中确认.

```
image(string) : image

--SAMPLE--

a=image("a.bmp");

--SUBTYPING--

string <: image//这个subtyping是危险的, 可以由一个编译命令"safe"来禁止
```

#### music

一段音乐, 可以是mp3后缀.

注意, 这段音乐是否真的存在只会在运行时被发现, 而不会在编译中确认.

```
music(string) : music
silent : music

--SAMPLE--

a=music("a.mp3");
b=silent;

--SUBTYPING--

string <: music//这个subtyping是危险的, 可以由一个编译命令"safe"来禁止
```

### hybrid types

这些类型将帮助你构建这个视频小说的进程.

#### action

一个, 或者若干个连续的动作.

注意, 程序员不会显式地使用这个类型.

```
halt : action//使程序以一个异常终止
nop : action//什么都不做
ref bool:=bool : action//set(,)
ref int:=int : action//mov(,)
ref string:=string : action//assign(,)
show(image) : action
show(image,parameter) : action
hide(image) : action
play(music) : action
say(character,string) : action
say(character,string,music) : action//可选的music表示需要更换的声音
menu(option) : action
menu(option,option) : action
menu(option,option,option) : action
menu(option,option,option,option) : action
menu(option,option,option,option,option) : action
menu(option,option,option,option,option,option) : action
action\action : action//连接两个动作//cont(,)
if bool then {action} else {action} : action//if(,,)

--SAMPLE--

a:=a+1\b:=b*2
```

#### character

表示一个角色, 构造函数中的image表示其头像贴图.

```
character(string,image) : character
nobody : character

--SAMPLE--

amy=character("Amy John","Amy.jpg");

--SUBTYPING--

character <: image
```

#### scene

一个场景, 构造函数中的music表示该场景的背景音乐, action表示这个场景的动作.

```
 scene(image,music,action) : scene
 blank : scene
 
 
 --SAMPLE--
 
start=scene("sky.jpg",silent,
	show("fuck.jpg")\
	play("laugh.mp3")\
	a=a+1\
	if (a>5) then show("kill.jpg") else nop
);
```

####option

通过menu(option,...)形成一个action供给玩家在若干个选项中选择.

当选项超过6个时会编译错误.

```
string->action : option//arrow(,)

--SAMPLE--

a=menu(
	"Fuck you!"->score:=score-1,
	"I love you!"->score:=score+1
);
```

#### frame

游戏的框架, 由场景和分支连接而成. 名为"main"的frame会最终被执行.

```
frame\frame : frame//contframe(,)
if bool then {frame} else {frame} : frame//ifframe(,,)

--SAMPLE--

main=start\scene1\if (score>5) then goodend else badend;

--SUBTYPING--

scene <: frame

```

 