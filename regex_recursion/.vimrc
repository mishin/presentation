" This .vimrc file was created by Vroom-0.37
set nocompatible
syntax on

map <SPACE> :n<CR>:<CR>gg
map <BACKSPACE> :N<CR>:<CR>gg
map R :!vroom -run %<CR>
map RR :!vroom -run %<CR>
map AA :call RunNow()<CR>:<CR>
map VV :!vroom -vroom<CR>
map QQ :q!<CR>
map OO :!open <cWORD><CR><CR>
map EE :e <cWORD><CR>
map !! G:!open <cWORD><CR><CR>
map ?? :e .help<CR>
set laststatus=2
set statusline=%-20f\ Recursion\ in\ Regex!

" Overrides from /home/mishin/.vroom/vimrc


" Values from slides.vroom config section. (under 'vimrc')
set statusline=%-3f\ \ \ \ \ Recursioni\ in\ Regex\ (or:\ How\ parse\ IBM\ Datastage\ dsx\ file)
map <C-C> 3<C-^><Ctrl-Home>
map <C-O> 2<C-^><Ctrl-Home>
map <C-E> 5<C-^><Ctrl-Home>
map <C-P> 11<C-^><Ctrl-Home>
map MSM ouse Method::Signatures::Modifiers;<Esc>

