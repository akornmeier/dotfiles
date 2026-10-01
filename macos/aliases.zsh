[[ "$OSTYPE" == darwin* ]] || return

# Flush DNS Cache
alias dnsflush='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias hosts='code /private/etc/hosts'
