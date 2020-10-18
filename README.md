# vim-git-backup
A top notch backup mechanism for Vim. Maintain copies of your files,
anywhere, and never lose anything again.


## How It Works
1. Work in Vim as you normally would. 
2. Save your file.
3. vim-git-backup does everything else for you, in the background.


## Integrations
Because the file back ups happen using git, any tool which uses git as a backend
can be used to view or edit your backups.

Here's a few personal favorites


- [agit](https://github.com/cohama/agit.vim)
- [fugitive](https://github.com/tpope/vim-fugitive)
- [gitk](https://git-scm.com/docs/gitk)


## Configuration
Control the folder where backups are stored, either by setting the

`VIM_CUSTOM_BACKUP_DIRECTORY` environment variable or by setting `g:custom_backup_dir` in your .vimrc.

e.g.

```sh
export VIM_CUSTOM_BACKUP_DIRECTORY=~/some/folder
```

```vim
let g:custom_backup_dir = "~/some/folder"
```


## Why You Should Care
If you've ever wanted to do any of the following things, you will love this plugin:

1. Show the most recently edited files
2. See all changes from the previous revision
3. Diff the changes in the last week
4. Get a list of all changed files from the last X days
5. Get the all-time diff of the files in the current directory
6. Search for any text which you A. Don't remember what file you put it in B. Was deleted a while ago
7. Search for git commits which contain a phrase through EVERY revision of every file in the current directory
8. Get the search contents for each commit that contains a phrase through EVERY revision of every file in the current directory
9. Backup any file as it was, X days ago
10. Restore a previous version of a file
11. View your backups using a tool like [agit](https://github.com/cohama/agit.vim) or [fugitive](https://github.com/tpope/vim-fugitive)
12. Get a summary of what you've worked on over X days (for time-keeping purposes)

And did I mention, each scenario above applies both to "overall" but
also can be filtered using the current directory?

This simple plugin easily provides all of this functionality and more.
Interested? Read on!


## Working With vim-git-backup On Command-Line
So you've installed vim-git-backup and have a catalog of back-ups that
you want to start using. Great!

To summarize, you can use any git command to construct your own queries, like this:

```sh
git -C ~/.vim_custom_backups grep foo  # Search for "foo" across all commits and all files
git -C ~/.vim_custom_backups log  # Get all commit history for your backups
```

Personally, I find writing all that to be tedious so I wrote a [really
simple wrapper script](ghistory) to do make it easier to write.

With the wrapper, you can now do things like

```sh
ghistory grep -n foo -- .  # Search in the current directory for any commit containing "foo"
ghistry log -Sblah -- .  # Search log contents for "blah"
ghistory CHANGED  # Show every tracked file, in "date modified" order
ghistory CHANGED -- .  # Show every tracked file, in "date modified" order, of the current directory
```

The wrapper script has a many different example commands. The few above
are just a fraction of what's possible.


## Advanced Vim Commands
Beyond the automatic functionality of vim-git-backup, there's also some
helpful functions which you can call to view and restore back up files.
To learn more, run this while inside Vim:

```vim
:help vim-git-backup
```


## Special Thanks
This plugin idea came from 
[this post](https://www.reddit.com/r/vim/comments/8w3udw/topnotch_vim_file_backup_history_with_no_plugins)
