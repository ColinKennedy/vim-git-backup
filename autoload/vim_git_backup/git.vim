function! vim_git_backup#git#add_tag(path)
    call vim_git_backup#git_helper#GetRemote(g:custom_backup_dir, 'add ' . a:path)
endfunction


function! vim_git_backup#git#add_tag(tag)
    return vim_git_backup#git_helper#GetRemote(g:custom_backup_dir, 'tag ' . a:tag)
endfunction


function! vim_git_backup#git#commit(message)
    return vim_git_backup#git_helper#GetRemote(g:custom_backup_dir, 'commit -m "' . message '"')
endfunction


function! vim_git_backup#git#init(directory)
    call system(vim_git_backup#git_helper#GetRemote(a:directory, 'init'))
endfunction


function! vim_git_backup#git#add_note(message)
    return vim_git_backup#git_helper#GetRemote(g:custom_backup_dir, 'nodes add -m "' . message . '"')
endfunction
