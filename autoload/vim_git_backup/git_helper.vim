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


" TODO : Rename this function
function! vim_git_backup#git_helper#GetRemote(root, command)
    return s:RunFromFolder(a:root, a:command)
endfunction


function! s:RunFromFolder(root, command)
	return 'git -C ' . a:root . ' ' . a:command
endfunction


function! vim_git_backup#git_helper#get_commit_message(file)
    let l:file_name = fnamemodify(a:file, ':t')

    let l:folder = s:GetGitRoot(a:file)
    if l:folder == ""
        return vim_git_backup#git_helper#GetRemote(g:custom_backup_dir, 'commit -m "Updated: ' . l:file_name . '"')
    endif

	let l:branch_command = vim_git_backup#git_helper#GetRemote(l:folder, 'rev-parse --abbrev-ref HEAD')
    let l:branch = system(l:branch_command)

	if l:branch == 'HEAD'  " This happens when the user is not on the latest commit of a branch
        " This gets the name of the commit that the user is on
	    let l:branch_command = vim_git_backup#git_helper#GetRemote(l:folder, 'rev-parse HEAD')
        let l:branch = system(l:branch_command)
	endif

    let l:folder_name = fnamemodify(l:folder, ":t")

    return 'Repo: ' . l:folder_name . '/' . l:branch . '- ' . l:file_name
endfunction


function! vim_git_backup#git_helper#get_recommended_note(file1, file2)
    if !filereadable(a:file1)
        return 'Added ' . a:file2
    endif

    let l:line_diff = vim_git_backups#filer#get_line_diff(a:file1, a:file2)

    if l:line_diff == '1'
        let l:word = 'line'
    else
        let l:word = 'lines'
    endif

    return 'Changed ' . l:line_diff . ' ' . l:word
endfunction


function! vim_git_backup#git_helper#get_recommended_tag()
    let l:previous_date = system(vim_git_backup#git_helper#GetRemote(g:custom_backup_dir, 'describe --abbrev=0 --tags'))
    let l:today = strftime('%y/%m/%d')

    if l:today == l:previous_date
        return ""
    endif

    return l:today
endfunction
