source $VIMRUNTIME/defaults.vim

colorscheme one
set background=light

" Set airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = "unique_tail_improved"
let g:airline_powerline_fonts = 1

" Set option
set autoindent
set autoread
set backspace=indent,eol,start
set nobackup
set breakindent
set breakindentopt=sbr
set showbreak=↪
set cdhome
set cmdheight=1
set completeopt=fuzzy,menuone,noselect,popup
set concealcursor=v
set confirm
set cursorline
set cursorlineopt=number,screenline
set diffopt=algorithm:minimal,closeoff,context:20,followwrap,internal,linematch:40
set errorbells
set expandtab
set exrc
set foldcolumn=0
set fsync
set nogdefault
set helplang=zh,en
set history=10000
set hlsearch
set ignorecase
set smartcase
set list
set listchars=tab:--→,trail:·,multispace:\ ,nbsp:⍽,space:·
set magic
set more
set mouse=a
set number
set numberwidth=4
set relativenumber
set scrolloff=5
set shiftround
set shiftwidth=2
set noshowmode
set signcolumn=yes
set smoothscroll
set splitbelow
set splitright
set startofline
set noswapfile
set tabclose=uselast
set tabstop=2
set termguicolors
set undofile
set undolevels=100000
set virtualedit=block,onemore
set whichwrap=b,s,\<,\>
set wildmenu
set wildmode=full
set wildoptions=fuzzy,pum
set wrap
