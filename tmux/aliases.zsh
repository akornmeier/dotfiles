# Tmux aliases
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'

# WARNING: The alias below uses --dangerously-skip-permissions, which allows
# Claude Code to execute tools (shell commands, file writes, etc.) without
# prompting for user confirmation. Only use this in trusted, sandboxed
# environments. Do not source this file on shared or production machines.
# Claude Code Orchestration
alias cldyo='export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 && claude --verbose --dangerously-skip-permissions --model opus --teammate-mode tmux'
