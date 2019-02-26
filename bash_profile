# Created by Marcelo C. Carlos
# Modified setup from https://github.com/mathiasbynens/dotfiles

for file in $(ls ~/.dotfile_src_*); do
    [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Make multi-line commandsline in history
shopt -q -s cmdhist

# Make sure display get updated when terminal window get resized
shopt -q -s checkwinsize

if [ "$(uname)" == "Darwin" ]; then
    # Enabling bash-completion (you need to install it first - use brew for that!)
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# show the number of failed login attempts
if [ -f "/var/log/auth.log" ] ; then
    echo -e "Failed login attempts: $(grep 'Failed password' /var/log/auth.log* | wc -l)"
fi

# initialize rbenv
eval "$(rbenv init -)"

# initialize gpg daemon
eval $(gpg-agent --daemon)

# awscli completion
complete -C aws_completer aws

function cd {
    builtin cd "$@"
    if [ -d ".git" ]; then
        grep "git secrets --pre_commit_hook" .git/hooks/pre-commit -q 2> /dev/null
        if [ ! $? -eq 0 ]; then
            git secrets --install
        fi
    fi
}

source ~/.fzf.bash
#source ~/.bnw_dotfile

#export PATH="$(brew --prefix qt@5.5)/bin:$PATH"

function bnw_bastion {
  user=mcarlos

  environment=$1
  stage=$2
  region=$3
  [[ -z "${region}" ]] && region='eu-west-1'

  ip=$(bnw_ips bastion $environment $stage $region)
  ssh -l $user -A $ip
}

function bnw_ips {
  app=$1
  environment=$2
  stage=$3
  region=$4
  [[ -z "${region}" ]] && region='eu-west-1'
  aws ec2 describe-instances --filters "Name=tag:Application,Values=$app" "Name=instance-state-name,Values=running" --profile ${environment}-${stage} --region ${region} --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text
}

function bnw_ssh {
  user=mcarlos

  app=$1
  environment=$2
  stage=$3
  region=$4
  [[ -z "${region}" ]] && region='eu-west-1'

  bastion=$(bnw_ips bastion $environment $stage $region)

  ips=$(bnw_ips $app $environment $stage $region)
  total=$(echo "$ips" | wc -l)

  if [[ "$total" -gt 1 ]]; then
    select ip_item in $ips; do
      case $ip_item in
        *)
          ip=$ip_item;
          break;
      esac
    done
  else
    ip=$ips
  fi
  ssh -o ProxyCommand="ssh -W %h:%p ${user}@${bastion}" ${user}@${ip}
}


export PATH="$HOME/go/bin/:$HOME/bin:$PATH"
