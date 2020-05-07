(* module Syntax: syntax trees and associated support functions *)

open Support.Pervasive
open Support.Error

(* Data type definitions *)
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

type command =
    Header of info * string
  | Assign of info * string * binding
  | Eval of info * term
  | Bind of info * string * binding

(* Contexts *)
type context
val emptycontext : context 
val ctxlength : context -> int
val addbinding : context -> string -> binding -> context
val addname: context -> string -> context
val index2name : info -> context -> int -> string
val getbinding : info -> context -> int -> binding
val name2index : info -> context -> string -> int
val isnamebound : context -> string -> bool

(* Misc *)
val tmInfo: term -> info

