let s:linters = {}
let s:empty_dict = {}

" Escape a single errorformat string, by escaping commas, and then escaping
" spaces, commas and backslashes. The result should be useable when setting
" errorformat strings:
" 	let errorformat = "%f: line %l, col %c, %m"
" 	execute "set errorformat=" . s:EscapeErrorFormat(errorformat)
function s:EscapeErrorFormat(string)
	let l:string = a:string
	let l:string = substitute(l:string, ',', '\\,', 'g')
	let l:string = substitute(l:string, '[\\, ]', '\\\0', 'g')
	return l:string
endfunction

" Escape a list of errorformat strings, joining them with a comma. The result
" will be useable when setting errorformat strings:
" 	let errorformats = ["%f: line %l, col %c, %m", "%f: line %l, %m"]
" 	execute "set errorformat=" . s:EscapeErrorFormats(errorformats)
function s:EscapeErrorFormats(strings)
	return join(map(a:strings, 's:EscapeErrorFormat(v:val)'), ',')
endfunction

" Run the linter for the current buffer, if there is one defined.
function s:RunLinter()
	" Get buffers filetype
	let l:filetype = &ft

	let l:linter = get(s:linters, l:filetype, s:empty_dict)
	if l:linter == s:empty_dict
		return
	endif

	let l:this_file = expand("%:p")
	let l:temp_file = tempname()
	let l:cmd = printf(l:linter['linter'], shellescape(l:this_file), shellescape(l:temp_file))

	silent execute "!" . l:cmd

	if v:shell_error
		set errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m
		execute 'set errorformat=' . linter['errorformat']
		copen
		execute "cgetfile " . l:temp_file
	else
		cclose
	endif

endfunction

" Define a new linter for a filetype
"
" Parameters:
"   filetype - The filetype this linter is used for
"   linter - The command to invoke. This must contain two "%s" placeholders.
"     The first is replaced with the full file path of the file being linted,
"     and the second is replaced with the output file for any errors. The
"     command can contain shell pipes and redirects, such as
"         mylinter --foo --input=%s | frobnicat > %s
"   errorformats - The errorformat strings to use. This should be a list of
"   all the different formats to use. The entries should not be escaped - the
"   escaping will be done automatically.
" 
" Example:
" 	call s:DefineLinter("foo", "foolint --input %s 2> %s", [
" 	\	"%f:%l:%c: %m",
" 	\	"%f:%l: %m"
" 	\])
function! s:DefineLinter(filetype, linter, errorformats)
	let l:errorformat_string = s:EscapeErrorFormats(a:errorformats)
	let s:linters[a:filetype] = {'linter': a:linter, 'errorformat': l:errorformat_string, }
endfunction

" Expose the DefineLinter() function for external use. Has the same
" parameters.
function! linters#define(filetype, linter, errorformats)
	call DefineLinter(a:filetype, a:linter, a:errorformats)
endfunction

function! linters#run()
	call s:RunLinter()
endfunction

" jshint integration for linting JavaScript
if executable("jshint")
	call s:DefineLinter("javascript", "jshint %s > %s", ['%f: line %l, col %c, %m'])
endif

" LessCSS compiling using lessc and /dev/null
if executable("lessc")
	call s:DefineLinter("less", "lessc --no-color %s /dev/null 2> %s", ['%m in %f:%l:%c'])
endif

if executable("pylint")
	call s:DefineLinter('python', "pylint %s > %s 2>/dev/null", [
	\	"%t:  %l,%c: %m",
	\	"%t: %l,%c: %m",
	\	"%t:%l,%c: %m",
	\])
endif

if executable("pyflakes")
	call s:DefineLinter('python', "pyflakes %s > %s", ["%f:%l: %m"])
endif

if executable("hlint")
	call s:DefineLinter('haskell', 'hlint %s > %s', ['%f:%l:%c: %m'])
endif

au BufWritePost * call s:RunLinter()
