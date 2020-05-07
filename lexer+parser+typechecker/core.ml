open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   SUBTYPING  ------------------------ *)
    
let rec tyeqv ctx tyS tyT = 
  match (tyS,tyT) with
    (TyInt, TyInt) -> true
  | (TyBool, TyBool) -> true
  | (TyString, TyString) -> true
  | (TyImage, TyImage) -> true
  | (TyMusic, TyMusic) -> true
  | (TyParam, TyParam) -> true
  | (TyAction, TyAction) -> true
  | (TyCharacter, TyCharacter) -> true
  | (TyScene, TyScene) -> true
  | (TyOption, TyOption) -> true
  | (TyFrame, TyFrame) -> true
  | _ -> false
  
let rec subtype ctx tyS tyT =
  tyeqv ctx tyS tyT ||
  match (tyS,tyT) with
    (TyString, TyImage) -> true
  | (TyString, TyMusic) -> true
  | (TyCharacter, TyImage) -> true
  | (TyScene, TyFrame) -> true
  | (TyBot, TyOption) -> true
  | (TyBot, TyMusic) -> true
  | (TyBot, TyParam) -> true
  | _ -> false

(* ------------------------   TYPING  ------------------------ *)

let rec typeof ctx t =
  match t with
    TmVar(fi,i,_) ->
      (let bind = getbinding fi ctx i in match bind with
        TmAbbBind(_,Some(ty)) -> ty
      | TmLocB(_,_) -> TyBool
      | TmLocI(_,_) -> TyInt
      | TmLocS(_,_) -> TyString
      | _ -> error fi "Unexpected error 4")     
  | TmTrue(_)
  | TmFalse(_) ->
      TyBool
  | TmIf(fi,t1,t2,t3) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      let tyT3 = typeof ctx t3 in
      if tyeqv ctx tyT1 TyBool then
        if (tyeqv ctx tyT2 TyAction) && (tyeqv ctx tyT3 TyAction) then
            TyAction
        else if (subtype ctx tyT2 TyFrame) && (subtype ctx tyT3 TyFrame) then
            TyFrame
        else error fi "Error: Unmatched type of then and else clauses"
      else error fi "Error: If condition is not a boolean"
  | TmString(_,_) ->
      TyString
  | TmAssign(fi,t1,t2) -> 
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if tyeqv ctx tyT1 tyT2 then  
        if (tyeqv ctx tyT1 TyBool) || (tyeqv ctx tyT1 TyInt) || (tyeqv ctx tyT1 TyString)
        then TyAction
        else error fi "Unexpected error 5"
      else error fi "Unexpected error 5"
  | TmAdd(fi,t1,t2) -> 
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if tyeqv ctx tyT1 tyT2 then
        if tyeqv ctx tyT1 TyInt then TyInt 
        else if tyeqv ctx tyT1 TyString then TyString
        else error fi "Error: Unexpected argument type for +"
      else error fi "Error: Unexpected argument type for +"
  | TmSub(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyInt
      else error fi "Error: Unexpected argument type for -"
  | TmAnd(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyBool) then TyBool
      else error fi "Error: Unexpected argument type for &"
  | TmOr(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyBool) then TyBool
      else error fi "Error: Unexpected argument type for |"
  | TmXor(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyBool) then TyBool
      else error fi "Error: Unexpected argument type for ^"
  | TmNot(fi,t) ->
      let tyT = typeof ctx t in
      if (tyeqv ctx tyT TyBool) then TyBool
      else error fi "Error: Unexpected argument type for !"
  | TmMul(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyInt
      else error fi "Error: Unexpected argument type for *"
  | TmDiv(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyInt
      else error fi "Error: Unexpected argument type for /"
  | TmGT(fi,t1,t2) -> 
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyBool
      else error fi "Error: Unexpected argument type for >"
  | TmLT(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyBool
      else error fi "Error: Unexpected argument type for <"
  | TmGEQ(fi,t1,t2) -> 
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyBool
      else error fi "Error: Unexpected argument type for >="
  | TmLEQ(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyInt) then TyBool
      else error fi "Error: Unexpected argument type for <="
  | TmEQ(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if tyeqv ctx tyT1 tyT2 then
        if (tyeqv ctx tyT1 TyInt) || (tyeqv ctx tyT1 TyString)
        then TyBool
        else error fi "Error: Unexpected argument type for =="
      else error fi "Error: Unexpected argument type for =="
  | TmNEQ(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      if tyeqv ctx tyT1 tyT2 then
        if (tyeqv ctx tyT1 TyInt) || (tyeqv ctx tyT1 TyString)
        then TyBool
        else error fi "Error: Unexpected argument type for !="
      else error fi "Error: Unexpected argument type for !="
  | TmInt(_,_) ->
      TyInt
  | TmImage(fi,t) ->
      if subtype ctx (typeof ctx t) TyImage then TyImage
      else error fi "Error: Unexpected argument type for image()"
  | TmMusic(fi,t) -> 
      if subtype ctx (typeof ctx t) TyMusic then TyMusic
      else error fi "Error: Unexpected argument type for music()"
  | TmSilent(_) ->
      TyMusic
  | TmHalt(_)
  | TmNop(_) ->
      TyAction
  | TmShow(fi,t1,t2) ->
      if (subtype ctx (typeof ctx t1) TyImage) && (subtype ctx (typeof ctx t2) TyParam) then
        TyAction
      else error fi "Error: Unexpected argument type for show()"
  | TmHide(fi,t) ->
      if subtype ctx (typeof ctx t) TyImage then TyAction
      else error fi "Error: Unexpected argument type for hide()"
  | TmPlay(fi,t) ->
      if subtype ctx (typeof ctx t) TyMusic then TyAction
      else error fi "Error: Unexpected argument type for play()"
  | TmSay(fi,t1,t2,t3) ->
      if (subtype ctx (typeof ctx t1) TyCharacter) && (subtype ctx (typeof ctx t2) TyString) 
         && (subtype ctx (typeof ctx t3) TyMusic)
      then TyAction
      else error fi "Error: Unexpected argument type for say()"
  | TmNull(_) -> TyBot
  | TmMenu(fi,t1,t2,t3,t4,t5,t6) ->
      let chk t = subtype ctx (typeof ctx t) TyOption in
      if (chk t1) && (chk t2) && (chk t3) && (chk t4) && (chk t5) && (chk t6) then TyAction
      else error fi "Error: Unexpected argument type for menu()"
  | TmCont(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in 
      if (tyeqv ctx tyT1 tyT2) && (tyeqv ctx tyT1 TyAction) then TyAction
      else error fi "Error: Unexpected argument type for action backslash"
  | TmCharacter(fi,t1,t2) ->
      if (subtype ctx (typeof ctx t1) TyString) && (subtype ctx (typeof ctx t2) TyImage)
      then TyCharacter
      else error fi "Error: Unexpected argument type for character()"
  | TmNobody(_) ->
      TyCharacter
  | TmScene(fi,t1,t2,t3) ->
      if (subtype ctx (typeof ctx t1) TyImage) && (subtype ctx (typeof ctx t2) TyMusic) 
         && (subtype ctx (typeof ctx t3) TyAction)
      then TyScene
      else error fi "Error: Unexpected argument type for scene()"
  | TmBlank(_) ->
      TyScene
  | TmOption(fi,t1,t2) ->
      if (subtype ctx (typeof ctx t1) TyString) && (subtype ctx (typeof ctx t2) TyAction)
      then TyOption
      else error fi "Error: Unexpected argument type for option()"
  | TmContframe(fi,t1,t2) ->
      if (subtype ctx (typeof ctx t1) TyFrame) && (subtype ctx (typeof ctx t2) TyFrame)
      then TyFrame
      else error fi "Error: Unexpected argument type for frame backslash"
  | TmParam(_,_) ->
      TyParam

(* ------------------------   EVALUATION  ------------------------ *)

type store = int ref * int ref * int ref
let emptystore () =  (ref 0, ref 0, ref 0)

exception NoRuleApplies

let rec printtm ctx t = 
  match t with 
    TmVar(fi,i,_) ->
      (let bind = getbinding fi ctx i in match bind with
        TmAbbBind(t1,_) -> printtm ctx t1
      | TmLocB(id,_) -> pr ("b" ^ (string_of_int (id+1)))
      | TmLocI(id,_) -> pr ("i" ^ (string_of_int (id+1)))
      | TmLocS(id,_) -> pr ("s" ^ (string_of_int (id+1)))
      | _ -> error fi "Unexpected error 3")     
  | TmTrue(_) ->
      pr "true"
  | TmFalse(_) ->
      pr "false"
  | TmIf(_,t1,t2,t3) ->
      (if tyeqv ctx (typeof ctx t2) TyAction then pr "if(" else pr "ifframe("); 
      printtm ctx t1; pr ","; printtm ctx t2; pr ","; printtm ctx t3; pr ")"
  | TmString(_,s) ->
      pr s
  | TmAssign(_,t1,t2) -> 
      (let tyT1 = typeof ctx t1 in 
      if tyeqv ctx tyT1 TyBool then pr "set("
      else if tyeqv ctx tyT1 TyInt then pr "mov("
      else if tyeqv ctx tyT1 TyString then pr "assign(");
      printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmAdd(_,t1,t2) -> 
      (let tyT1 = typeof ctx t1 in
      if tyeqv ctx tyT1 TyInt then pr "add(" else pr "concat(");
      printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmSub(_,t1,t2) ->
      pr "sub("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmAnd(_,t1,t2) ->
      pr "and("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmOr(_,t1,t2) ->
      pr "or("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmXor(_,t1,t2) ->
      pr "xor("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmNot(_,t) ->
      pr "not("; printtm ctx t; pr ")"
  | TmMul(_,t1,t2) ->
      pr "mul("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmDiv(_,t1,t2) ->
      pr "div("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmGT(_,t1,t2) -> 
      pr "greater("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmLT(_,t1,t2) ->
      pr "less("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmGEQ(_,t1,t2) -> 
      pr "geq("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmLEQ(_,t1,t2) ->
      pr "leq("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmEQ(_,t1,t2) ->
      (let tyT1 = typeof ctx t1 in
      if tyeqv ctx tyT1 TyInt then pr "eq(" else pr "same(");
      printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmNEQ(_,t1,t2) ->
      (let tyT1 = typeof ctx t1 in
      if tyeqv ctx tyT1 TyInt then pr "neq(" else pr "diff(");
      printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmInt(_,x) ->
      pr (string_of_int x)
  | TmImage(_,t) ->
      pr "image("; printtm ctx t; pr ")"
  | TmMusic(_,t) -> 
      pr "music("; printtm ctx t; pr ")"
  | TmSilent(_) ->
      pr "silent"
  | TmHalt(_) ->
      pr "halt"
  | TmNop(_) ->
      pr "nop"
  | TmShow(_,t1,t2) ->
      pr "show("; printtm ctx t1;
      (match t2 with
         TmNull(_) -> ()
       | _ -> pr ","; printtm ctx t2);
      pr ")"
  | TmHide(_,t) ->
      pr "hide("; printtm ctx t; pr ")"
  | TmPlay(_,t) ->
      pr "play("; printtm ctx t; pr ")"
  | TmSay(_,t1,t2,t3) ->
      pr "say("; printtm ctx t1; pr ","; printtm ctx t2;
      (match t3 with
         TmNull(_) -> ()
       | _ -> pr ","; printtm ctx t3);
      pr ")"
  | TmNull(_) -> ()
  | TmMenu(_,t1,t2,t3,t4,t5,t6) ->
      pr "menu("; printtm ctx t1;
      let opt t = (match t with
         TmNull(_) -> ()
       | _ -> pr ","; printtm ctx t)
      in
        opt t2; opt t3; opt t4; opt t5; opt t6; pr ")"
  | TmCont(_,t1,t2) ->
      pr "cont("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmCharacter(_,t1,t2) ->
      pr "character("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmNobody(_) ->
      pr "nobody"
  | TmScene(_,t1,t2,t3) ->
      pr "scene("; printtm ctx t1; pr ","; printtm ctx t2; pr ","; printtm ctx t3; pr ")"
  | TmBlank(_) ->
      pr "blank"
  | TmOption(_,t1,t2) ->
      pr "arrow("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmContframe(_,t1,t2) ->
      pr "contframe("; printtm ctx t1; pr ","; printtm ctx t2; pr ")"
  | TmParam(_,s) ->
      pr s

