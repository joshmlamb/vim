" Plugins
packadd! everforest


" Variables
let g:everforest_background = 'hard'
let g:sneak#label = 1
let g:mucomplete#enable_auto_at_startup = 1
let g:comment_strings = {
\    'sh': ['# '],
\    'zsh': ['# '],
\    'vim': ['" '],
\    'html': ['<!--', '-->'],
\    'vue': ['//', '<!--', '-->'],
\    'css': ['/*', '*/'],
\    'scss': ['/*', '*/'],
\    'javascript': ['//', '{/*', '*/}'],
\    'liquid': ['{% comment %}', '{% endcomment %}'],
\    'twig': ['{#', '#}'],
\    'blade': ['{{--', '--}}'],
\}
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
let mapleader = " "


" Set Options
syntax on
filetype plugin indent on

set hidden
set nocompatible
set clipboard+=unnamed
set relativenumber number
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set formatoptions-=t
set textwidth=0
set wrapmargin=0
set ruler
set colorcolumn=80
set scrolloff=8
set mouse=a
set backspace=indent,eol,start
set laststatus=2
set completeopt+=menu,menuone,noinsert,noselect
set omnifunc=syntaxcomplete#Complete
set shortmess+=c
set path+=**
set wildmenu
set wildignore+=**/node_modules/**,**/.git/**
set hlsearch
set incsearch
set smartcase
set ignorecase
set nobackup
set nowb
set noswapfile
set undofile
set undodir=~/.vim/undo
set updatetime=150

if has('termguicolors')
  set termguicolors
endif
set background=dark
colorscheme everforest

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %l:%c
set statusline+=\ 

if executable("fzf")
    set rtp+=~/.fzf
endif

if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
endif


" Force filetypes
au BufNewFile,BufRead *.astro set syntax=html


" Maps
nnoremap <leader>rc :source ~/.vim/vimrc<CR>
nnoremap <leader>h :help<space>
nnoremap <leader>cl :setlocal cursorcolumn! cursorline!<CR>
nnoremap <CR> :noh<CR><CR>
"noremap <up> <nop>
"noremap <down> <nop>
"noremap <left> <nop>
"noremap <right> <nop>

if executable("fzf")
    nnoremap <leader>f :GFiles<CR>
    nnoremap <leader>af :Files<CR>
    nnoremap <leader>b :Buffers<CR>
    nnoremap <leader>sp :Rg<CR>
else
    nnoremap <leader>f :find<space>
    nnoremap <leader>b :call setqflist(getbufinfo({'buflisted':1})) \| copen<CR>
endif

nnoremap <leader>cb :bd<CR>
nnoremap <leader>cB :%bd\|e#\|bd#<CR>

nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> <esc>:m .+1<CR>==
inoremap <C-k> <esc>:m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==

inoremap {<CR> {<CR>}<esc>O
inoremap { {}<esc>i
inoremap {{ {{  }}<esc>2hi
inoremap {% {%  %}<esc>2hi
inoremap ( ()<esc>i
inoremap [ []<esc>i
inoremap ' ''<esc>i
inoremap " ""<esc>i


" Auto-close tags
function CloseTag()
    return "</" . split(matchstr(getline('.'), '<\zs[^<]\+\ze>'), " ")[0] . ">"
endfunction
inoremap <expr> </ CloseTag()
 

" Toggle File Explorer
function ToggleNetrw()
    if exists("g:netrw_buffer") && bufexists(g:netrw_buffer)
        exe "bd".g:netrw_buffer | unlet g:netrw_buffer
    else
        Vexplore | let g:netrw_buffer=bufnr("%")
    endif
endfunction
nnoremap <leader>e :call ToggleNetrw()<CR>


" Comment Helper
function CommentUtil(line, show_alternate) abort
    let comment_strings = g:comment_strings[&filetype]
    let comment_list_length = len(comment_strings)
    let line = trim(a:line)

    if a:show_alternate && comment_list_length == 3
        let comment_strings = comment_strings[1:2]
        let comment_list_length = 2
    elseif comment_list_length == 3 
        let comment_strings = comment_strings[0:0]
        let comment_list_length = 1
    endif

    let is_commented = line[0:strlen(comment_strings[0]) - 1] == comment_strings[0]

    return {
    \   'comment_strings': comment_strings,
    \   'comment_list_length': comment_list_length,
    \   'is_commented': is_commented,
    \}
endfunction

function CommentLine(...) abort
    set paste
    let line = getline('.')
    let utils = CommentUtil(line, get(a:, 1, 0)) 

    if utils['is_commented']
        exe "normal ^" . strlen(utils['comment_strings'][0]) . "x"

        if utils['comment_list_length'] == 2
            exe "normal $" . (strlen(utils['comment_strings'][1]) - 1) . "h" . strlen(utils['comment_strings'][1]) . "x"
        endif
    else
        if utils['comment_list_length'] == 1
            exe "normal I" . utils['comment_strings'][0] . "\<esc>^"
        elseif utils['comment_list_length'] == 2
            exe "normal I" . utils['comment_strings'][0] . "\<esc>A" . utils['comment_strings'][1] . "\<esc>^"
        endif
    endif

    set nopaste
endfunction

function CommentSelection(...) abort range
    set paste
    let line = getline("'<")
    let utils = CommentUtil(line, get(a:, 1, 0)) 

    if utils['comment_list_length'] == 1
        for l:line in range(line("'<"), line("'>"))
            exe "normal " . l:line . "gg"
            call CommentLine()
        endfor
    elseif utils['comment_list_length'] == 2
        if utils['is_commented']
            exe line("'<")."normal dd" | exe line("'>")."normal dd"
        else
            exe line("'<")."normal O". utils['comment_strings'][0] | exe line("'>")."normal o". utils['comment_strings'][1]
        endif
    endif

    set nopaste
endfunction
noremap <leader>/ :call CommentLine()<CR>
vnoremap <leader>/ :call CommentSelection()<CR>
noremap <leader>? :call CommentLine(1)<CR>
vnoremap <leader>? :call CommentSelection(1)<CR>


" Toggle Quickfix lList
function ToggleQuickfix()
    let quickfix_state = len(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist'))

    if quickfix_state == 0 
        copen
    else
        cclose
    endif
endfunction
nnoremap <silent> <leader>q :call ToggleQuickfix()<CR>
