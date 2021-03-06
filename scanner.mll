(* SOS Scanner *)
(* Written primarily by Sheron, later polish by G *)

{ open Parser 
  
  let find_file file = 
      if Sys.file_exists file then file
      else if Sys.file_exists ("lib/"^file) then ("lib/"^file)
      else raise (Failure ("Could not find file "^file))

  let import_table = Hashtbl.create 10
}

(* Definitions *)
let digit = ['0'-'9']
let digits = digit+

(* Rules *)

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf }
| "/*"     { comment 0 lexbuf }           (* Comments *)
| "//"     { single_comment lexbuf }            (* Single line comments *)
| "import " ([^'\n']+".sos" as file) { 
  let file = find_file file in
  if Hashtbl.mem import_table file then IMPORT [] (* Ignore *)
  else (
  Hashtbl.add import_table file ();
  let read = Lexing.from_channel (open_in file) in
  let parsed = Parser.program token read in
  IMPORT parsed ) } 
| '('      { LPAREN }
| ')'      { RPAREN }
| '{'      { LBRACE }
| '}'      { RBRACE }
| '['      { LBRACK }
| ']'      { RBRACK }
| '$'      { DOLLAR }
| ','      { COMMA }
| ':'      { COLON }
| '.'      { DOT }
| "->"     { TO }
| '+'      { ADD }
| '-'      { SUB }
| "**"     { MMUL }
| '*'      { MUL }
| '/'      { DIV }
| '%'      { MOD }
| '@'      { CONCAT }
| ';'      { SEQ }
| "=="     { EQEQ }
| "!="     { NEQ }
| '!'      { NOT }
| '='      { EQ }
| '<'      { LT }
| '>'      { GT }
| "<="     { LTEQ }
| ">="     { GTEQ }
| "&&"     { AND }
| "||"     { OR }
| "of"     { OF }
| "if"     { IF }
| "then"   { THEN }
| "else"   { ELSE }
| "struct" { STRUCT }
| "alias"  { ALIAS }
| "array"  { ARRAY }
| "func"   { FUNC }
| digits as lxm { INTLIT(int_of_string lxm) } 
| digits '.'  digit* ( ['e' 'E'] ['+' '-']? digits )? as lxm { FLOATLIT(lxm) }
| "true"   { BOOLLIT(true) }
| "false"  { BOOLLIT(false) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*     as lxm { VAR(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }


and comment depth = parse
  "*/" { if depth==0 then token lexbuf else comment (depth-1) lexbuf }
| "/*" { comment (depth+1) lexbuf }
| _    { comment depth lexbuf }

and single_comment = parse
  '\n' { token lexbuf }
| _    { single_comment lexbuf }
