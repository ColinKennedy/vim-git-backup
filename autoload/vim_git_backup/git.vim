function! vim_git_backup#git#add(path)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'add ' . a:path)
endfunction


function! vim_git_backup#git#add_tag(tag)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'tag ' . a:tag)
endfunction


function! vim_git_backup#git#commit(message)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'commit -m "' . a:message . '"')
endfunction


" TODO : Add check to make sure this runs
function! vim_git_backup#git#init(directory)
    call system(vim_git_backup#git_helper#get_remote(a:directory, 'init'))
endfunction


function! vim_git_backup#git#add_note(message)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'nodes add -m "' . a:message . '"')
endfunction
