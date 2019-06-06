if exists('g:loaded_vim-format') || &cp
	finish
endif
let g:loaded_vim_format = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:vim_format_fmt_on_save")
	let g:vim_format_fmt_on_save = 0
endif

" TODO: add other file types
" NOTE: key must be same as FileType
let g:vim_format_list={
			\ 'json':{'autocmd':['*.json'],'cmds':[{'requirements':['jq'], 'shell':'cat {input_file} | jq .'}]}
			\ }

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

function! s:vim_format(key,args)
	let cmds_dict = g:vim_format_list[a:key]['cmds']
	let l:vim_format_cmd_format = ''
	for cmd_set in cmds_dict
		" TODO: cache cmd requirements result
		let cmds=cmd_set['requirements']
		let cmd_cnt=0
		for cmd in cmds
			if executable(cmd)
				let cmd_cnt=cmd_cnt+1
				break
			endif
		endfor
		if cmd_cnt!=len(cmds)
			continue
		endif
		let l:vim_format_cmd_format = cmd_set['shell']
	endfor
	if l:vim_format_cmd_format == ''
		echohl ErrorMsg
		echomsg 'Not found format command!'
		echomsg ''
		echohl None
		return
	endif

	" NOTE: write current buffer to tmporary file
	let tempfilepath=tempname()
	call writefile(getline(1, '$'), tempfilepath)

	" NOTE: build format command
	let sprintf_dict={
				\	'input_file':tempfilepath,
				\}
	let l:vim_format_full_cmd = l:vim_format_cmd_format
	for key in keys(sprintf_dict)
		let l:vim_format_full_cmd=substitute(l:vim_format_full_cmd,'{' . key . '}',sprintf_dict[key],'')
	endfor
	" NOTE: format
	" NOTE: output is stdout
	let l:vim_format_output = system(l:vim_format_full_cmd . ' ' . a:args)

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

augroup vim_format
	autocmd!
	for key in keys(g:vim_format_list)
		let upper_key = substitute(key, '\(\w\+\)', '\u\1', '')
		if get(g:, "vim_format_fmt_on_save", 1)
			execute printf('autocmd BufWritePre %s %sFormat', join(g:vim_format_list[key]['autocmd'],','), upper_key)
		endif
		" NOTE: decl command json -> JsonFormat
		execute printf('command! -bar -nargs=? %sFormat :call <SID>vim_format("%s",<q-args>)', upper_key, key)
	endfor
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
