function! s:systemlist(command)
    return split(system(a:command, nr2char(10)))
endfunction


function! vim_git_backup#filer#copy(file, backup_directory)
    if a:file == a:backup_directory
        " Prevent a file from overwriting the backup directory
        return
    endif

    let l:directory = a:backup_directory . expand('%:p:h')
    let l:backup_file = a:backup_directory . a:file
    let l:full_directory = expand(l:directory)

    if !isdirectory(l:full_directory)
        call mkdir(l:full_directory, "p")
    endif

    " TODO : Make this work, cross-platform
    call system('cp ' . a:file . ' ' . l:backup_file)
endfunction


function! vim_git_backup#filer#get_line_diff(old, new)
    " Reference: https://stackoverflow.com/questions/1566461/how-to-count-differences-between-two-files-on-linux#comment51008286_2479947
    let l:output = s:systemlist('diff -U 0 "' . a:old . '" "' . a:new . '" | grep -v ^@ | tail -n +3 | wc -l')[0]
    return l:output
endfunction


function! vim_git_backup#filer#strip_mount(path)
    if has("win32")
        return substitute(a:path, "^[A-Z]:\\", "", "")
    endif

    return substitute(a:path, "^/", "", "")
endfunction
