(* Module Main: The main program.  Deals with processing the command
   line, reading files, building and connecting lexers and parsers, etc. 
   
   For most experiments with the implementation, it should not be
   necessary to change this file.
*)

open Format
open Support.Pervasive
open Support.Error
open Syntax
open Core

let searchpath = ref [""]

let started = ref 0

let argDefs = [
  "-I",
      Arg.String (fun f -> searchpath := f::!searchpath),
      "Append a directory to the search path"]

let parseArgs () =
  let inFile = ref (None : string option) in
  Arg.parse argDefs
     (fun s ->
       match !inFile with
         Some(_) -> err "You must specify exactly one input file"
       | None -> inFile := Some(s))
     "";
  match !inFile with
      None -> err "You must specify an input file"
    | Some(s) -> s

let openfile infile = 
  let rec trynext l = match l with
        [] -> err ("Could not find " ^ infile)
      | (d::rest) -> 
          let name = if d = "" then infile else (d ^ "/" ^ infile) in
          try open_in name
            with Sys_error m -> trynext rest
  in trynext !searchpath

let parseFile inFile =
  let pi = openfile inFile
  in let lexbuf = Lexer.create inFile pi
  in let result =
    try Parser.toplevel Lexer.main lexbuf with Parsing.Parse_error -> 
    error (Lexer.info lexbuf) "Parse error"
in
  Parsing.clear_parser(); close_in pi; result

let alreadyImported = ref ([] : string list)

let process_assign fi ctx (refb,refi,refs) x bind =
  match bind with
    TmLocB(_,t) -> 
      let ctx' = addbinding ctx x (TmLocB(!refb,t)) in
        refb:=(!refb)+1;
        pr ("b" ^ (string_of_int (!refb)) ^ "="); printtm ctx' t; pr ";\n";
        (ctx',(refb,refi,refs))
  | TmLocI(_,t) ->
      let ctx' = addbinding ctx x (TmLocI(!refi,t)) in
        refi:=(!refi)+1; 
        pr ("i" ^ (string_of_int (!refi)) ^ "="); printtm ctx' t; pr ";\n";
        (ctx',(refb,refi,refs))
  | TmLocS(_,t) ->
      let ctx' = addbinding ctx x (TmLocS(!refs,t)) in
        refs:=(!refs)+1; 
        pr ("s" ^ (string_of_int (!refs)) ^ "="); printtm ctx' t; pr ";\n";
        (ctx',(refb,refi,refs))
  | _ -> error fi "Unexpected error 1"
  
let process_bind fi ctx x bind =
  match bind with
    TmAbbBind(t,None) ->
      let tyT = typeof ctx t in
        addbinding ctx x (TmAbbBind(t,Some(tyT)))
  | _ -> error fi "Unexpected error 2"

let rec process_command (ctx,store) cmd = match cmd with
    Header(fi,x) ->
      pr x; print_newline(); pr "```\n"; (ctx,store)
  | Assign(fi,x,bind) ->
      let ctx',store' = process_assign fi ctx store x bind in
      (ctx',store')
  | Eval(fi,t) -> 
      (if (!started) == 0 then (pr "```\n";started:=1) else ());
      (if subtype ctx (typeof ctx t) TyFrame then (printtm ctx t; pr ";\n")
      else error fi "Error: \"main\" is not a Frame");(ctx,store)
  | Bind(fi,x,bind) -> 
      (if (!started) == 0 then (pr "```\n";started:=1) else ());
      let ctx' = process_bind fi ctx x bind in
      (ctx',store)
  
let process_file f (ctx,store) =
  alreadyImported := f :: !alreadyImported;
  let cmds,_ = parseFile f ctx in
  let g (ctx,store) c =  
    process_command (ctx,store) c
  in
    List.fold_left g (ctx,store) cmds

let main () = 
  let inFile = parseArgs() in
  let _ = process_file inFile (emptycontext, emptystore()) in
  ()

let () = set_max_boxes 1000
let () = set_margin 67
let res = 
  Printexc.catch (fun () -> 
    try main();0 
    with Exit x -> x) 
  ()
let () = print_flush()
let () = exit res
