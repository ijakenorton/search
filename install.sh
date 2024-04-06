#To install erlang and elixir
sudo apt-get -y install curl build-essential autoconf libncurses5-dev libssh-dev 
 curl https://mise.run | sh
 ~/.local/bin/mise use --global erlang@latest
 ~/.local/bin/mise use --global elixir@latest
# restart shell
# source ~/.zshrc  
# source ~/.bashrc
