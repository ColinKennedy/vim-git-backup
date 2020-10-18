" Run a command in the terminal and return a list of strings, showing its output.
"
" Args:
"     command (str): The command to run.
"
" Returns:
"     list[str]: The found command output.
"
function! s:systemlist(command)
    return split(system(a:command, nr2char(10)))
endfunction


" Copy `file` into `backup_directory`.
"
" Args:
"     file (str): The absolute path to a file or folder.
"     backup_directory (str): The absolute directory to a folder on-disk to copy into.
"
function! vim_git_backup#filer#copy(file, backup_directory)
    if a:file == a:backup_directory
        " Prevent a file from overwriting the backup directory
        echoerr 'Cannot copy "' . a:file . '" into "' . a:backup_directory . '"'

        return
    endif

    let l:directory = a:backup_directory . expand('%:p:h')
    let l:backup_file = a:backup_directory . a:file
    let l:full_directory = expand(l:directory)

    if !isdirectory(l:full_directory)
        call mkdir(l:full_directory, "p")
    endif

    " Copy `a:file` to `l:backup_file`
    call writefile(readfile(a:file), l:backup_file, "w")
endfunction


" Get the lines which differ between `old` and `new`.
"
" Args:
"     old (str): The absolute file path to an older version of a file.
"     new (str): The absolute file path to an newer version of the same file.
"
" Returns:
"     list[str]: The found diff, if any.
"
function! vim_git_backup#filer#get_line_diff(old, new)
    " Reference: https://stackoverflow.com/questions/1566461/how-to-count-differences-between-two-files-on-linux#comment51008286_2479947
    let l:output = s:systemlist('diff -U 0 "' . a:old . '" "' . a:new . '" | grep -v ^@ | tail -n +3 | wc -l')[0]
    return l:output
endfunction


" Change an absolute path like "/foo/bar.txt into a relative path, such as "foo/bar.txt".
"
" We need this in several places in order for backup files to be copied
" and queried correctly.
"
" Args:
"     path (str): The absolute path to convert.
"
" Returns:
"     str: The relative path.
"
function! vim_git_backup#filer#strip_mount(path)
    if has("win32")
        return substitute(a:path, "^[A-Z]:\\", "", "")
    endif

    return substitute(a:path, "^/", "", "")
endfunction
