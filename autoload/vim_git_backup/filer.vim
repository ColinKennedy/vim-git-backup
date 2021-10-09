let g:_safe_character = ''


" Check if `text` is an absolute Windows file system path.
"
" Args:
"     text (str): A file or folder on-disk, e.g. "C:\foo.txt".
"
" Returns:
"     bool: If `text` comes from windows, return True. e.g. True.
"
function! s:has_drive(text)
    let l:match = matchstr(a:text, "^[A-Z]:")

    return !empty(l:match)
endfunction


" Remove a leading Windows drive letter, if any.
"
" Args:
"     text (str): A file or folder on-disk, e.g. "C:\foo.txt".
"
" Returns:
"     str: The simplified path. e.g. "C\foo.txt".
"
function! s:substitute_drive(text)
    if !has('win32')
        return a:text
    endif

    if !s:has_drive(a:text)
        return a:text
    endif

    return substitute(a:text, ":", g:_safe_character, 'g')
endfunction


" Copy `file` into `backup_directory`.
"
" Args:
"     file (str): The absolute path to a file or folder.
"     file_lines (list[str]): The source code lines of `file`.
"     backup_directory (str): The absolute directory to a folder on-disk to copy into.
"
function! vim_git_backup#filer#copy(file, file_lines, backup_directory)
    let l:file = s:substitute_drive(a:file)

    if l:file == a:backup_directory
        " Prevent a file from overwriting the backup directory
        echoerr 'Cannot copy "' . l:file . '" into "' . a:backup_directory . '"'

        return
    endif

    let l:current_file_path = s:substitute_drive(expand('%:p:h'))

    if l:file != a:file
        let l:file = '\' . l:file
        let l:current_file_path = '\' . l:current_file_path
    endif

    let l:directory = a:backup_directory . l:current_file_path
    let l:backup_file = a:backup_directory . l:file
    let l:full_directory = expand(l:directory)

    if !isdirectory(l:full_directory)
        call mkdir(l:full_directory, "p")
    endif

    " Copy `l:file` to `l:backup_file`
    call writefile(a:file_lines, l:backup_file, "b")
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
        return s:substitute_drive(a:path)
    endif

    return substitute(a:path, "^/", "", "")
endfunction
