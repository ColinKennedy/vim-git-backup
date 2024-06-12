" Prevent special characters from getting manipulated by vimscript functions accidentally.
"
" This function is a companion to `s:_set_command`.
"
" Args:
"     text (str): The text to escape. e.g. "cd /tmp && ls"
"
" Returns:
"     str: The escaped text. e.g. "cd /tmp \&\& ls"
"
function! s:_escape(text)
    return substitute(a:text, '&', '\\&', 'g')
endfunction


" Create a shell-style set-variable command. e.g. `set foo=`ls bar``.
"
" Important:
"     This function assumes that `assignee` has special characters escaped.
"     Known characters which must be escaped
"     - &
"
" Args:
"     variable_name (str): The name of the shell variable to create.
"     assignee (str): The right-hand value to assign onto `variable_name`.
"
" Returns:
"     str: The final variable-set command. e.g. "set foo=bar".
"
function! s:_set_command(variable_name, assignee)
    if !g:vim_git_backup_is_windows
        let l:text = substitute(g:vim_git_backup_shell_setter, '%s', a:variable_name, 'g')

        return substitute(l:text, '%z', a:assignee, 'g')
    endif

    echoerr 'Windows is not supported yet'

    return ''
endfunction


" Convert `name` into a terminal variable.
"
" Args:
"     name (str): The variable name to make into a variable. e.g. "foo
"
" Returns:
"     str: The generated variable name. e.g. "$foo".
"
function! s:_variable(name)
    if !g:vim_git_backup_is_windows
        return '$' . a:name
    endif

    echoerr 'Windows is not supported yet'

    return ''
endfunction


" Make a in-line shell command from `text`.
"
" Args:
"     command (str): The shell text that represents a command. e.g. "cd /tmp".
"
" Returns:
"     str: The generated command. e.g. "`cd /tmp`".
"
function! s:_wrap(command)
    return '`' . a:command . '`'
endfunction


" Find the root git folder, assuming `path` is on or inside of a git repository.
"
" Args:
"     path (str): A file or folder within a git repository.
"
" Returns:
"     str: The found git repository root. If not root was found, return an empty string.
"
function! s:GetGitRoot(path)
    " Note: This function only works on Linux!
    let l:parts = split(a:path, '/')
    let l:index = 0
    let l:length = len(parts)

    for part in l:parts
        let l:root = join([''] + parts[:l:length - l:index], '/')

        if finddir('.git', l:root) != "" || findfile('.git', l:root) != ""
            return l:root
        endif

        let index += 1
    endfor

    return ''
endfunction


" Create a recommended message for the git commit of a backup file.
"
" This function is auto-generated so it's not that helpful beyond saying
" what was edited.
"
" Args:
"     file (str):
"         The absolute path to a file on-disk which we'll generate a
"         commit message for.
"
" Returns:
"     list[str]:
"         The shell commands needed to generate a git commit message.
"
function! vim_git_backup#git_helper#get_commit_commands(root, file)
    let l:file_name = fnamemodify(a:file, ':.')

    let l:folder = s:GetGitRoot(a:file)

    if l:folder == ""
        return [
        \     vim_git_backup#git_helper#get_remote(
        \         g:custom_backup_dir,
        \         "commit -m 'Updated: " . l:file_name . "'"
        \     )
        \ ]
    endif

    let l:folder_name = fnamemodify(l:folder, ":t")
    let l:branch_name_command = vim_git_backup#git_helper#get_remote(l:folder, 'rev-parse --abbrev-ref HEAD')
    let l:branch_variable_name = 'branch_name'
    let l:commit_message = 'Repo: ' . l:folder_name . '/' . s:_variable(l:branch_variable_name) . ' - ' . l:file_name
    let l:commit_command = 'commit -m "' . l:commit_message . '"'

    let l:branch_name_command = s:_wrap(s:_escape(l:branch_name_command))

    return [
    \ s:_set_command(l:branch_variable_name, l:branch_name_command),
    \ vim_git_backup#git_helper#get_remote(a:root, l:commit_command),
    \ ]
endfunction


" Create a note for a commit message for some backed up file.
"
" Args:
"     old (str): The file which the user wants to back up.
"     new (str): The location on-disk where `file1` will be backed up to.
"     new_lines (list[str]): The text lines of `new` to compare against `old`.
"
" Returns:
"     str: The generated message.
"
function! vim_git_backup#git_helper#get_recommended_note(old, new, new_lines)
    if !filereadable(a:old)
        return 'Added ' . a:new
    endif

    let l:old_line_count = len(readfile(a:old))
    let l:new_line_count = len(a:new_lines)

    let l:difference = l:new_line_count - l:old_line_count

    if l:difference == 1 || l:difference == -1
        let l:word = 'line'
    else
        let l:word = 'lines'
    endif

    if l:difference >= 0
        let l:modifier = 'Added'
    else
        let l:modifier = 'Removed'
        let l:difference *= -1
    endif

    return l:modifier . ' ' . l:difference . ' ' . l:word
endfunction


" Create a git command which runs `command` from some git `root` folder.
"
" Args:
"     root (str): The directory of a git repository to run `command` from.
"     command (str): The raw git command to run.
"
" Returns:
"     str: The generated command.
"
function! vim_git_backup#git_helper#get_remote(root, command)
    return 'cd ' . a:root . g:vim_git_backup_shell_separator . 'git ' . a:command
endfunction
