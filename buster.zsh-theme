COLOR=066

set_color() {
	echo "%{$FG[$COLOR]%}"
}

reset() {
	echo "%f%b"
}

inbracket() {
	echo "$(set_color)[$(reset)$1$(set_color)]$(reset)"
}

conda_prompt_info() {
	echo "$(inbracket "conda:$CONDA_DEFAULT_ENV")"
}

directory() {
	echo "$(inbracket "./%1/")"
}

hardware() {
	echo "$(inbracket "%M")"
}

current_time() {
   echo "$(inbracket "%t")"
}

function fill-line() {
    local left_len=$(prompt-length $1)
    local right_len=$(prompt-length $2)
    local pad_len=$((COLUMNS - left_len - right_len - 1))
    local pad=${(pl.$pad_len.. .)}  # pad_len spaces
    echo ${1}${pad}${2}
}

function set-prompt() {
    local top_left="$(set_color)┌$(hardware)-$(directory)"
    local top_right="$(git_prompt_info)$(conda_prompt_info)"
    local bottom_left="$(set_color)└>$(reset) "
    local bottom_right="$(current_time)"

    PROMPT="$(fill-line "$top_left" "$top_right")"$'\n'$bottom_left
    RPROMPT=$bottom_right
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

autoload -Uz add-zsh-hook
add-zsh-hook precmd set-prompt

ZSH_THEME_GIT_PROMPT_PREFIX="$(set_color)[$(reset)git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="$(set_color)]$(reset)-"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}x%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}o%{$reset_color%}"
