" @author nate zhou
" @since 2023
" hyper.vim is a color scheme based on ron.vim

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "hyper"
hi Normal		guifg=cyan	guibg=black
hi NonText		guifg=yellow guibg=#303030
hi comment		guifg=green
hi constant		guifg=cyan	gui=bold
hi identifier	guifg=cyan	gui=NONE
hi statement	guifg=lightblue	gui=NONE
hi preproc		guifg=Pink2
hi type			guifg=seagreen	gui=bold
hi special		guifg=yellow
hi ErrorMsg		guifg=Black	guibg=Red
hi WarningMsg	guifg=Black	guibg=Green
hi Error		guibg=Red
hi Todo			guifg=Black	guibg=orange
hi Cursor		guibg=#60a060 guifg=#00ff00
hi Search		guibg=darkgray guifg=black gui=bold 
hi IncSearch	gui=NONE guibg=steelblue
hi LineNr		cterm=bold ctermfg=darkgrey guifg=darkgrey
hi title		guifg=darkgrey
hi ShowMarksHL ctermfg=cyan ctermbg=lightblue cterm=bold guifg=yellow guibg=black  gui=bold
hi label		guifg=gold2
hi operator		guifg=orange
hi clear Visual
hi Visual		term=reverse cterm=reverse gui=reverse
hi DiffChange   guibg=darkgreen
hi DiffText		guibg=olivedrab
hi DiffAdd		guibg=slateblue
hi DiffDelete   guibg=coral
hi Folded		guibg=gray30
hi FoldColumn	guibg=gray30 guifg=white
hi cIf0			guifg=gray
hi diffOnly	    guifg=red gui=bold

" column color from `set cc=80`
hi ColorColumn  ctermbg=blue

" current line number
hi CursorLine cterm=bold
hi CursorLineNr cterm=bold ctermfg=yellow

" status line of not current focused window (split)
hi StatusLineNC	gui=NONE    guifg=lightblue guibg=darkblue
" status line of current window
hi StatusLine	gui=bold    ctermbg=white ctermfg=blue	guifg=cyan	guibg=blue
