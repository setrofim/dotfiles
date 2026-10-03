if exists("b:current_syntax")
  finish
endif

syntax match cborNumber /\<-\?\d\+\(\.\d\+\)\?\>/
syntax match cborHexNumber /0x[0-9a-fA-F]\+/
syntax region cborString start=/"/ skip=/\\"/ end=/"/ contains=@Spell
syntax region cborByteString start=/h'/ end=/'/
syntax region cborByteString start=/b64'/ end=/'/
syntax keyword cborBoolean true false
syntax keyword cborNull null undefined
syntax match cborTag /\<\d\+(/
syntax match cborTagClose /)/
syntax match cborPunct /[{}\[\],:]/

" Line comments: ; to end of line (CDDL-style, common in RFC examples
" that mix diagnostic notation with CDDL)
syntax match cborComment /;.*$/ contains=@Spell

" Inline "/ ... /" comments — RFC 8949 Appendix G.1 non-normative
" annotations, typically used after a byte string to show its decoded
" meaning, e.g.: h'A164494554' / {"IETF"} /
syntax region cborInlineComment start=/\// end=/\// contains=@Spell

highlight link cborNumber Number
highlight link cborHexNumber Number
highlight link cborString String
highlight link cborByteString Structure
highlight link cborBoolean Boolean
highlight link cborNull Constant
highlight link cborTag Type
highlight link cborTagClose Type
highlight link cborPunct Delimiter
highlight link cborComment Comment
highlight link cborInlineComment Comment

let b:current_syntax = "cbordiag"
