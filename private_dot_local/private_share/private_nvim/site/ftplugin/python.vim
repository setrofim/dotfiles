set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent
set number
set shiftround 


" Breakpoints
let g:pymode_breakpoint_cmd = "import ipdb; ipdb.set_trace()  # XXX BREAKPOINT"
fun! SetPythonBreakPoint(lnum) "{{{
    let line = getline(a:lnum)
    if strridx(line, g:pymode_breakpoint_cmd) != -1
        normal dd
    else
        let plnum = prevnonblank(a:lnum)
        call append(line('.')-1, repeat(' ', indent(plnum)).g:pymode_breakpoint_cmd)
        normal k
    endif

    " Save file without any events
    if &modifiable && &modified | noautocmd write | endif	
endfunction "}}}

imap <F7> <Esc>:call SetPythonBreakPoint(line('.'))<CR>ja
nmap <F7> :call SetPythonBreakPoint(line('.'))<CR>

