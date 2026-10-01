#!/bin/bash
#
# macOS-specific installation tasks

# Skip if not on macOS. `return` because bin/dot sources this file; `exit`
# would end the whole dot run.
if test ! "$(uname)" = "Darwin"; then
  return 0 2>/dev/null || exit 0
fi

echo "🔍 Checking for macOS updates..."

# Check for available updates first
UPDATE_COUNT=$(softwareupdate -l 2>&1 | grep -c "recommended" || true)

if [ "$UPDATE_COUNT" -gt 0 ]; then
  echo -e " ${YELLOW}$UPDATE_COUNT update(s) available.${NC}"
  echo ""

  # Prompt with timeout
  printf " Install updates now? (y/n) [15s timeout, defaults to skip]: "

  # Read with 15 second timeout
  if read -t 15 -n 1 response; then
    echo ""
    if [[ $response =~ ^[Yy]$ ]]; then
      echo " Installing updates..."
      # Install all updates without restarting (let user decide when to restart)
      sudo softwareupdate -i -a --no-restart

      # Check if restart is recommended
      if softwareupdate -l 2>&1 | grep -q "restart"; then
        echo ""
        echo "⚠️ Some updates require a restart."
        echo "Please restart your computer when convenient."
      fi
    else
      echo " Skipping updates. Run 'sudo softwareupdate -i -a' later to install."
    fi
  else
    # Timeout occurred
    echo ""
    echo " No response - skipping updates."
    echo " Run 'sudo softwareupdate -i -a' later to install."
  fi
else
  echo -e "  ${GREEN}✓ System is up to date.${NC}"
fi
