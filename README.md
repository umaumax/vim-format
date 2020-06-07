# vim-format

vim plugin for misc formatting

## support format list
* json
* cmake
* yaml
* sh,zsh

### cmake - cmake_format
[umaumax/cmake\_format: Source code formatter for cmake listfiles\.]( https://github.com/umaumax/cmake_format )
```
pip install https://github.com/umaumax/cmake_format/archive/master.tar.gz
```

### json - jq
[Download jq]( https://stedolan.github.io/jq/download/ )
```
# Mac OS X
brew install jq
# Ubuntu
sudo apt-get install jq
```

### python - autopep8
[hhatto/autopep8: A tool that automatically formats Python code to conform to the PEP 8 style guide\.]( https://github.com/hhatto/autopep8 )
```
pip install autopep8
```

### yaml - align-yaml
[align\-yaml]( https://github.com/jonschlinkert/align-yaml )
```
npm install -g align-yaml
```

### sh,zsh - shfmt
[mvdan/sh: A shell parser, formatter, and interpreter \(POSIX/Bash/mksh\)]( https://github.com/mvdan/sh )

### rust - rustfmt
```
rustup component add rustfmt
```
`rustfmt`の仕様でファイル名を指定するとそのファイルを基準にして，各モジュールが適切に設定されているかを検査する

一時ファイルを利用してファイルを保存すると，そのときにエラーが発生してしまう

その一時ファイルを編集対象のファイルと同じディレクトリに配置すれば，その検査自体は問題ないが，
フォーマットされた結果が，stdoutに他のファイルの結果を含めて出力されてしまう問題がある

### nasm - nasmfmt
[yamnikov\-oleg/nasmfmt: Formatter for NASM source files]( https://github.com/yamnikov-oleg/nasmfmt )
```
go get -u github.com/yamnikov-oleg/nasmfmt
```

----

## how to use
```
Plug 'umaumax/vim-format'

" auto
let g:vim_format_fmt_on_save = 1

" manual
let g:format_flag=1
augroup json_group
  autocmd!
  autocmd FileType json autocmd BufWinEnter *.json command! -bar Format :JsonFormat
  autocmd FileType json autocmd BufWritePre *.json if g:format_flag | :JsonFormat | endif
  autocmd FileType json autocmd! json_group FileType
augroup END

" for original command
let g:vim_format_list={
  \ 'jenkins':{'autocmd':['*.groovy'],'cmds':[{'requirements':['goenkins-format'], 'shell':'cat {input_file} | goenkins-format'}]},
  \ }
```
