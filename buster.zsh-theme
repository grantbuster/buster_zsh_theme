# Custom zsh theme by Grant Buster
# useful unicode chars: ━┏┗ ┓┛  ─╭╰ ╮╯
# use to search unicode chars: https://shapecatcher.com/

set_color() {
    # custom colors for different hosts.
    # use "spectrum_ls" to see available colors.
    # default is 066
    if [[ "$HOST" == *"el"* ]]; then
        COLOR=002
    elif [[ "$HOST" == *"kl"* ]]; then
        COLOR=124
    elif [[ "$HOST" == *"ip-172"* ]]; then
        COLOR=013
    elif [[ "$HOST" == *"bbush"* ]]; then
        COLOR=027
    else
        COLOR=066
    fi
    echo "%{$FG[$COLOR]%}"
}

reset() {
	echo "%f%k%b"
}

chyph() {
    echo "$(set_color)─$(reset)"
}

inbracket() {
	echo "$(set_color)[$(reset)$1$(set_color)]$(reset)"
}

inbox() {
	echo "$(set_color)┫$(reset)$1$(set_color)┣$(reset)"
}

host_prompt_info() {
    echo "$(inbracket %M)"
}

conda_prompt_info() {
    if [[ -z "${CONDA_DEFAULT_ENV}" ]]; then
        echo ""
    else
        echo "$(inbracket "conda::$CONDA_DEFAULT_ENV")"
    fi
}

directory() {
	echo "$(inbracket "/%1//")"
}

current_time() {
   echo "$(inbracket "%T")"
}

function fill-line() {
    local left_len=$(prompt-length $1)
    local right_len=$(prompt-length $2)
    local pad_len=$((COLUMNS - left_len - right_len - 1))
    local pad=${(pl.$pad_len..─.)}  # pad_len spaces
    echo ${1}$(set_color)${pad}$(reset)${2}
}

function prompt-length() {
    emulate -L zsh
        local -i x y=${#1} m
        if (( y )); then
            while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
                x=y
                (( y *= 2 ))
            done
            while (( y > x + 1 )); do
                (( m = x + (y - x) / 2 ))
                (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
            done
        fi
    echo $x
}

function set-prompt() {
    local top_left="$(set_color)╭$(host_prompt_info)$(chyph)$(directory)"
    local top_right="$(git_prompt_info)$(conda_prompt_info)$(set_color)─╮$(reset)"
    local bottom_left="$(set_color)╰─>$(reset) "
    local bottom_right="$(chyph)$(chyph)$(current_time)$(set_color)─╯$(reset)"

    PROMPT="$(fill-line "$top_left" "$top_right")"$'\n'$bottom_left
    RPROMPT=$bottom_right
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set-prompt

ZSH_THEME_GIT_PROMPT_PREFIX="$(set_color)[$(reset)git::"
ZSH_THEME_GIT_PROMPT_SUFFIX="$(set_color)]$(reset)$(chyph)"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}x%{$reset%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}o%{$reset%}"
