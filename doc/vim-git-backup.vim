Version 1.0.0

Copyright (C) 2020 Colin Kennedy <http://colinkennedy.github.io/>

License: So-called MIT/X license
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

CONTENTS                                        *vim-git-backup*

Introduction                           |vim-git-backup-introduction|
How It Works                           |vim-git-backup-how-it-works|
Integrations                           |vim-git-backup-integrations|
Configuration                          |vim-git-backup-configuration|
Advanced Commands                      |vim-git-backup-advanced-commands|
Requires                               |vim-git-backup-requires|
Special Thanks                         |vim-git-backup-special-thanks|

===============================================================================
Introduction                          *vim-git-backup-introduction*

A top notch backup mechanism for Vim. Maintain copies of your files,
anywhere, and never lose anything again.


===============================================================================
How It Works                          *vim-git-backup-how-it-works*

1. Work in Vim as you normally would.
2. Save your file.
3. vim-git-backup does everything else for you, in the background.


===============================================================================
Integrations                           *vim-git-backup-integrations*

Because the file back ups happen using git, any tool which uses git as a backend
can be used to view or edit your backups.

Here's a few personal favorites


- [agit](https://github.com/cohama/agit.vim)
- [fugitive](https://github.com/tpope/vim-fugitive)
- [fzf](https://github.com/junegunn/fzf.vim)
- [gitk](https://git-scm.com/docs/gitk)


===============================================================================
Configuration                           *vim-git-backup-configuration*

Control the folder where backups are stored, either by setting the

`VIM_CUSTOM_BACKUP_DIRECTORY` environment variable or by setting
`g:custom_backup_dir` in your .vimrc.

e.g.

>
    export VIM_CUSTOM_BACKUP_DIRECTORY=~/some/folder

>
    let g:custom_backup_dir = "~/some/folder"


===============================================================================
Advanced Commands                           *vim-git-backup-advanced-commands*


BackupCurrentFile
Manually runs the file backup command.

OpenCurrentFileBackupHistory
Open all file backups in a new buffer

RestoreFileUsingGitBackup
While viewing a backup file, copy the backup to its original location.

ToggleBackupFile
Switch between the backup file and its working file.

GHistory
Open a FZF dialog to show all edited files. This command requires
[fzf](https://github.com/junegunn/fzf.vim) to be installed.


===============================================================================
Requires                                    *vim-git-backup-requires*

- Vim 8.0+
- Linux (Windows support on-request)


===============================================================================
Special Thanks                                 *vim-git-backup-special-thanks*

This plugin idea came from
[this post](https://www.reddit.com/r/vim/comments/8w3udw/topnotch_vim_file_backup_history_with_no_plugins)
