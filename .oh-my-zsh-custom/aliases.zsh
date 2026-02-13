# ============================================================================
# GENERAL ALIASES & CONFIGURATION
# ============================================================================

# Tool aliases
alias tf=terraform
alias kns=kubens
alias kctx=kubectx
alias cat='bat --paging=never -p'
node-root() {
  kubectl run node-root --restart=Never --rm -it --image=alpine --privileged \
    --overrides '{"spec":{"hostPID":true}}' \
    --override-type=merge \
    --command -- nsenter --mount=/proc/1/ns/mnt -- /bin/bash
}

# Man page configuration
export MANPAGER="env BATMAN_IS_BEING_MANPAGER=yes /bin/bash $HOMEBREW_PREFIX/bin/batman"
export MANROFFOPT="-c"

# Load kubectl aliases if available
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
