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

        if finddir('.git', l:root) != ""
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
"     str:
"         The generated commit message. If `file` is inside of a git
"         repository, the git commit message will include repository and
"         branch details in the message.
"
function! vim_git_backup#git_helper#get_commit_message(file)
    let l:file_name = fnamemodify(a:file, ':t')

    let l:folder = s:GetGitRoot(a:file)
    if l:folder == ""
        return vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'Updated: ' . l:file_name)
    endif

	let l:branch_command = vim_git_backup#git_helper#get_remote(l:folder, 'rev-parse --abbrev-ref HEAD')
    let l:branch = system(l:branch_command)

	if l:branch == 'HEAD'  " This happens when the user is not on the latest commit of a branch
        " This gets the name of the commit that the user is on
	    let l:branch_command = vim_git_backup#git_helper#get_remote(l:folder, 'rev-parse HEAD')
        let l:branch = system(l:branch_command)
	endif

    let l:folder_name = fnamemodify(l:folder, ":t")

    return 'Repo: ' . l:folder_name . '/' . l:branch . '- ' . l:file_name
endfunction


" Create a note for a commit message for some backed up file.
"
" Args:
"     file1 (str): The file which the user wants to back up.
"     file2 (str): The location on-disk where `file1` will be backed up to.
"
" Returns:
"     str: The generated message.
"
function! vim_git_backup#git_helper#get_recommended_note(file1, file2)
    if !filereadable(a:file1)
        return 'Added ' . a:file2
    endif

    let l:line_diff = vim_git_backup#filer#get_line_diff(a:file1, a:file2)

    if l:line_diff == '1'
        let l:word = 'line'
    else
        let l:word = 'lines'
    endif

    return 'Changed ' . l:line_diff . ' ' . l:word
endfunction


" str: Create a recommended tag, if needed.
function! vim_git_backup#git_helper#get_recommended_tag()
    let l:previous_date = system(vim_git_backup#git_helper#get_remote(g:custom_backup_dir, 'describe --abbrev=0 --tags'))
    let l:today = strftime('%y/%m/%d')

    if l:today == l:previous_date
        return ""
    endif

    return l:today
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
    return 'git -C ' . a:root . ' ' . a:command
endfunction
