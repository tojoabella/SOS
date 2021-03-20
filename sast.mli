(* Semantically-checked AST *)

open Ast

type sexpr = typeid * sx
and sx = 
  SVarDef of tid * id * sexpr                (* type name = val *)
| SFxnDef of tid * id * argtype list * sexpr (* type id (type name, ...) = val *)
| SAssign of id * sexpr                      (* id = val *)
| SAssignStruct of id * id * sexpr           (* id.field = val *)
| SAssignArray of id * sexpr * sexpr          (* id[expr] = expr *)
| SUop of uop * sexpr                        (* uop expr *)
| SBinop of sexpr * operator * sexpr          (* expr op expr *)
| SFxnApp of id * sfxnargs
| SIfElse of sexpr * sexpr * sexpr             (* if expr then expr else expr *)
| SArrayCon of sexpr list                    (* [expr, ...] *)
| SAnonStruct of sexpr list                  (* {expr, ...} *)
| SNamedStruct of id * sexpr list           (* name{expr, ...} *)
| SVar of id                                (* name *)
| SStructField of id * id                   (* name.id *)
| SIntLit of int                            (* int *)
| SFloatLit of float                        (* float *)

and snamedArg = id * sexpr 

and sfxnargs = 
  SOrderedFxnArgs of sexpr list
| SNamedFxnArgs of snamedArg list

type sstmt = 
  STypedef of typedef
| SExpression of sexpr
| SImport of import

type sprogram = sstmt list