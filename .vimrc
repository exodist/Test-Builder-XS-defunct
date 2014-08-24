:map  <F9>      :w<cr>:!perl ./Build.PL && ./Build && TT_IMPLEMENTATION=XS prove -Ilib -Iblib/arch -It/TraceTests -v %<CR>
:imap <F9> <ESC>:w<cr>:!perl ./Build.PL && ./Build && TT_IMPLEMENTATION=XS prove -Ilib -Iblib/arch -It/TraceTests -v %<CR>
