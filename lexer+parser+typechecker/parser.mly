/*  
 *  Yacc grammar for the parser.  The files parser.mli and parser.ml
 *  are generated automatically from parser.mly.
 */

%{
open Support.Error
open Support.Pervasive
open Syntax
%}

/* ---------------------------------------------------------------------- */
/* Preliminaries */

/* We first list all the tokens mentioned in the parsing rules
   below.  The names of the tokens are common to the parser and the
   generated lexical analyzer.  Each token is annotated with the type
   of data that it carries; normally, this is just file information
   (which is used by the parser to annotate the abstract syntax trees
   that it constructs), but sometimes -- in the case of identifiers and
   constant values -- more information is provided.
 */

/* Keyword tokens */
%token <Support.Error.info> IF
%token <Support.Error.info> THEN
%token <Support.Error.info> ELSE
%token <Support.Error.info> TRUE
%token <Support.Error.info> FALSE
%token <Support.Error.info> VAR
%token <Support.Error.info> IMAGE
%token <Support.Error.info> MUSIC
%token <Support.Error.info> SILENT
%token <Support.Error.info> HALT
%token <Support.Error.info> NOP
%token <Support.Error.info> SHOW
%token <Support.Error.info> HIDE
%token <Support.Error.info> PLAY
%token <Support.Error.info> SAY
%token <Support.Error.info> MENU
%token <Support.Error.info> CHARACTER
%token <Support.Error.info> NOBODY
%token <Support.Error.info> SCENE
%token <Support.Error.info> BLANK
%token <Support.Error.info> MAIN

/* Identifier and constant value tokens */
%token <string Support.Error.withinfo> UCID  /* uppercase-initial */
%token <string Support.Error.withinfo> LCID  /* lowercase/symbolic-initial */
%token <int Support.Error.withinfo> INTV
%token <string Support.Error.withinfo> STRINGV
%token <string Support.Error.withinfo> HEADER
%token <string Support.Error.withinfo> PARAM

/* Symbolic tokens */
%token <Support.Error.info> AMPERSAND
%token <Support.Error.info> CARET
%token <Support.Error.info> LEQ
%token <Support.Error.info> GEQ
%token <Support.Error.info> NEQ
%token <Support.Error.info> ADD
%token <Support.Error.info> SUB
%token <Support.Error.info> BACKSLASH
%token <Support.Error.info> APOSTROPHE
%token <Support.Error.info> DQUOTE
%token <Support.Error.info> ARROW
%token <Support.Error.info> BANG
%token <Support.Error.info> BARGT
%token <Support.Error.info> BARRCURLY
%token <Support.Error.info> BARRSQUARE
%token <Support.Error.info> COLON
%token <Support.Error.info> COLONCOLON
%token <Support.Error.info> COLONEQ
%token <Support.Error.info> COLONHASH
%token <Support.Error.info> COMMA
%token <Support.Error.info> DARROW
%token <Support.Error.info> DDARROW
%token <Support.Error.info> DOT
%token <Support.Error.info> EOF
%token <Support.Error.info> EQ
%token <Support.Error.info> EQEQ
%token <Support.Error.info> EXISTS
%token <Support.Error.info> GT
%token <Support.Error.info> HASH
%token <Support.Error.info> LCURLY
%token <Support.Error.info> LCURLYBAR
%token <Support.Error.info> LEFTARROW
%token <Support.Error.info> LPAREN
%token <Support.Error.info> LSQUARE
%token <Support.Error.info> LSQUAREBAR
%token <Support.Error.info> LT
%token <Support.Error.info> RCURLY
%token <Support.Error.info> RPAREN
%token <Support.Error.info> RSQUARE
%token <Support.Error.info> SEMI
%token <Support.Error.info> SLASH
%token <Support.Error.info> STAR
%token <Support.Error.info> TRIANGLE
%token <Support.Error.info> USCORE
%token <Support.Error.info> VBAR

%left BACKSLASH
%left VBAR
%left CARET
%left AMPERSAND
%left EQEQ NEQ
%left LT GT LEQ GEQ
%left ADD SUB
%left STAR SLASH
%right BANG

/* ---------------------------------------------------------------------- */
/* The starting production of the generated parser is the syntactic class
   toplevel.  The type that is returned when a toplevel is recognized is
     Syntax.context -> (Syntax.command list * Syntax.context) 
   that is, the parser returns to the user program a function that,
   when given a naming context, returns a fully parsed list of
   Syntax.commands and the new naming context that results when
   all the names bound in these commands are defined.

   All of the syntactic productions in the parser follow the same pattern:
   they take a context as argument and return a fully parsed abstract
   syntax tree (and, if they involve any constructs that bind variables
   in some following phrase, a new context).
   
*/

%start toplevel
%type < Syntax.context -> (Syntax.command list * Syntax.context) > toplevel
%%

/* ---------------------------------------------------------------------- */
/* Main body of the parser definition */

/* The top level of a file is a sequence of commands, each terminated
   by a semicolon. */
toplevel :
    EOF
      { fun ctx -> [],ctx }
  | Command SEMI toplevel
      { fun ctx ->
          let cmd,ctx = $1 ctx in
          let cmds,ctx = $3 ctx in
          cmd::cmds,ctx }

/* A top-level command */
Command :
    HEADER
      { fun ctx -> (Header($1.i,$1.v),ctx) }
  | VAR LCID EQ Basic3
      { fun ctx -> (Assign($2.i,$2.v,$4 ctx),addname ctx $2.v) }
  | LCID Binder
      { fun ctx -> (Bind($1.i,$1.v,$2 ctx), addname ctx $1.v) }
  | MAIN EQ Frame
      { fun ctx -> (let t = $3 ctx in Eval(tmInfo t,t), ctx) }

/* Basic boolean, int, string expressions */
Basic3 :
    INTV
      { fun ctx -> TmLocI(-1,TmInt($1.i,$1.v)) }
  | STRINGV
      { fun ctx -> TmLocS(-1,TmString($1.i,$1.v)) }
  | TRUE
      { fun ctx -> TmLocB(-1,TmTrue($1)) }
  | FALSE
      { fun ctx -> TmLocB(-1,TmFalse($1)) }

/* Right-hand sides of top-level bindings */
Binder :
    EQ Term
      { fun ctx -> TmAbbBind($2 ctx, None) }

Term :
    Frame
      { $1 }
  | Image
      { $1 }
  | Character
      { $1 }
  | Music
      { $1 }
  | Actions
      { $1 }
  | Expr
      { $1 }
      
Frame :
    Scene
      { fun ctx -> $1 ctx }
  | IF Expr THEN LCURLY Frame RCURLY ELSE LCURLY Frame RCURLY
      { fun ctx -> TmIf($1,$2 ctx,$5 ctx,$9 ctx) }
  | Frame BACKSLASH Frame
      { fun ctx -> let t1 = $1 ctx in TmContframe(tmInfo t1,t1,$3 ctx) }

Scene :
    Variable
      { $1 }
  | BLANK
      { fun ctx -> TmBlank($1) }
  | SCENE LPAREN Image COMMA Music COMMA Actions RPAREN
      { fun ctx -> TmScene($1,$3 ctx,$5 ctx,$7 ctx) }
      
Image :
    Variable
      { $1 }
  | Expr
      { $1 }
  | Character
      { $1 }
  | IMAGE LPAREN Expr RPAREN
      { fun ctx -> TmImage($1,$3 ctx) }
      
Character :
    Variable
      { $1 }
  | NOBODY
      { fun ctx -> TmNobody($1) }
  | CHARACTER LPAREN Expr COMMA Image RPAREN
      { fun ctx -> TmCharacter($1,$3 ctx,$5 ctx) }
   
Music :
    Variable
      { $1 }
  | Expr
      { $1 }
  | SILENT
      { fun ctx -> TmSilent($1) }
  | MUSIC LPAREN Expr RPAREN
      { fun ctx -> TmMusic($1,$3 ctx) }

Actions :
    Action
      { $1 }
  | IF Expr THEN LCURLY Actions RCURLY ELSE LCURLY Actions RCURLY
      { fun ctx -> TmIf($1,$2 ctx,$5 ctx,$9 ctx) }
  | Actions BACKSLASH Actions
      { fun ctx -> let t1 = $1 ctx in TmCont(tmInfo t1,t1,$3 ctx) }
      
Action:
    Variable
      { $1 }
  | HALT
      { fun ctx -> TmHalt($1) }
  | NOP
      { fun ctx -> TmNop($1) }
  | Assignment
      { $1 }
  | SHOW LPAREN Image RPAREN
      { fun ctx -> TmShow($1,$3 ctx,TmNull(dummyinfo)) }
  | SHOW LPAREN Image COMMA Parameter RPAREN
      { fun ctx -> TmShow($1,$3 ctx,$5 ctx) }
  | HIDE LPAREN Image RPAREN
      { fun ctx -> TmHide($1,$3 ctx) }
  | PLAY LPAREN Music RPAREN
      { fun ctx -> TmPlay($1,$3 ctx) }
  | SAY LPAREN Character COMMA Expr RPAREN
      { fun ctx -> TmSay($1,$3 ctx,$5 ctx,TmNull(dummyinfo)) }
  | SAY LPAREN Character COMMA Expr COMMA Music RPAREN
      { fun ctx -> TmSay($1,$3 ctx,$5 ctx,$7 ctx) }
  | MENU LPAREN Option RPAREN
      { fun ctx -> TmMenu($1,$3 ctx,TmNull(dummyinfo),TmNull(dummyinfo),TmNull(dummyinfo),TmNull(dummyinfo),TmNull(dummyinfo)) }
  | MENU LPAREN Option COMMA Option RPAREN
      { fun ctx -> TmMenu($1,$3 ctx,$5 ctx,TmNull(dummyinfo),TmNull(dummyinfo),TmNull(dummyinfo),TmNull(dummyinfo)) }
  | MENU LPAREN Option COMMA Option COMMA Option RPAREN
      { fun ctx -> TmMenu($1,$3 ctx,$5 ctx,$7 ctx,TmNull(dummyinfo),TmNull(dummyinfo),TmNull(dummyinfo)) }
  | MENU LPAREN Option COMMA Option COMMA Option COMMA Option RPAREN
      { fun ctx -> TmMenu($1,$3 ctx,$5 ctx,$7 ctx,$9 ctx,TmNull(dummyinfo),TmNull(dummyinfo)) }
  | MENU LPAREN Option COMMA Option COMMA Option COMMA Option COMMA Option RPAREN
      { fun ctx -> TmMenu($1,$3 ctx,$5 ctx,$7 ctx,$9 ctx,$11 ctx,TmNull(dummyinfo)) }
  | MENU LPAREN Option COMMA Option COMMA Option COMMA Option COMMA Option COMMA Option RPAREN
      { fun ctx -> TmMenu($1,$3 ctx,$5 ctx,$7 ctx,$9 ctx,$11 ctx,$13 ctx) }
  
Assignment :
    Variable COLONEQ Expr
      { fun ctx -> let t1 = $1 ctx in TmAssign(tmInfo t1,t1,$3 ctx) }

Variable :
    LCID
      { fun ctx -> TmVar($1.i, name2index $1.i ctx $1.v, ctxlength ctx) }

Parameter :
    PARAM
      { fun ctx -> TmParam($1.i,$1.v) }
      
Option :
    Expr ARROW Actions
      { fun ctx -> let t1 = $1 ctx in TmOption(tmInfo t1,t1,$3 ctx) }

Expr :
    Atom
      { $1 }
  | LPAREN Expr RPAREN
      { $2 }
  | BANG Expr 
      { fun ctx -> TmNot($1,$2 ctx) }
  | Expr ADD Expr
      { fun ctx -> let t1 = $1 ctx in TmAdd(tmInfo t1,t1,$3 ctx) }
  | Expr SUB Expr
      { fun ctx -> let t1 = $1 ctx in TmSub(tmInfo t1,t1,$3 ctx) }
  | Expr AMPERSAND Expr
      { fun ctx -> let t1 = $1 ctx in TmAnd(tmInfo t1,t1,$3 ctx) }
  | Expr CARET Expr
      { fun ctx -> let t1 = $1 ctx in TmXor(tmInfo t1,t1,$3 ctx) }
  | Expr VBAR Expr
      { fun ctx -> let t1 = $1 ctx in TmOr(tmInfo t1,t1,$3 ctx) }
  | Expr STAR Expr
      { fun ctx -> let t1 = $1 ctx in TmMul(tmInfo t1,t1,$3 ctx) }
  | Expr SLASH Expr
      { fun ctx -> let t1 = $1 ctx in TmDiv(tmInfo t1,t1,$3 ctx) }
  | Expr GT Expr
      { fun ctx -> let t1 = $1 ctx in TmGT(tmInfo t1,t1,$3 ctx) }
  | Expr LT Expr
      { fun ctx -> let t1 = $1 ctx in TmLT(tmInfo t1,t1,$3 ctx) }
  | Expr GEQ Expr
      { fun ctx -> let t1 = $1 ctx in TmGEQ(tmInfo t1,t1,$3 ctx) }
  | Expr LEQ Expr
      { fun ctx -> let t1 = $1 ctx in TmLEQ(tmInfo t1,t1,$3 ctx) }
  | Expr EQEQ Expr
      { fun ctx -> let t1 = $1 ctx in TmEQ(tmInfo t1,t1,$3 ctx) }
  | Expr NEQ Expr
      { fun ctx -> let t1 = $1 ctx in TmNEQ(tmInfo t1,t1,$3 ctx) } 
      
Atom :
    Variable
      { $1 }
  | INTV
      { fun ctx -> TmInt($1.i,$1.v) }
  | STRINGV
      { fun ctx -> TmString($1.i,$1.v) }
  | TRUE
      { fun ctx -> TmTrue($1) }
  | FALSE
      { fun ctx -> TmFalse($1) }

