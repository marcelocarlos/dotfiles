[ -n "$PS1" ] && source ~/.bash_profile
source ~/.fzf.bash
complete -C /usr/local/bin/vault vault
source <(kubectl completion bash)
