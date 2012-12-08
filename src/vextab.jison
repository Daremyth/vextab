/*
  LALR(1) Grammar for VexTab
  Mohit Cheppudira <mohit@muthanna.com>

  Process with Jison: http://zaach.github.com/jison/

  Note: This file is new. The current parser in vextab.js is
  a hand-rolled recursive descent parser.
*/

%{
  Vex.L("Starting parser.");
%}

%lex
%s notes
%%

"notes"                        { this.begin('notes'); return 'NOTES'; }
"tabstave"                       return 'TABSTAVE'
<INITIAL>[^\s=]+                 return 'WORD'


"/"                   return '/'
"-"                   return '-'
"+"                   return '+'
":"                   return ':'
"="                   return '='
"("                   return '('
")"                   return ')'
"["                   return '['
"]"                   return ']'
"|"                   return '|'
"."                   return '.'

/* These are valid inside fret/string expressions only */
<notes>[b]            return 'b'
<notes>[s]            return 's'
<notes>[h]            return 'h'
<notes>[p]            return 'p'
<notes>[t]            return 't'
<notes>[q]            return 'q'
<notes>[w]            return 'w'
<notes>[h]            return 'h'
<notes>[d]            return 'd'
<notes>[v]            return 'v'
<notes>[V]            return 'V'
<notes>[0-9]+         return 'NUMBER'

/* New lines reset your state */
[\r\n]+               { this.begin('INITIAL'); }
\s+                   /* skip whitespace */
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

%start e

%%

e:
  maybe_vextab EOF
    { return $1 }
  ;

maybe_vextab
  :
    { $$ = null }
  | vextab
    { $$ = $1 }
  ;

vextab
  : stave
    { $$ = [$1] }
  | vextab stave
    { $$ = [].concat($1, $2) }
  ;

stave
  : TABSTAVE maybe_options maybe_notelist
    { $$ = { element: "stave", options: $2, notes: $3 } }
  ;

maybe_options
  :
    { $$ = null }
  | options
    { $$ = $1 }
  ;

options
  : WORD '=' WORD
    { $$ = [{key: $1, value: $3}] }
  | options WORD '=' WORD
    { $$ = [].concat($1, [{key: $2, value: $4}]) }
  ;

maybe_notelist
  :
    { $$ = null }
  | notelist
    { $$ = $1 }
  ;

notelist
  : NOTES notes
  | notelist NOTES notes
  ;

notes
  : lingo
  | lingo notes
  | '[' lingo ']'
  | '[' lingo ']' notes
  | '[' lingo notes ']'
  | '[' lingo notes ']' notes
  ;

lingo
  : line
  | chord
  ;

time
  : ':' time_values maybe_dot
  ;

time_values
  : NUMBER
  | 'q'
  | 'w'
  | 'h'
  ;

maybe_dot
  :
  | 'd'
  ;

line
  : frets maybe_decorator '/' string
  | time
  | '|'
  ;

chord
  : '(' chord_line ')' maybe_decorator
  | articulation chord
  ;

chord_line
  : line
  | chord_line '.' line
  ;

frets
  : NUMBER
  | articulation timed_fret
  | frets maybe_decorator articulation timed_fret
  ;

timed_fret
  : ':' time_values maybe_dot ':' NUMBER
  |  NUMBER
  ;

string
  : NUMBER
  ;

articulation
  : '-'
  | 's'
  | 't'
  | 'b'
  | 'h'
  | 'p'
  ;

maybe_decorator
  : 'v'
  | 'V'
  |
  ;