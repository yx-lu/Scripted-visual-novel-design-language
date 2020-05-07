open Format
open Support.Error
open Support.Pervasive

(* ---------------------------------------------------------------------- *)
(* Datatypes *)

type ty =
    TyInt
  | TyBool
  | TyString
  | TyImage
  | TyMusic
  | TyParam
  | TyAction
  | TyCharacter
  | TyScene
  | TyOption
  | TyFrame
  | TyBot

type term =
    TmVar of info * int * int
  | TmTrue of info
  | TmFalse of info
  | TmIf of info * term * term * term
  | TmString of info * string
  | TmAssign of info * term * term
  | TmAdd of info * term * term
  | TmSub of info * term * term
  | TmAnd of info * term * term
  | TmOr of info * term * term
  | TmXor of info * term * term
  | TmNot of info * term
  | TmMul of info * term * term
  | TmDiv of info * term * term
  | TmGT of info * term * term
  | TmLT of info * term * term
  | TmGEQ of info * term * term
  | TmLEQ of info * term * term
  | TmEQ of info * term * term
  | TmNEQ of info * term * term
  | TmInt of info * int
  | TmImage of info * term
  | TmMusic of info * term
  | TmSilent of info
  | TmHalt of info
  | TmNop of info
  | TmShow of info * term * term
  | TmHide of info * term
  | TmPlay of info * term
  | TmSay of info * term * term * term
  | TmNull of info  (* Null stuff *)
  | TmMenu of info * term * term * term * term * term * term
  | TmCont of info * term * term
  | TmCharacter of info * term * term
  | TmNobody of info
  | TmScene of info * term * term * term
  | TmBlank of info
  | TmOption of info * term * term
  | TmContframe of info * term * term
  | TmParam of info * string
  
type binding =
    NameBind 
  | TmAbbBind of term * (ty option)
  | TmLocB of int * term
  | TmLocI of int * term
  | TmLocS of int * term

type context = (string * binding) list

type command =
    Header of info * string
  | Assign of info * string * binding
  | Eval of info * term
  | Bind of info * string * binding

(* ---------------------------------------------------------------------- *)
(* Context management *)

let emptycontext = []

let ctxlength ctx = List.length ctx

let addbinding ctx x bind = List.append ctx [(x,bind)]

let addname ctx x = addbinding ctx x NameBind

let rec isnamebound ctx x =
  match ctx with
      [] -> false
    | (y,_)::rest ->
        if y=x then true
        else isnamebound rest x

let index2name fi ctx x =
  try
    let (xn,_) = List.nth ctx x in
    xn
  with Failure _ ->
    let msg =
      Printf.sprintf "Variable lookup failure: offset: %d, ctx size: %d" in
    error fi (msg x (List.length ctx))

let rec name2index fi ctx x =
  match ctx with
      [] -> error fi ("Identifier " ^ x ^ " is unbound")
    | (y,_)::rest ->
        if y=x then 0
        else 1 + (name2index fi rest x)



(* ---------------------------------------------------------------------- *)
(* Context management (continued) *)

let rec getbinding fi ctx i =
  try
    let (_,bind) = List.nth ctx i in
    bind 
  with Failure _ ->
    let msg =
      Printf.sprintf "Variable lookup failure: offset: %d, ctx size: %d" in
    error fi (msg i (List.length ctx))
(* ---------------------------------------------------------------------- *)
(* Extracting file info *)

let tmInfo t = match t with
    TmVar(fi,_,_) -> fi
  | TmTrue(fi) -> fi
  | TmFalse(fi) -> fi
  | TmIf(fi,_,_,_) -> fi
  | TmString(fi,_) -> fi
  | TmAssign(fi,_,_) -> fi
  | TmAdd(fi,_,_) -> fi
  | TmSub(fi,_,_) -> fi
  | TmAnd(fi,_,_) -> fi
  | TmOr(fi,_,_) -> fi
  | TmXor(fi,_,_) -> fi
  | TmNot(fi,_) -> fi
  | TmMul(fi,_,_) -> fi
  | TmDiv(fi,_,_) -> fi
  | TmGT(fi,_,_) -> fi
  | TmLT(fi,_,_) -> fi
  | TmGEQ(fi,_,_) -> fi
  | TmLEQ(fi,_,_) -> fi
  | TmEQ(fi,_,_) -> fi
  | TmNEQ(fi,_,_) -> fi
  | TmInt(fi,_) -> fi
  | TmImage(fi,_) -> fi
  | TmMusic(fi,_) -> fi
  | TmSilent(fi) -> fi
  | TmHalt(fi) -> fi
  | TmNop(fi) -> fi
  | TmShow(fi,_,_) -> fi
  | TmHide(fi,_) -> fi
  | TmPlay(fi,_) -> fi
  | TmSay(fi,_,_,_) -> fi
  | TmNull(fi) -> fi
  | TmMenu(fi,_,_,_,_,_,_) -> fi
  | TmCont(fi,_,_) -> fi
  | TmCharacter(fi,_,_) -> fi
  | TmNobody(fi) -> fi
  | TmScene(fi,_,_,_) -> fi
  | TmBlank(fi) -> fi
  | TmOption(fi,_,_) -> fi
  | TmContframe(fi,_,_) -> fi
  | TmParam(fi,_) -> fi
  

(* ---------------------------------------------------------------------- *)
(* Printing *)


