# vim-format

vim plugin for misc formatting

## support format list
* cmake
* json
* python
* yaml
* toml
* sh,zsh
* rust
* nasm
* golang
* awk

### cmake - cmake_format
[umaumax/cmake\_format: Source code formatter for cmake listfiles\.]( https://github.com/umaumax/cmake_format )
``` bash
pip install https://github.com/umaumax/cmake_format/archive/master.tar.gz
```

### json - prettier, jq
prettier
``` bash
npm install -g prettier
```

jq
[Download jq]( https://stedolan.github.io/jq/download/ )
``` bash
# Mac OS X
brew install jq
# Ubuntu
sudo apt-get install jq
```

### python - autopep8
[hhatto/autopep8: A tool that automatically formats Python code to conform to the PEP 8 style guide\.]( https://github.com/hhatto/autopep8 )
``` bash
pip install autopep8
```

### yaml - prettier / yamlfmt / align-yaml
[gechr/yamlfmt: 📄 YAML file formatter]( https://github.com/gechr/yamlfmt )
``` bash
go get -u github.com/gechr/yamlfmt
```

[align\-yaml]( https://github.com/jonschlinkert/align-yaml )
``` bash
npm install -g align-yaml
```

### toml - prettier
``` bash
npm install prettier prettier-plugin-toml --save-dev --save-exact
```

### sh,zsh - shfmt
[mvdan/sh: A shell parser, formatter, and interpreter \(POSIX/Bash/mksh\)]( https://github.com/mvdan/sh )

### rust - rustfmt
``` bash
rustup component add rustfmt
```
`rustfmt`の仕様でファイル名を指定するとそのファイルを基準にして，各モジュールが適切に設定されているかを検査する

一時ファイルを利用してファイルを保存すると，そのときにエラーが発生してしまう

その一時ファイルを編集対象のファイルと同じディレクトリに配置すれば，その検査自体は問題ないが，
フォーマットされた結果が，stdoutに他のファイルの結果を含めて出力されてしまう問題がある

### nasm - nasmfmt
[yamnikov\-oleg/nasmfmt: Formatter for NASM source files]( https://github.com/yamnikov-oleg/nasmfmt )
``` bash
go get -u github.com/yamnikov-oleg/nasmfmt
```

### prettier for json, toml, yaml
``` bash
npm install prettier prettier-plugin-toml --save-dev --save-exact
```

### golang - gofmt

### awk - gawk

### lua - stylua
[JohnnyMorganz/StyLua: An opinionated Lua code formatter]( https://github.com/JohnnyMorganz/StyLua )

``` bash
cargo install stylua
```

----

## how to use
``` vim
Plug 'umaumax/vim-format'

let g:my_format_flag=1

" auto setting
let g:vim_format_fmt_on_save = 1
let g:Vim_format_pre_hook = { key, args -> g:my_format_flag }

" example of manual setting for json
let g:vim_format_fmt_on_save = 0
augroup json_group
  autocmd!
  autocmd FileType json autocmd BufWinEnter *.json command! -bar Format :JsonFormat
  autocmd FileType json autocmd BufWritePre *.json if g:my_format_flag | :JsonFormat | endif
  autocmd FileType json autocmd! json_group FileType
augroup END

" for original command
let g:vim_format_list={
  \ 'jenkins':{'autocmd':['*.groovy'],'cmds':[{'requirements':['goenkins-format'], 'shell':'cat {input_file} | goenkins-format'}]},
  \ }
```

The plugin will automatically define the commands with the following rules.

e.g.
* key is python: PythonFormat
* key is awk:    AwkFormat
