---
title: Setup VIM plugin
date: 2017-04-09 11:53:53
tags:
	- Vim
	- Plugin
	- Vim-plug
---
Time to revisit my VIM plugin system after VIM is upgraded to version 8.0

Previously I was using [Vundle](https://github.com/VundleVim/Vundle.vim) but it is bit complicate to set up quickly. This time I am using [vim-plug](https://github.com/junegunn/vim-plug).

<!-- more -->

# Install Vim 8.0 on a clean window 10 system #
By default the installer creates
1.  **C:\Program Files (x86)\Vim\vim80** (folder)
2.  **C:\Program Files (x86)\Vim\_vimrc** (file)
3.  **C:\Users\lufeng\vimfiles** (folder. Sometimes the vimfiles folder is installed in C:\Program Files (x86)\Vim)

# Install vim-plug #
Assume you have curl installed. If not, download the exe file and add the path to environment PATH.
```bash
curl -fLo %USERPROFILE%/vimfiles/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
This will download and save the file **plug.vim** in **C:\Users\lufeng\vimfiles\autoload\**

# Setup your plugins
Edit the **C:\Program Files (x86)\Vim\_vimrc**, to insert below at the top of the file
```bash
call plug#begin('$HOME/vimfiles/plugged')
" Make sure you use single quotes
" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
" Plug 'junegunn/vim-easy-align'

Plug 'flazz/vim-colorschemes'
Plug 'PProvost/vim-ps1'
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
Plug 'kien/ctrlp.vim'
Plug 'majutsushi/tagbar'

" Initialize plugin system
call plug#end()
```
{% asset_img "PlugInstall.png " "Plug installing" %}

The first line specified where the plugin will be stored
```bash
call plug#begin('$HOME/vimfiles/plugged')
```
Therefore all plugins are stored in **C:\Users\lufeng\vimfiles\plugged**

EOF

