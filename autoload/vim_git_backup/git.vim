" Create a `git add path` command.
function! vim_git_backup#git#add(path)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'add ' . a:path)
endfunction


" Create a `git tag` command.
function! vim_git_backup#git#add_tag(tag)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'tag ' . a:tag)
endfunction


" Create a `git commit -m ""` command.
function! vim_git_backup#git#commit(message)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'commit -m "' . a:message . '"')
endfunction


" Create a `git init` command.
function! vim_git_backup#git#init(directory)
    let l:results = system(vim_git_backup#git_helper#get_remote(a:directory, 'init'))

    if l:results !~ "^Initialized empty Git repository in " && l:results !~ "^Reinitialized existing Git repository in "
        echoerr 'Directory "' . a:directory . '" could not be made into a git repository.'
    endif
endfunction


" Create a `git notes add -m ""` command.
function! vim_git_backup#git#add_note(message)
    return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'notes add -m "' . a:message . '"')
endfunction
