(* module Core

   Core typechecking and evaluation functions
*)

open Syntax
open Support.Error

type store = int ref * int ref * int ref
val emptystore : unit -> store

val printtm : context -> term -> unit

val typeof : context -> term -> ty
val subtype : context -> ty -> ty -> bool
