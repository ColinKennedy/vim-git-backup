if get(g:, 'vim_git_backup_loaded', '0') == '1'
    " Prevent this plugin from being loaded more than once in a single Vim session
    finish
endif

" Check for required executable commands
for name in ["diff", "git", "sed", "tac"]
    if !executable(name)
        echoerr 'vim-git-backup requires "' . name . '" cannot continue.'

        finish
    endif
endfor

if empty(get(g:, 'vim_git_backup_shell_separator'))
    let g:vim_git_backup_shell_separator = ' && '
endif

if empty(get(g:, 'vim_git_backup_shell_setter'))
    let g:vim_git_backup_shell_setter = '%s="%z"'
endif

if has('win32') || has("win64")
    let g:vim_git_backup_is_windows = 1
    let s:PATH_SEPARATOR = '\'
else
    let g:vim_git_backup_is_windows = 0
    let s:PATH_SEPARATOR = '/'
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands and Auto-Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=0 BackupCurrentFile :call s:BackupCurrentFile()

command! -nargs=0 OpenCurrentFileBackupHistory :call s:OpenCurrentFileBackupHistory()

command! -nargs=* RestoreFileUsingGitBackup :call s:RestoreFileUsingGitBackup(<q-args>)

command! -nargs=0 ToggleBackupFile :call s:ToggleBackupFile()

command! -nargs=0 GHistory :call GHistory()


" Backup the current file whenever the file is saved
augroup custom_backup
    autocmd!
    autocmd BufWritePost * call s:BackupCurrentFile()
augroup end


let g:custom_backup_dir = get(g:, 'custom_backup_dir', expand("$VIM_CUSTOM_BACKUP_DIRECTORY"))

if get(g:, 'custom_backup_dir') is 0
    let g:custom_backup_dir = '~/.vim_custom_backups'
endif

let g:custom_backup_dir = expand(g:custom_backup_dir)

" Choose a shell executable"
if expand("$SHELL") != "$SHELL"
    let g:custom_backup_shell_executable = expand("$SHELL") . " -c"
elseif has("win32")
    let g:custom_backup_shell_executable = "C:\\Windows\\System32\\cmd.exe /C"
else
    let g:custom_backup_shell_executable = "/bin/sh -c"
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function definitions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:SetupBackupDirectory(directory)
    call mkdir(a:directory, "p")
    call vim_git_backup#git#init(a:directory)
endfunction


function! s:BackupCurrentFile()
    if !isdirectory(expand(g:custom_backup_dir))
        call s:SetupBackupDirectory(g:custom_backup_dir)
    endif

    " 1. Backup the file
    let l:file = expand('%:p')  " e.g. '/tmp/foo.txt'

    if l:file =~ '\.git' .. s:PATH_SEPARATOR
        return
    endif

    let l:backup_file = g:custom_backup_dir . l:file  " e.g. '~/.vim_custom_backups/tmp/foo.txt'
    let l:relative_backup_file = vim_git_backup#filer#strip_mount(l:file)  " e.g. 'tmp/foo.txt'

    try
        let l:file_lines = readfile(l:file)
    catch /.*/
        silent! echoerr 'Cannot read file "' . l:file . '", skipping git backup.'

        return
    endtry

    let l:recommended_note = vim_git_backup#git_helper#get_recommended_note(
    \ l:backup_file,
    \ l:file,
    \ l:file_lines
    \ )

    call vim_git_backup#filer#copy(l:file, l:file_lines, g:custom_backup_dir)

    let l:commands = []

    call add(l:commands, vim_git_backup#git#add(l:relative_backup_file))

    for l:line in vim_git_backup#git_helper#get_commit_commands(g:custom_backup_dir, l:file)
        call add(l:commands, l:line)
    endfor

    call add(l:commands, vim_git_backup#git#add_note(l:recommended_note))

    let l:command = join(l:commands, g:vim_git_backup_shell_separator)

    if exists("*jobstart")
        " Run asynchronously, in Neovim
        call jobstart(l:command)
    elseif exists("*job_start")
        " Run asynchronously, in Vim 8+
        let l:job_command = g:custom_backup_shell_executable . " " . l:command
        call job_start(l:job_command)
    else
        " Run the command synchronously
        call system(l:command)
    endif
endfunction


function! s:OpenCurrentFileBackupHistory()
    let backup_dir = expand(g:custom_backup_dir . expand('%:p:h'))
    let cmd = "cd " . backup_dir
    let cmd .= "; git log -p --since='1 month' " . expand('%:t')

    silent! exe "noautocmd botright pedit vim_git_backup"

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


" Switch between the backup file and its working file.
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


" If the user also has installed fzf.vim, add fzf-specific functions
if &rtp =~ "fzf.vim"
    " Open a FZF dialog to show all edited files.
    function! GHistory(...)
        " Note: This command uses `cd && git` instead of `git -C` because
        " `git -C` is a relatively recent git feature, which we don't really
        " need in this case.
        "
        if a:0
            let l:keep_order = a:1
        else
            let l:keep_order = get(g:, "git_backup_keep_file_order", "1") == "1"
        endif

        if l:keep_order
            let l:commands = [
            \    'cd ' . g:custom_backup_dir,
            \    'git diff-index --name-only --diff-filter=A @',
            \    'git log --pretty='''' --name-only | awk ''!seen[$0]++'' 2> /dev/null',
            \]
            let l:text = system(join(l:commands, "\n"))
            let l:files = split(l:text, "\n")
        else
            let l:text = system("cd " . g:custom_backup_dir . " && git" . " ls-files")
            let l:files = split(l:text, "\n")
        endif

        " `l:files` is a list of paths which are relative to the Vim backup folder
        " So we must convert them back into absolute paths.
        "
        let l:files = map(l:files, 's:convert_to_absolute(v:val)')

        call fzf#run({"source": l:files, "sink": "e"})
    endfunction
endif


let g:vim_git_backup_loaded = '1'
