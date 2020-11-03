"	VIM SETTINGS: {{{3
"	VIM: let g:mldvp_filecmd_open_tagbar=0 g:mldvp_filecmd_NavHeadings="" g:mldvp_filecmd_NavSubHeadings="" g:mldvp_filecmd_NavDTS=0 g:mldvp_filecmd_vimgpgSave_gotoRecent=0
"	vim: set tabstop=4 modeline modelines=10 foldmethod=marker:
"	vim: set foldlevel=2 foldcolumn=3: 
"	}}}1
let s:self_name = "mld_vim_vimh_vi"
let s:self_printdebug=0
let s:path_log_stderr = printf("/tmp/.stderr.%s.log", s:self_name)
let g:vimh_loaded = 1
"	Ongoing: 2020-10-21T18:50:52AEDT Support for windows paths?
let s:home_dir = substitute(shellescape(fnamemodify('~', ':p')), "'", "", "g") 

"	Log file location:
let s:path_vimh_log = s:home_dir . ".vimh"

"	Delimitor of log columns
let s:vimh_delim = "\t"

let s:vimh_format_iso_datetime = "%Y-%m-%dT%H:%M:%S%Z"
let s:vimh_hostname = system("echo -n $HOST")

"	vimh_vi log columns: 
"		Delimitor = \t
"		column 1:	isodatetime, nearest second
"		column 2: 	filename
"		column 3: 	host
"		column 4:	action
"		column 5: 	filepath

"	{{{2

let s:currentopenfile_name = ""
let s:path_currentfile = ""

if (expand('%:t') == "vimh.vi.txt")
	if (s:self_printdebug == 1)
		echo printf("%s, Read logfile, set nowrap", s:self_name)
	endif
	exe "set nowrap"
endif

"	Labeled: 2020-10-22T16:23:34AEDT 
function! s:Update_Log(action)
"	{{{
	if (s:self_printdebug == 1)
		echo printf("Update Log Begin")
	endif

	let path_curfile = ""
	let temp_currentopenfile_name = expand('%:t')
	let temp_path_currentfile = expand('%:p')
	if (temp_path_currentfile != s:path_currentfile) || (temp_currentopenfile_name != s:currentopenfile_name)
		"let s:qvar_currentfile = g:QReader_CurrentFile_Var()
		let s:currentopenfile_name = temp_currentopenfile_name
		let s:path_currentfile = temp_path_currentfile
	endif

	if (s:path_currentfile == s:path_vimh_log)
		if (s:self_printdebug)
			echo printf("skip, s:path_currentfile == s:path_vimh_log")
		endif
		return
	endif

	let current_action_str = a:action
	if (len(current_action_str) == 0)
		current_action_str = "None"
	endif

	if (len(s:currentopenfile_name) == 0)
		if (s:self_printdebug == 1)
			echo printf("skip, currentopenfile_name=(%s)", s:currentopenfile_name)
		endif
		return 0
	endif

	let delim = s:vimh_delim

	let current_datetime_str = ""
	let current_datetime_str = strftime(s:vimh_format_iso_datetime)
	
	let log_output_str = current_datetime_str . delim . s:currentopenfile_name . delim . s:vimh_hostname . delim . current_action_str . delim . s:path_currentfile

	if (s:self_printdebug)
		echo printf("log_output_str=(%s)", log_output_str)
	endif

	call writefile( [log_output_str], s:path_vimh_log, "a")

endfunction
"	}}}

command! VimhLogWrite call s:Update_Log("BufWritePost")
command! VimhLogEnter call s:Update_Log("VimEnter")
command! VimhLogRead call s:Update_Log("BufReadPre")
command! VimhLogQuit call s:Update_Log("VimLeave")

autocmd! BufWritePost * VimhLogWrite
autocmd! BufReadPre * VimhLogRead
autocmd! VimLeave * VimhLogQuit
autocmd! VimEnter * VimhLogEnter

"	}}}1

