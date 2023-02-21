# General
alias rm='echo "This is not the command you are looking for."; false'

# AWS
alias ssm_my_sessions='aws ssm describe-sessions --state "Active" --filters "key=Owner,value=arn:aws:iam::751486495581:user/josiah.caprino"'
alias ec2_start_cpu='aws ec2 start-instances --instance-ids i-0abc89187f1e2e2aa'
alias ec2_describe_cpu='aws ec2 describe-instance-status --instance-ids i-0abc89187f1e2e2aa'
alias ec2_stop_cpu='aws ec2 stop-instances --instance-ids i-0abc89187f1e2e2aa'
alias ec2_reboot_cpu='aws ec2 reboot-instances --instance-ids i-0abc89187f1e2e2aa'
alias ec2_start_gpu='aws ec2 start-instances --instance-ids i-0808afe182a3f57a0' 
alias ec2_describe_gpu='aws ec2 describe-instance-status --instance-ids i-0808afe182a3f57a0'
alias ec2_stop_gpu='aws ec2 stop-instances --instance-ids i-0808afe182a3f57a0'
alias ec2_reboot_gpu='aws ec2 reboot-instances --instance-ids i-0808afe182a3f57a0'
alias ec2_ssh_cpu='ssh -t i-0abc89187f1e2e2aa.us-east-2 bash -c zsh -l'

# Docker
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Size}}\t{{.Ports}}"' 
alias port_forward_vscode='ssh -v -NL localhost:23750:/var/run/docker.sock i-0808afe182a3f57a0.us-east-2'

# TLDR
alias tldr='docker run --rm -it -v ~/.tldr/:/root/.tldr/ nutellinoit/tldr'