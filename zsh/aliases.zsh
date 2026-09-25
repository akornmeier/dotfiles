# Standard Shell
alias l='ls -l'
alias reload='source ~/.zshrc'

# Flush DNS Cache
if [[ "$OSTYPE" == darwin* ]]; then
  alias dnsflush='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  alias hosts='code /private/etc/hosts'
else
  alias dnsflush='resolvectl flush-caches'
  alias hosts='sudoedit /etc/hosts'
fi

alias cls='clear' # Good 'ol Clear Screen command

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"