# # export PYENV_ROOT="$HOME/.pyenv"
# # export PATH="$PYENV_ROOT/bin:$PATH"
# # export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

# # plugin=(
# #   pyenv
# # )

# # eval "$(pyenv init -)"
# # eval "$(pyenv virtualenv-init -)"

# # alias python='python3'

# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]]
# export PATH="$PYENV_ROOT/bin:$PATH"
# echo 'eval "$(pyenv init -)"' >> ~/.zshrc

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"