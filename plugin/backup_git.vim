""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands and Auto-Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=0 BackupCurrentFile :call s:BackupCurrentFile()

command! -nargs=0 OpenCurrentFileBackupHistory :call s:OpenCurrentFileBackupHistory()

command! -nargs=* RestoreFileUsingGitBackup :call s:RestoreFileUsingGitBackup(<q-args>)

command! -nargs=0 ToggleBackupFile :call s:ToggleBackupFile()

command! -nargs=0 GHistory :call GHistory()<CR>

" Backup the current file whenever the file is saved
augroup custom_backup
  autocmd!
  autocmd BufWritePost * call s:BackupCurrentFile()
augroup end


let g:custom_backup_dir = get(g:, 'custom_backup_dir', expand("$VIM_CUSTOM_BACKUP_DIRECTORY"))

if !get(g:, 'custom_backup_dir')
  let g:custom_backup_dir = '~/.vim_custom_backups'
endif

let g:custom_backup_dir = expand(g:custom_backup_dir)

" Choose a shell executable"
if expand("$SHELL") != "$SHELL"
    let g:custom_backup_shell_executable = expand("$SHELL")
elseif has("win32")
    let g:custom_backup_shell_executable = "C:\\Windows\\System32\\cmd.exe"
else
    let g:custom_backup_shell_executable = "/bin/sh"
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function definitions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:RunFromFolder(root, command)
	return 'git -C ' . a:root . ' ' . a:command
endfunction


" TODO : Rename this function
function! s:GetRemote(root, command)
	return s:RunFromFolder(a:root, a:command)
endfunction


function! s:GitInit(directory)
    call system(s:GetRemote(a:directory, 'init'))
endfunction


function! s:SetupBackupDirectory(directory)
    call mkdir(a:directory, "p")
    call s:GitInit()
endfunction


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


function! s:systemlist(command)
    return split(system(a:command, nr2char(10)))
endfunction


function! s:GetLineDiff(old, new)
    " Reference: https://stackoverflow.com/questions/1566461/how-to-count-differences-between-two-files-on-linux#comment51008286_2479947
    let l:output = s:systemlist('diff -U 0 "' . a:old . '" "' . a:new . '" | grep -v ^@ | tail -n +3 | wc -l')[0]
    return l:output
endfunction


function! s:GitAddNote(message)
    return s:GetRemote(g:custom_backup_dir, 'nodes add -m "' . message . '"')
endfunction


function! s:GetRecommendedNote(file1, file2)
    if !filereadable(a:file1)
        return 'Added ' . a:file2
    endif

    let l:line_diff = s:GetLineDiff(a:file1, a:file2)

    if l:line_diff == '1'
        let l:word = 'line'
    else
        let l:word = 'lines'
    endif

    return 'Changed ' . l:line_diff . ' ' . l:word
endfunction


function! s:CopyFile(file, backup_directory)
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

    call system('cp ' . a:file . ' ' . l:backup_file)
endfunction


function! s:GetCommitMessage(file)
    let l:file_name = fnamemodify(a:file, ':t')

    let l:folder = s:GetGitRoot(a:file)
    if l:folder == ""
        return s:GetRemote(g:custom_backup_dir, 'commit -m "Updated: ' . l:file_name . '"')
    endif

	let l:branch_command = s:GetRemote(l:folder, 'rev-parse --abbrev-ref HEAD')
    let l:branch = system(l:branch_command)

	if l:branch == 'HEAD'  " This happens when the user is not on the latest commit of a branch
        " This gets the name of the commit that the user is on
	    let l:branch_command = s:GetRemote(l:folder, 'rev-parse HEAD')
        let l:branch = system(l:branch_command)
	endif

    let l:folder_name = fnamemodify(l:folder, ":t")

    return 'Repo: ' . l:folder_name . '/' . l:branch . '- ' . l:file_name
endfunction


function! s:strip_mount(path)
    if has("win32")
        return substitute(a:path, "^[A-Z]:\\", "", "")
    endif

    return substitute(a:path, "^/", "", "")
endfunction


function! s:GitAdd(path)
    call s:GetRemote(g:custom_backup_dir, 'add ' . a:path)
endfunction


function! s:GitCommit(message)
    return s:GetRemote(g:custom_backup_dir, 'commit -m "' . message '"')
endfunction


function! s:GetRecommendedTag()
    let l:previous_date = system(s:GetRemote(g:custom_backup_dir, 'describe --abbrev=0 --tags'))
    let l:today = strftime('%y/%m/%d')

    if l:today == l:previous_date
        return ""
    endif

    return l:today
endfunction


function! s:GitAddTag(tag)
    return s:GetRemote(g:custom_backup_dir, 'tag ' . a:tag)
endfunction


function! s:BackupCurrentFile()
    if !isdirectory(expand(g:custom_backup_dir))
        call s:SetupBackupDirectory(g:custom_backup_dir)
    endif

    let l:file = expand('%:p')  " e.g. '/tmp/foo.txt'
    let l:backup_file = g:custom_backup_dir . l:file  " e.g. '~/.vim_custom_backups/tmp/foo.txt'
    let l:relative_backup_file = s:strip_mount(l:file)  " e.g. 'tmp/foo.txt'

    call s:CopyFile(l:file, g:custom_backup_dir)

    let commands = []

    call add(commands, s:GitAdd(l:relative_backup_file))
    call add(commands, s:GitCommit(s:GetCommitMessage(l:file)))
    call add(commands, s:GitAddNote(s:GetRecommendedNote(l:backup_file, l:file)))

    let tag = s:GetRecommendedTag()

    if !isempty(tag)
        call add(commands, s:GitAddTag(tag))
    endif

    let cmd = join(commands, ";")

    if exists("*job_start")
        " Run the command asynchronously (Vim 8+ only)
        call job_start([g:custom_backup_shell_executable, '-c', cmd])
    else
        " Run the command synchronously
        call system(cmd)
    endif
endfunction


" TODO : Requires tmux but I couldn't get it to work. Fix someday (or not)
" function! s:OpenCurrentFileBackupHistory()
"   let backup_dir = expand(g:custom_backup_dir . expand('%:p:h'))
"   let cmd = 'tmux split-window -h -c "' . backup_dir . '"\; '
"   let cmd .= 'send-keys "git log --patch --since=\"1 month ago\" ' . expand('%:t') . '" C-m'
"   call system(cmd)
" endfunction


function! s:OpenCurrentFileBackupHistory()
  let backup_dir = expand(g:custom_backup_dir . expand('%:p:h'))
  let cmd = "cd " . backup_dir
  let cmd .= "; git log -p --since='1 month' " . expand('%:t')

  silent! exe "noautocmd botright pedit vim_git_backups"
  noautocmd wincmd P
  set buftype=nofile
  exe "noautocmd r! ".cmd
  exe "normal! gg"
  noautocmd wincmd p
endfunction


function! s:RestoreFileUsingGitBackup(...)
  " If a backup file path is given, use it. Otherwise, use the current file
  let l:destination = get(a:, 1, '')

  if l:destination == ""
    let l:destination = expand('%:p')
  endif

  if l:destination == g:custom_backup_dir
    echoerr "No backup file was given or found. Please give a file path to RestoreFileUsingGitBackup."
    return
  endif

  let l:backup_file = g:custom_backup_dir . l:destination

  if filereadable(l:backup_file) == 0
    echoerr l:backup_file . " does not exist. Cannot continue with the backup."
    return
  endif

  let l:root = fnamemodify(l:destination, ":h")

  if !isdirectory(l:root)
    silent !mkdir -p l:root > /dev/null 2>&1
    redraw!
  endif

  let l:cmd = "cp " . l:backup_file . " " . l:destination
  call system(l:cmd)
endfunction


" Switch between the backup file and its working file
function! s:ToggleBackupFile()
    let l:full_path = expand('%:p')

    if l:full_path =~ '^' .  g:custom_backup_dir
        " If this block executes then that means the user is looking at the actual file
        let l:backup_path = l:full_path[strlen(g:custom_backup_dir):]
    else
        " If this block executes then that means the user is currently in the backup file
        let l:backup_path = g:custom_backup_dir . l:full_path
    endif

    execute "edit " . l:backup_path
endfunction


function! s:convert_to_absolute(text)
    if has('unix')
        return "/" . a:text
    return

    echoerr "Not implemented / supported"

    return ""
endfunction

" Open a FZF dialog to show all editted files
function! GHistory()
    " Note: This command uses `cd && git` instead of `git -C` because
    " `git -C` is a relatively recent git feature, which we don't really
    " need in this case.
    "
    let l:text = system("cd " . g:custom_backup_dir . " && git" . " ls-files")
    let l:files = split(l:text, "\n")

    " `l:files` is a list of paths which are relative to the Vim backup folder
    " So we must convert them back into absolute paths.
    "
    let l:files = map(l:files, 's:convert_to_absolute(v:val)')

    call fzf#run({"source": l:files, "sink": "e"})
endfunction
