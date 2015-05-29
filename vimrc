" Guarantees that this file is only loaded once
if !exists("g:royalHimeVimrcLoaded") || g:royalHimeVimrcLoaded == 0

	""""""""""
	" Vundle "
	""""""""""
	" 1. Install Vundle with this command:
	" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	" 2. Run this command in vim
	" :PluginInstall

	set nocompatible              " be iMproved, required
	filetype off                  " required

	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()

		" let Vundle manage Vundle, required
		Plugin 'gmarik/Vundle.vim'

		Plugin 'kien/ctrlp.vim'
			let g:ctrlp_by_filename=1
			let g:ctrlp_match_window='order:ttb'
			let g:ctrlp_custom_ignore = {
			\ 'dir': 'node_modules',
			\ 'file': '.*\.class$'
			\ }
		Plugin 'tpope/vim-abolish'
		Plugin 'tpope/vim-commentary'
		Plugin 'Lokaltog/vim-easymotion'
		Plugin 'bling/vim-airline'

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	filetype plugin indent on    " required

	"""""""""""""
	" Load Once "
	"""""""""""""
	let g:royalHimeVimrcLoaded = 1

	""""""""""""
	" Settings "
	""""""""""""
	set autoindent
	set backspace=indent,eol,start
	set cursorline
	set hlsearch
	set ignorecase
	set incsearch
	set listchars=eol:$,tab:>-,precedes:<,extends:>
	set modeline
	set nowrap
	set number
	set rnu
	set showcmd
	set smartcase
	set smartindent
	set laststatus=2 " Always show status line
	set wildmode=longest,list

	syntax on

	"""""""""""""""""
	" Abbreviations "
	"""""""""""""""""
	abbr ftJS /* vim: set filetype=javascript : */
	abbr ftHtml <!-- vim: set filetype=html : -->

	""""""""""""
	" Commands "
	""""""""""""
	command! ClearSearch let @/=''

	command! WhitespaceHighlight normal /\s\+$<CR>
	command! WhitespaceCleanup %s/\s\+$//gc

	command! EditVimrc vnew ~/royal-neko/vimrc
	command! ReloadVimrc source ~/royal-neko/vimrc
	command! SaveAndReloadVimrc write | ReloadVimrc

	command! SimpleSave set nowritebackup|set noswapfile

	""""""""""""
	" Mappings "
	""""""""""""
	noremap <Leader>c :ClearSearch<CR>
	noremap <Leader>e :EditVimrc<CR>
	noremap <Leader>h :WhitespaceHighlight<CR>
	noremap <Leader>l :vnew .vimrc<CR>
	noremap <Leader>n :set invrelativenumber<CR>
	noremap <Leader>r :let g:royalHimeVimrcLoaded=0<CR>:SaveAndReloadVimrc<CR>
	noremap <Leader>s :!sort<CR>
	noremap <Leader>w :WhitespaceCleanup<CR>
	noremap <Leader>yw m`bye``
	noremap <Leader>yy m`0y$``
	noremap <Leader>YY m`^yg_``

	""""""""""""
	" Snippets "
	""""""""""""
	let snippet = {}
	let snippet['log'] = 'console.log(!!!);'
	let snippet['func'] = 'function(!!!) {!!!}'
	let snippet['Func'] = 'function(!!!) { !!! }'
	let snippet['des'] = 'describe("!!!", function() {!!!});'
	let snippet['it'] = 'it("!!!", function() {!!!});'
	let snippet['ex'] = 'expect(!!!).to.equal(!!!);'
	let snippet['each'] = '_.each(!!!, function(!!!) {!!!});'

	inoremap <Leader>r <Esc>vbcvar <C-R>" = require("<C-R>"");
	inoremap <Leader>q <Esc>vbc<C-O>m`<C-R>=snippet[@"]<CR><Esc>``/!!!<CR>:ClearSearch<CR>c3l
	inoremap <Leader><Tab> <Esc>/!!!<CR><Esc>:ClearSearch<CR>c3l

	""""""""""""""""
	" Local Config "
	""""""""""""""""
	let localVimrc = $HOME."/royal-neko/local/vimrc"
	if filereadable(localVimrc)
		exec "source ".localVimrc
	endif

	if filereadable(".vimrc")
		source .vimrc
	endif
endif
