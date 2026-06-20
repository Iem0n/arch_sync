# ИНТЕРФЕЙС И ПРИГЛАШЕНИЕ (Prompt)
# Двухстрочный минималистичный prompt. 
# Верхняя строка: Имя (белое) @ Хост (серое) -> Путь (акцентный белый)
# Нижня строка: Просто строгий символ "-> " для ввода команды.
PS1="\[\e[1;37m\]\u\[\e[0m\]\[\e[0;37m\]@\h\[\e[0m\] \[\e[1;37m\]\w\[\e[0m\]\n\[\e[1;37m\]→ \[\e[0m\]"

# НАСТРОЙКИ И ИСПРАВЛЕНИЯ ОПЕЧАТОК
shopt -s autocd # Позволяет переходить в папку, просто введя её имя без "cd"
shopt -s cdspell # Автоматически исправляет мелкие опечатки в именах папок при cd
shopt -s histappend # Дописывать историю, а не перезаписывать её
export HISTSIZE=10000
export HISTFILESIZE=20000

# ЦВЕТА ДЛЯ СИСТЕМНЫХ УТИЛИТ
export COLORTERM="truecolor"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# Кастомная монохромная расцветка для ls (папки — белые жирные, файлы — обычные)
export LS_COLORS="di=1;37:ln=0;36:so=0;35:pi=0;33:ex=0;32:bd=0;34;46:cd=0;34;43:su=0;30;41:sg=0;30;46:tw=0;30;42:ow=0;30;43"

# ПОЛЕЗНЫЕ АЛИАСЫ
# Навигация
alias ..='cd ..'
alias ...='cd ../..'

# Замена дефолтных редакторов на Helix
alias hx='helix'
alias nano='helix'
alias vi='helix'
alias vim='helix'

# Быстрый перезапуск элементов десктопа
alias rway='pkill -SIGUSR2 waybar'
alias rmak='pkill mako && mako &'
alias rfuz='pkill -9 fuzzel'

# Системные
alias c='clear'

# ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ
export EDITOR="hx"
export VISUAL="hx"

export MOZ_ENABLE_WAYLAND=1
export LIBVA_DRIVER_NAME=radeonsi
export VDPAU_DRIVER=radeonsi
export AMD_VULKAN_ICD=RADV
