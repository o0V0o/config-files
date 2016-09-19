ln -sir awesome ~/.config/awesome
ln -sir Vim/.vimrc ~/.vimrc
rm -r ~/.vim
mkdir ~/.vimbackup
ln -sir Vim/.vim ~/.vim
ln -sir tmux/.tmux.conf ~/.tmux.conf

ln -sir .xbindkeys ~/.xbindkeys

ls -al ~/.config/awesome
ls -al ~/.vimrc
ls -al ~/.tmux.conf
