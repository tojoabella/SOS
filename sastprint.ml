(* Very basic """pretty""" printer for SAST *)
(* Written by G *)
open Sast
open Ast

let basic_print sast = 
  let rec sargl_string l =
    List.fold_left (fun str (t, id) -> (if str = "" then "" else str^", ")^typeid_string t ^" "^id) "" l
  and typeid_string = function
    Int -> "int"
  | Float -> "float"
  | Bool -> "bool"
  | Void -> "void"
  | Array(t) -> "array "^typeid_string t
  | Struct(l) -> "{"^sargl_string l^"}"
  | Func(_) -> "func"
  | EmptyArray -> "[]"
  in

  let print_typedef = function
    SAlias(nm, al) -> print_string("alias "^nm^" = "^typeid_string al^"\n")
  | SStructDef(nm,  l) -> print_string("struct "^nm^" = {"^sargl_string l^"}\n")
  in

  let rec explstr l = List.fold_left
    (fun s e -> (if s="" then s else s^", ")^sexp_string e) "" l

  and sexp_string (t, e) = match e with
    SVarDef(_, var, exp) -> typeid_string t ^" "^var^" = "^sexp_string exp^"\n"
  | SAssign(var, exp) -> "("^typeid_string t^") "^var^" = "^sexp_string exp^"\n"
  | SAssignStruct(var, f, exp) -> "("^typeid_string t^") "^sexp_string var^"."^f^" = "^sexp_string exp^"\n"
  | SAssignArray(var, e1, e2) -> "("^typeid_string t^") "^sexp_string var^"["^sexp_string e1^"] = "^sexp_string e2^"\n"
  | SUop(op, exp) -> "("^typeid_string t^")"^
    (match op with Not -> "!" | Neg -> "-")^sexp_string exp
  | SBinop (e1, op, e2) -> let opstr  = match op with
      Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/" | Mod -> "%" |
      MMul -> "**" |
      Eq -> "==" | Neq -> "!=" | Less -> "<" | Greater -> ">" | LessEq -> "<=" |
      GreaterEq -> ">=" | And -> "&&" | Or -> "||" | Seq -> ";" |
      Of -> "of" | Concat -> "@" in
    "("^typeid_string t^") ("^sexp_string e1^" "^opstr^" "^sexp_string e2^")"
  | SIterFxnApp (fe, expl)
  | SFxnApp (fe, expl) -> "("^typeid_string t^") "^sexp_string fe^"("^
    (explstr expl)^")\n"
  | SIfElse(e1, e2, e3) -> "("^typeid_string t^") if "^sexp_string e1^"\nthen "^sexp_string e2^"\nelse "^sexp_string e3^"\n"
  | SArrayCon(expl) -> 
      "("^typeid_string t^") ["^explstr expl^"]"
  | SStruct(nm, expl) -> 
      "("^typeid_string t^") "^nm^"{"^explstr expl^"}"
  | SVar(id) -> "("^typeid_string t^") "^id
  | SStructField(id, f) -> "("^typeid_string t^") "^sexp_string id^"."^f
  | SIntLit(i) -> string_of_int i
  | SFloatLit(f) -> f
  | SBoolLit(b) -> string_of_bool b
  | SArrayAccess(nm, idx) -> "("^typeid_string t^") "^sexp_string nm^"["^sexp_string idx^"]"
  | SArrayLength(nm) -> sexp_string nm^".length"
  | SCast(exp) -> sexp_string exp
  in

  let print_sstmt = function
    STypeDef(td) -> print_typedef td
  | SExpression(sexpr) -> print_string(sexp_string sexpr)
  | SFxnDef(_, var, sargl, exp) ->
      print_string(var^"("^sargl_string sargl^") = "^sexp_string exp^"\n")

  in List.iter print_sstmt sast

(*
let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.program Scanner.token lexbuf in
  let sast = Semant.check ast in 
  basic_print sast *)
