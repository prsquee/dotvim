" sets {{{
syntax enable
set encoding=utf-8
scriptencoding utf-8
set ambiwidth=single
set mouse=nicr
set autoread
filetype plugin indent on
set t_Co=256
set number
set relativenumber
set ruler
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set cursorline
set nocursorcolumn

set showcmd                       " display incomplete commands
set foldenable                    " auto folding enabled
set fdm=marker

set hidden                        " Allow backgrounding buffers without writing them, and remember marks/undo for backgrounded buffers

"" Whitespace
set nowrap                        " don't wrap lines
set tabstop=2                     " a tab is two spaces
set softtabstop=2
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode

"" List chars, this can be toggled with leader+l, default is on
set listchars=""                  " Reset the listchars
set listchars=tab:▸\ 
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=nbsp:.
set listchars+=eol:¬              " end of line char

"" Searching
set magic                         " \v advance magic here
set hlsearch                      " highlight matches
set incsearch                     " incremental searching
set ignorecase                    " searches are case insensitive
set showmatch
set smartcase                     " ... unless they contain at least one capital letter
set pastetoggle=<F2>
set scrolloff=3                   " provide some context when editing

set history=100

set autoindent
filetype plugin indent on
set clipboard=unnamed
set background=dark
let mapleader=","
" }}}
" autocommands {{{
if has("autocmd")
  " Editing just texts or markdown {{{
  augroup SetupTextEditingMode
    autocmd!
    au BufReadPre,BufRead,BufNewFile,BufWritePre,FileReadPre *.txt
          \ colorscheme solarized8_flat |
          \ call CheckDarkMode()       |
          \ call SetupWrapping()       |
          \ call PrepareSpelling()     |
          \ call s:lightline_update()  |
          \ call MultipleHighlightsUpdate()
  augroup END
  " }}}
  " make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ ) {{{
  au FileType python set softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79
  "}}}
  "auto save views and folds {{{
   autocmd BufWinLeave *.* mkview
   autocmd BufWinEnter *.* silent loadview
  "}}}
 endif
" }}}
" macOS specific stuff {{{
if has("macunix")
  " Font settings {{{
  if has('gui_running')
    set guifont=MesloLGS\ NF:h14
      " hide all scrollbars and only show tabbar
    " set antialias
    set guioptions=e
  endif
  "}}}
  " Open current case
  function! OpenCase()
    ":t gets the base name of the file and :r removes the extension
    let l:sfdc = 'https://gss--c.visualforce.com/apex/Case_View?sbstr='
    let l:casenumber = matchstr(expand('%:t:r'), '\v\d{8}')
    if ! empty(l:casenumber)
      exec ":silent! !open \"" . l:sfdc . l:casenumber . "\""
    else
      echo 'This is not a case file.'
    endif
  endfun
  " ssh to current case
  function! SSHCase()
    let l:casenumber = matchstr(expand('%:t:r'), '\v\d{8}')
    let l:alfred1 = "!osascript -e 'tell application \"Alfred 5\" to search \"ssh " . l:casenumber . "\"' -e 'tell application \"System Events\" to key code 36'"
    if ! empty(l:casenumber)
      exec l:alfred1
    else
      echo 'This is not a case file.'
    endif
  endfun


  " open url in the default browser
  function! OpenURI()
    let l:uri = matchstr(getline("."), 'https\?:\/\/[^ >,;"]\+')
    if ! empty(l:uri)
      echo "opening " . l:uri
      exec ":silent! !open \"" . l:uri . "\""
    else
      echo "No URI found in line."
    endif
  endfun

  " remaps for when working on macOS
  nnoremap <silent> <leader>d :!open dict://<cword><CR><CR>
  nnoremap <silent> <leader>m :!open wais://1/<cword><CR><CR>
  nnoremap <silent> <leader>r :!open -R %<CR>
  nnoremap <silent> <leader>o :!open %<CR>
  nnoremap <silent> <leader>w :call OpenURI()<CR>
  nnoremap <silent> <leader>x :call OpenCase()<CR>

else
  " running on a linux or bsd
  function PBCopyToRemoteOSX() range
    echo system('echo '.shellescape(join(getline(a:firstline, a:lastline), "\n")).'| pbcopy && echo "copied!"')
  endfunction
  vnoremap <silent> <S-y> :call PBCopyToRemoteOSX()<CR>

endif " }}}
" backups, swap and undo files {{{
" Save your backups
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif

set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup/
set backupdir^=./.vim-backup/
set backup

" Swap files
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif

set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" viminfo stores the the state of your previous editing session
set viminfo+=n~/.vim/viminfo

if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif
"  }}}
" remaps {{{
" clear the search buffer when hitting return
nnoremap <CR> :nohlsearch<CR>
nnoremap <leader>l :set list!<CR>

inoremap jk <ESC>
inoremap jj <ESC>
inoremap hh <ESC>
inoremap kk <ESC>

" magic search
nnoremap / /\v
nnoremap ? ?\v

" center next highlight
nnoremap n nzz
nnoremap N Nzz

" search the word selected in visual mode
xnoremap / y/\v<C-R>"<CR>


" space for toggle folding
nnoremap <Space> za
" space copy to select in visual
vnoremap <Space> y
" window movement
nnoremap <Down>    <C-w>j
nnoremap <Up>      <C-w>k
nnoremap <Left>    <C-w>h
nnoremap <Right>   <C-w>l

nnoremap <S-Down>  <C-w>J
nnoremap <S-Up>    <C-w>K
nnoremap <S-Left>  <C-w>H
nnoremap <S-Right> <C-w>L

nnoremap <leader>c gcc
nnoremap <silent> <leader><leader> :update<CR>

nnoremap <S-y> y$
" }}}
" functions {{{
function! SetupWrapping()
    set wrap
    set wrapmargin=0
    set textwidth=0
    set linebreak
    set nocursorline nocursorcolumn
    set nolist
    syntax off
endfun

function! StripTrailingWhitespaces()
  "prep: save last search, save cursor position
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the stripping
  %s/\s\+$//e
  "cleanup
  let @/=_s
  call cursor(l,c)
endfun

function! s:lightline_update()
  if !exists('g:loaded_lightline')
    return
  endif
  try
    call lightline#colorscheme()
  catch
  endtry
endfun

function! PrepareSpelling()
  setlocal spell spelllang=en_us,es_mx
  setlocal complete+=kspell
  syntax match dontspell /"[^"]\+"/ contains=@NoSpell
  syntax match dontspell /'[^']\+'/ contains=@NoSpell
  syntax match dontspell /_[^']\+_/ contains=@NoSpell
  syntax match dontspell /([^)]\+)/ contains=@NoSpell
  syntax match dontspell /{[^']\+}/ contains=@NoSpell
  syntax match dontspell /\[[^']\+\]/ contains=@NoSpell
  syntax match dontspell /\*[^']\+\*/ contains=@NoSpell
  syntax match dontspell /\v^\s{2,}[$#].*$/ contains=@NoSpell
  syntax region codeRegion matchgroup=codes start=/\v^\W{3,}$/ end=/\v^\W{3,}$/ contains=@NoSpell
endfun
" }}}
" misc {{{
" always show the status bar
if has("statusline") && !&cp
  set laststatus=2
endif

cabbrev W!! w !sudo tee %
" }}}
" plugins customizations {{{

"LIGHTLINE
"trying pure unicode instead of powerline
"
set noshowmode  " remove -- INSER -- line below"
"      \   'filename': expand("%")

let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly ? "✖︎" : ""}'
      \ },
      \ 'component_function': {
      \   'gitbranch': 'LightlineBranchName',
      \   'filename': 'RelativeFromHome'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '❯', 'right': '❮' }
\ }
fun! LightlineBranchName()
  return gitbranch#name() == '' ? '' : 'ᚠ ' . gitbranch#name()
endfun

fun! RelativeFromHome()
  return expand('%:~')
endfun


" vim-multiple-highlights setup
let g:mh_regex = '\v<\x{8}(-\x{4}){3}-\x{12}>'
" let g:uuid_guibg = 'Green'
" let g:uuid_ctermbg = 'White'
" let g:uuid_fgcolors = [ 'Red', 'White', 'Blue', 'Green','Black','DarkGray']
" }}}

let macvim_skip_colorscheme=1
let g:solarized_contrast = 'high'
colorscheme solarized8
