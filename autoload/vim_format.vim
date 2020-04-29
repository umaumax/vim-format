if !exists('g:loaded_vim_format')
  finish
endif
let g:loaded_vim_format = 1
let s:save_cpo = &cpo
set cpo&vim

function vim_format#check_health()
  let ng_cnt=0
  for key in keys(g:vim_format_list)
    if s:get_vim_format_cmd_format(key) == ""
      let ng_cnt+=1
    endif
  endfor
  if ng_cnt == 0
    echom '[OK]'
  endif
endfunction

" Ref: 'rhysd/vim-clang-format' /autoload/clang_format.vim
function! s:has_vimproc() abort
  if !exists('s:exists_vimproc')
    try
      silent call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction
function! s:success(result) abort
  let exit_success = (s:has_vimproc() ? vimproc#get_last_status() : v:shell_error) == 0
  return exit_success
endfunction

function! s:error_message(result) abort
  echohl ErrorMsg
  echomsg '[failed to format.]'
  for line in split(a:result, '\n')
    echomsg line
  endfor
  echomsg ''
  echohl None
endfunction

function! s:get_vim_format_cmd_format(key, ...)
  let l:verbose=get(a:, 1, 1)
  let cmds_dict = g:vim_format_list[a:key]['cmds']
  for cmd_set in cmds_dict
    " FIX: cache cmd requirements result?
    " depend on invalid or valid for newly install comand which was not found
    let not_found_cmds=filter(cmd_set['requirements'], {-> !executable(v:val)})
    if !empty(not_found_cmds)
      if l:verbose
        echohl ErrorMsg
        echomsg "Not found format command [".join(not_found_cmds ,' ')."]"
        echomsg ''
        echohl None
      endif
      return
    endif
    return cmd_set
  endfor
  return []
endfunction

function! vim_format#format(key, args)
  let l:vim_format_cmd_format = s:get_vim_format_cmd_format(a:key)
  if empty(l:vim_format_cmd_format)
    return
  endif

  " NOTE: write current buffer to tmporary file
  let tempfilepath=tempname()
  " NOTE: rustfmt use input filepath, so you must use same directory of target file
  " if a:key == 'rust'
  " let tempfilepath = expand('%:p:h').'/.vim_format.tmp.'.expand('%:t')
  " endif
  call writefile(getline(1, '$'), tempfilepath)

  " NOTE: build format command
  let sprintf_dict={
        \ 'input_file': tempfilepath,
        \ 'args': len(a:args)==0 ? get(l:vim_format_cmd_format, 'default_args', '') : a:args,
        \}
  let l:vim_format_full_cmd = l:vim_format_cmd_format['shell']
  for key in keys(sprintf_dict)
    let l:vim_format_full_cmd=substitute(l:vim_format_full_cmd,'{' . key . '}',sprintf_dict[key], 'g')
  endfor
  " NOTE: format
  " NOTE: output is stdout
  let l:vim_format_output = system(l:vim_format_full_cmd)

  call delete(tempfilepath)

  if s:success(l:vim_format_output)
    let pos_save = a:0 >= 1 ? a:1 : getpos('.')
    let winview = winsaveview()
    let splitted = split(l:vim_format_output, '\n')
    silent! undojoin
    if line('$') > len(splitted)
      execute len(splitted) .',$delete' '_'
    endif
    call setline(1, splitted)
    call winrestview(winview)
    call setpos('.', pos_save)
  else
    call s:error_message(l:vim_format_output)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
