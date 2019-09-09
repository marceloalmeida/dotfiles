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

" Line numbers and coloring
set number
set background=dark
highlight LineNr ctermfg=black

" Indentation
filetype plugin indent on

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

" Commands
command! -range=% CL  <line1>,<line2>w !curl -s -F 'clbin=<-' https://clbin.com | tr -d '\n' | pbcopy
command! -range=% CP  <line1>,<line2>w !pbcopy

"Auto Commands
autocmd BufWritePre * call TrimEndLines()
