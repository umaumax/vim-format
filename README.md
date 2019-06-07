# vim-format

vim plugin for json formatting

## support format list
* json

### json - jq
[Download jq]( https://stedolan.github.io/jq/download/ )
```
# Mac OS X
brew install jq
# Ubuntu
sudo apt-get install jq
```

## how to use
```
Plug 'umaumax/vim-format'

# auto
let g:vim_format_fmt_on_save = 1

# manual
let g:format_flag=1
augroup json_group
  autocmd!
  autocmd FileType json autocmd BufWinEnter *.json command! -bar Format :JsonFormat
  autocmd FileType json autocmd BufWritePre *.json if g:format_flag | :JsonFormat | endif
  autocmd FileType json autocmd! json_group FileType
augroup END
```
