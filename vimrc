" Pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
call pathogen#helptags()

" Status bar
set laststatus=2

" Customize vim-airline
let g:airline_powerline_fonts=1
set t_Co=256
let g:airline_theme_patch_func = 'AirlineThemePatch'

" vim-terraform variables
let g:terraform_fmt_on_save=1
let g:terraform_fold_sections=1
set nofoldenable

" Tabstop
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Syntax highlighting
syntax on

" Cursor manipulation - https://github.com/mitchellh/vim-misc/blob/master/vimrc.vim
"set scrolloff=999         " Keep the cursor centered in the screen
set showmatch             " Highlight matching braces
set title                 " Set the title for gvim
set visualbell            " Use a visual bell to notify us
set incsearch             " Start showing results as you type
set smartcase             " Be smart about case sensitivity when searching
set cursorline            " Set cursor line
"set cursorcolumn          " Set cursor line
"hi CursorColumn   cterm=NONE ctermbg=8 ctermfg=NONE
"hi CursorLine   cterm=NONE ctermbg=8 ctermfg=NONE

" Line numbers and coloring
set number
set background=dark
highlight LineNr ctermfg=black

" Indentation
filetype plugin indent on

" Backspace fix
set backspace=indent,eol,start

" Enable fzf
set rtp+=/usr/local/opt/fzf

set mmp=5000

" testing
let g:airline#extensions#branch#enabled = 1
"let g:airline#extensions#branch#format = 'CustomBranchName'
"function! CustomBranchName(name)
"  return '[' . a:name . ']'
"endfunction


" Functions
function! AirlineThemePatch(a)
  if g:airline_section_b == ''
    let g:airline_section_b='%(%{VisualSelectionSize()}%)'
  endif
endfunction

function! VisualSelectionSize() 
    if mode() == "v" 
        " Exit and re-enter visual mode, because the marks 
        " ('< and '>) have not been updated yet. 
        exe "normal \<ESC>gv" 
        if line("'<") != line("'>") 
            return (line("'>") - line("'<") + 1) . ' lines' 
        else 
            return (col("'>") - col("'<") + 1) . ' chars' 
        endif 
    elseif mode() == "V" 
        exe "normal \<ESC>gv" 
        return (line("'>") - line("'<") + 1) . ' lines' 
    elseif mode() == "\<C-V>" 
        exe "normal \<ESC>gv" 
        return (line("'>") - line("'<") + 1) . 'x' . (abs(col("'>") - col("'<")) + 1) . ' block' 
    else 
        return '' 
    endif 
endfunction

function TrimEndLines()
    let save_cursor = getpos(".")
    ":silent! %s#\($\n\s*\)\+\%$##
    :silent! %s/\($\n\s*\)\+\%$//e
    call setpos('.', save_cursor)
endfunction

function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction

command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()

function! s:sort_by_header(bang, pat) range
  let pat = a:pat
  let opts = ""
  if pat =~ '^\s*[nfxbo]\s'
    let opts = matchstr(pat, '^\s*\zs[nfxbo]')
    let pat = matchstr(pat, '^\s*[nfxbo]\s*\zs.*')
  endif
  let pat = substitute(pat, '^\s*', '', '')
  let pat = substitute(pat, '\s*$', '', '')
  let sep = '/'
  if len(pat) > 0 && pat[0] == matchstr(pat, '.$') && pat[0] =~ '\W'
    let [sep, pat] = [pat[0], pat[1:-2]]
  endif
  if pat == ''
    let pat = @/
  endif

  let ranges = []
  execute a:firstline . ',' . a:lastline . 'g' . sep . pat . sep . 'call add(ranges, line("."))'

  let converters = {
        \ 'n': {s-> str2nr(matchstr(s, '-\?\d\+.*'))},
        \ 'x': {s-> str2nr(matchstr(s, '-\?\%(0[xX]\)\?\x\+.*'), 16)},
        \ 'o': {s-> str2nr(matchstr(s, '-\?\%(0\)\?\x\+.*'), 8)},
        \ 'b': {s-> str2nr(matchstr(s, '-\?\%(0[bB]\)\?\x\+.*'), 2)},
        \ 'f': {s-> str2float(matchstr(s, '-\?\d\+.*'))},
        \ }
  let arr = []
  for i in range(len(ranges))
    let end = max([get(ranges, i+1, a:lastline+1) - 1, ranges[i]])
    let line = getline(ranges[i])
    let d = {}
    let d.key = call(get(converters, opts, {s->s}), [strpart(line, match(line, pat))])
    let d.group = getline(ranges[i], end)
    call add(arr, d)
  endfor
  call sort(arr, {a,b -> a.key == b.key ? 0 : (a.key < b.key ? -1 : 1)})
  if a:bang
    call reverse(arr)
  endif
  let lines = []
  call map(arr, 'extend(lines, v:val.group)')
  let start = max([a:firstline, get(ranges, 0, 0)])
  call setline(start, lines)
  call setpos("'[", start)
  call setpos("']", start+len(lines)-1)
endfunction
command! -range=% -bang -nargs=+ SortGroup <line1>,<line2>call <SID>sort_by_header(<bang>0, <q-args>)

" Commands
command! -range=% CL  <line1>,<line2>w !curl -s -F 'clbin=<-' https://clbin.com | tr -d '\n' | pbcopy
command! -range=% CP  <line1>,<line2>w !pbcopy

"Auto Commands
autocmd BufWritePre * call TrimEndLines()

"Mappings
let mapleader=","
nmap <leader>d :NERDTreeToggle<CR>
nmap <leader>f :Files<CR>

" persist START
set undofile " Maintain undo history between sessions
set undodir=~/.vim/undodir

" Secure vim for gopass
au BufNewFile,BufRead /private/**/gopass** setlocal noswapfile nobackup noundofile
