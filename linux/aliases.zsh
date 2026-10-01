[[ "$OSTYPE" == linux* ]] || return

# Flush DNS Cache
alias dnsflush='resolvectl flush-caches'
alias hosts='sudoedit /etc/hosts'
