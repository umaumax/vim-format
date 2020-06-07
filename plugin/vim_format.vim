if exists('g:loaded_vim_format')
  finish
endif
let g:loaded_vim_format = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists("g:vim_format_fmt_on_save")
  let g:vim_format_fmt_on_save = 0
endif

" NOTE: key must be same as FileType
" set below values as python format style
" * {input_file}
let s:default_vim_format_list={
      \ 'json':   { 'autocmd-filename': ['*.json'],                                                     'cmds': [{'requirements': ['jq'],           'shell': 'cat {input_file} | jq {args}', 'default_args':'.'}]},
      \ 'cmake':  { 'autocmd-filename': ['*.cmake','CMakeLists.txt'],                                   'cmds': [{'requirements': ['cmake-format'], 'shell': 'cmake-format {args} {input_file}'}]},
      \ 'python': { 'autocmd-filename': ['*.{py}'],                                                     'cmds': [{'requirements': ['autopep8'],     'shell': 'autopep8 {args} {input_file}'}]},
      \ 'yaml':   { 'autocmd-filename': ['*.{yaml,yml}'],                                               'cmds': [{'requirements': ['align'],        'shell': 'align {args} {input_file} > /dev/null && cat {input_file}'}]},
      \ 'sh':     { 'autocmd-filename': ['*.{sh,bashrc,bashenv,bash_profile}','profile','environment'], 'cmds': [{'requirements': ['shfmt'],        'shell': 'cat {input_file} | shfmt {args}', 'default_args': '-i 2 -ci -bn'}]},
      \ 'zsh':    { 'autocmd-filename': ['*.{zsh,zshrc,zshenv,zprofile}'],                              'cmds': [{'requirements': ['shfmt'],        'shell': 'cat {input_file} | shfmt {args}', 'default_args': '-i 2 -ci -bn'}]},
      \ 'rust':   { 'autocmd-filename': ['*.{rs}'],                                                     'cmds': [{'requirements': ['rustfmt'],      'shell': 'cat {input_file} | rustfmt {args} --emit stdout --'}]},
      \ 'nasm':   { 'autocmd-filetype': ['nasm'],                                                       'cmds': [{'requirements': ['nasmfmt'],      'shell': 'nasmfmt -ii 4 {input_file} && cat {input_file}'}]},
      \ }
let g:vim_format_list=extend(copy(s:default_vim_format_list), get(g:, "vim_format_list", {}))

augroup vim_format
  autocmd!
  for key in keys(g:vim_format_list)
    let upper_key = substitute(key, '\(\w\+\)', '\u\1', '')
    if get(g:, "vim_format_fmt_on_save", 1)
      let setting=g:vim_format_list[key]
      if has_key(setting, 'autocmd-filename')
        execute printf('autocmd BufWritePre %s %sFormat', join(setting['autocmd-filename'],','), upper_key)
      endif
      if has_key(setting, 'autocmd-filetype')
        execute printf("autocmd BufWritePre * if &ft =~ '%s' | %sFormat | endif", join(setting['autocmd-filetype'],'|'), upper_key)
      endif
    endif
    " NOTE: e.g. decl command json -> JsonFormat
    execute printf('command! -bar -nargs=? %sFormat :call vim_format#format("%s",<q-args>)', upper_key, key)
  endfor
augroup END

command! VimFormatCheckHealth :call vim_format#check_health()

let &cpo = s:save_cpo
unlet s:save_cpo
