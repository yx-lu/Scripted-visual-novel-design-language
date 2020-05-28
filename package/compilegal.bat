copy %~1 C:\cygwin64\home\user\code\code.gal
@echo off
C:\cygwin64\bin\bash --login -i -c  "cd code;./f code.gal > syntax_tree.txt;exit"
copy C:\cygwin64\home\user\code\syntax_tree.txt .\syntax_tree.txt
C:\Users\user\Desktop\DPPL\proj\package\intermediate_code_generator
