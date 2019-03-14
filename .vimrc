set nocompatible                " required
filetype off                    " required

""" Settings
filetype plugin indent on   " required

set tabstop=4               " Show existing tab with 4 spaces width
set shiftwidth=4            " When indenting with '>', use 4 spaces width
set expandtab               " On pressing tab, insert 4 spaces
set encoding=utf-8
set showmatch               " Show matching brackets
let python_highlight_all=1  " Make code pretty

" colorscheme badwolf       " colorscheme -- overrides terminal transparency
set showcmd                 " highlight current line
" set cursorline              " highlight current line
set number                  " Enable Line Numbers
set relativenumber          " Enable Relative Line Numbers
set wildmenu                " Visual autocomplete for command menu
set incsearch               " search as chars are entered
set hlsearch                " highlight all matches
set lazyredraw              " redraw only when we need to

syntax on
set mouse=a         " Mouse Mode On
" Flag unnecessary whitespace
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py match BadWhitespace /\s\+$/

" Folding
set foldenable
set foldmethod=indent
set foldlevel=99


""" Keybinds
let mapleader = "\<Space>"   " Remap leader to Spacebar.
" Set j/k to move by virtual line, instead of actual line
" but w/ a number still uses phys lines.
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
" Make Y yank from cursor to end of line (instead of duplicating yy)
noremap Y y$
" Stay in visual mode when indenting
" vnoremap < <gv                
" vnoremap > >gv
" Make Ctrl-e jump to end of current line in insert mode.
inoremap <C-e> <C-o>$
" In command mode, %% = current dir
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'?' : '%%'
" Set Tab navigation
map <leader>h gT
map <leader>l gt
map <leader>1 1gt
map <leader>2 2gt
map <leader>3 3gt
map <leader>4 4gt
map <leader>5 5gt
map <leader>6 6gt
map <leader>7 7gt
map <leader>8 8gt
map <leader>9 9gt
map <leader>0 10gt
nnoremap <C-Right> gt
nnoremap <C-Left> gT
nnoremap <F2> gt
nnoremap <F3> gT

" View diff from current to last save
" :w !diff % -

""" Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
" call vundle@begin('~/some/path/here')

" Instead of using Vundle, we can just put plugins at 
" ~/.vim/pack/pluginfoldername/start/<pluginname>
" and they will be grabbed at startup.

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
    
" add all you plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

Plugin 'tmhedberg/SimpylFold'           " Better Python Folding
Plugin 'Konfekt/FastFold'               " Default Vim Folding is v slow.
Plugin 'vim-scripts/indentpython.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
" Plugin 'scrooloose/nerdtree'
Plugin 'ctrlpvim/ctrlp.vim'             " Ctrl+P to search everything
Plugin 'tpope/vim-fugitive'
" Plugin 'Lokaltog/powerline', {'rtp':'powerline/bindings/vim/'}
Plugin 'plytophogy/vim-virtualenv'
" Plugin 'easymotion/vim-easymotion'
Plugin 'tomtom/tcomment_vim'            " Commenting support by filetype. gc{motion} to toggle comments. gcc for current line.
Plugin 'michaeljsmith/vim-indent-object'    " Selection based on indent levels
Plugin 'FooSoft/vim-argwrap'
" All of your plugins must be added before the following line
call vundle#end()           " required


""" Plugin Settings



" enable below to load filetype-specific indent files
" i.e. *.py will follow ~/.vim/indent/python.vim formatting
" filetype indent on

" Proper PEP8 indentation
au BufNewFile,BufRead *.py;
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix
au BufNewFile,BufRead *.yaml;
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix


" Auto-complete
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>


" Nerdtree
let NERDTreeIgnore=['\.pyc$', '\~$'] " ignore files in NERDTree
map <C-n> :NERDTreeToggle<CR>   " command to open NERDTree
" exit vim if NERDTree is only window open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Ctrl-p
let g:ctrlp_map = '<c-p>'       " map ctrlp

" Wrap Args
noremap <silent> <leader>a :ArgWrap<CR>
let g:argwrap_wrap_closing_brace = 0

