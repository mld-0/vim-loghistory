"	vim: set tabstop=4 modeline modelines=10:
"	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker: 
"	{{{2
let g:vimh_version = "0.1"

"	TODO: 2022-06-05T19:57:19AEST vim-loghistory, get realpath (readlink -f) of file name/path (and use that)

let s:flag_printdebug = 0

let s:self_name = "vim-loghistory"
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

"	Ongoing: 2022-06-08T03:44:58AEST added 'realpath' as 6th column
"	vimh_vi log columns: 
"		Delimitor = \t
"		column 1:	isodatetime, nearest second
"		column 2: 	filename
"		column 3: 	host
"		column 4:	action
"		column 5: 	filepath
"		column 6:	realpath

let s:currentopenfile_name = ""
let s:path_currentfile = ""
let s:realpath_currentfile = ""

if (expand('%:t') == "vimh.vi.txt")
	if (s:flag_printdebug == 1)
		echo printf("%s, Read logfile, set nowrap", s:self_name)
	endif
	exe "set nowrap"
endif

"	Labeled: 2020-10-22T16:23:34AEDT 
function! s:Update_Log(action)
"	{{{
	if (s:flag_printdebug == 1)
		echo printf("Update Log Begin")
	endif

	let path_curfile = ""

	let temp_currentopenfile_name = expand('%:t')
	let temp_path_currentfile = expand('%:p')
	let s:currentopenfile_name = substitute(temp_currentopenfile_name, "[[:cntrl:]]", "", "g")
	let s:path_currentfile = substitute(temp_path_currentfile, "[[:cntrl:]]", "", "g")

	"if (temp_path_currentfile != s:path_currentfile) || (temp_currentopenfile_name != s:currentopenfile_name)
		"let s:qvar_currentfile = g:QReader_CurrentFile_Var()
		"let s:currentopenfile_name = substitute(temp_currentopenfile_name, "[[:cntrl:]]", "", "g")
		"let s:path_currentfile = substitute(temp_path_currentfile, "[[:cntrl:]]", "", "g")
		"if (s:path_currentfile != temp_path_currentfile)
		"	echoerr printf("%s, file path=(%s), contains control characters '[[:cntrl:]]', removed before logging", s:self_name, temp_path_currentfile)
		"endif
	"endif


	let temp_realpath_currentfile = ""
	if (len(temp_path_currentfile) > 0)
		let cmd_str = "readlink -f '" . temp_path_currentfile . "'"

		if (s:flag_printdebug)
			echo "cmd_str=(" . cmd_str . ")"
		endif

		let temp_realpath_currentfile = system(cmd_str)

		if (s:flag_printdebug)
			echo "temp_realpath_currentfile=(" . temp_realpath_currentfile . ")"
		endif

	endif

	if (s:flag_printdebug) 
		echo "s:realpath_currentfile=(" . s:realpath_currentfile . ")"
	endif

	let s:realpath_currentfile = substitute(temp_realpath_currentfile, "[[:cntrl:]]", "", "g")

	if (s:flag_printdebug)
		echo "s:realpath_currentfile=(" . s:realpath_currentfile . ")"
	endif


	if (s:path_currentfile == s:path_vimh_log)
		if (s:flag_printdebug)
			echo printf("skip, s:path_currentfile == s:path_vimh_log")
		endif
		return
	endif

	let current_action_str = a:action
	if (len(current_action_str) == 0)
		current_action_str = "None"
	endif

	if (len(s:currentopenfile_name) == 0)
		if (s:flag_printdebug == 1)
			echo printf("skip, currentopenfile_name=(%s)", s:currentopenfile_name)
		endif
		return 0
	endif

	let delim = s:vimh_delim

	let current_datetime_str = ""
	let current_datetime_str = strftime(s:vimh_format_iso_datetime)
	
	"let log_output_str = current_datetime_str . delim . s:currentopenfile_name . delim . s:vimh_hostname . delim . current_action_str . delim . s:path_currentfile
	let log_output_str = current_datetime_str . delim . s:currentopenfile_name . delim . s:vimh_hostname . delim . current_action_str . delim . s:path_currentfile . delim . s:realpath_currentfile

	if (s:flag_printdebug)
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


