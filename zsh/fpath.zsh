# Put every topic folder on fpath, so a topic can drop in functions (`functions/c`)
# or completions (`git/_included`) and have zsh find them with no wiring.
# -U keeps it free of duplicates: config.zsh's autoload glob and compinit both
# re-add entries, and a growing fpath slows every completion lookup.
typeset -U fpath
for topic_folder ($ZSH/*) if [ -d $topic_folder ]; then fpath=($topic_folder $fpath); fi;
