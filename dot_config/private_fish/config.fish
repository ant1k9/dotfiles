# The next line updates PATH for the Google Cloud SDK.
export EDITOR=vim

set -e _OLD_FISH_PROMPT_OVERRIDE
set -e _OLD_VIRTUAL_PYTHONHOME
set -e _OLD_VIRTUAL_PATH

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export AUTO_LAUNCHER_CONFIG_PATH="$HOME/.config/auto-launcher/config.toml"

eval (direnv hook fish)

# MacOS configs
if test (uname) = "Darwin"
    bind \cv edit_command_buffer
end

# Set PATH properly
function append-to-path
    set PATH (string replace ":$argv[1]" "" "$PATH")
    set PATH $PATH "$argv[1]"
end

for dir in \
    "$HOME/bin" \
    "$HOME/go/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/bin" \
    "$HOME/.arkade/bin" \
    "/home/linuxbrew/.linuxbrew/bin/fish" \
    "/var/lib/snapd/snap/bin"
    append-to-path "$dir"
end

alias al='auto-launcher'
alias allow='direnv allow'
alias box='formatter --header "┏━┓" --prefix "┃ " --suffix " ┃" --footer "┗━┛" --width 90'
alias c='curl'
alias cloc='cloc --exclude-list-file=.gitignore'
alias commitlint-head='commitlint --from=HEAD~1'
alias refresh-dropbox-token='gotask -t $HOME/.config/task/Taskfile.yml update-token'
alias dush='du -sh'
alias emacs='emacs -nw'
alias fishrc='vim ~/.config/fish/config.fish'
alias gmi='go-mod-init'
alias gmt='go mod tidy'
alias hpm='git push heroku main'
alias iconv1251='iconv -fcp1251'
alias k='kubectl'
alias ls=logo-ls
alias ncdu='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
alias r='source ~/.config/fish/config.fish '
alias semgrep-go='semgrep -f ~/go/pkg/mod/github.com/dgryski/semgrep-go@v0.0.0-20210819041707-9f189cc213ef/'
alias ticket='echo -n "["(git rev-parse --abbrev-ref HEAD | sed -s "s/\(release\|hotfix\)\///g")"]"'
alias tldr='tldr -p'
alias trc='vim ~/.tmux.conf'
alias tree='tree -C'
alias vimrc='vim ~/.vimrc'
alias viddy-agile='viddy "agile today show"'

# Helpers
if test (uname) != "Darwin"
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
end

# git aliases
alias amend='git add .; git commit -a --amend'
alias chk='git checkout'
alias gbr='git branch'
alias gci='gitci'
alias gd='git diff'
alias gds='_git-split-diff'
alias gdt='GIT_EXTERNAL_DIFF=difft gd'
alias gitci='git add .; git commit -a'
alias gitopen='open (git remote get-url --push origin)'
alias gp='git push'
alias gpl='git pull'
alias grbs='git rebase'
alias grbsc='grbs --continue'
alias gmr='git merge'
alias gmrc='gmr --continue'
alias last_commit='git log -1 --pretty=%B'
alias main='git checkout main'
alias master='git checkout master'
alias st='git status'

# Vagrant aliases
alias vd='vagrant destroy'
alias vgst='vagrant global-status'
alias vh='vagrant halt'
alias vnetinfo='vagrant netinfo'
alias vscp='vagrant scp'
alias vssh='vagrant ssh'
alias vst='vagrant status'
alias vup='vagrant up'

# Django helpers
alias dbshell='./manage.py dbshell'
alias djtest='echo yes | ./manage.py test -v2'
alias makemigrations='./manage.py makemigrations'
alias migrate='./manage.py migrate'
alias mshell='./manage.py shell'

function originpush
    git push origin (git rev-parse --abbrev-ref HEAD)
end

function grf
    grep -rn $argv . | egrep -v 'Binary|.git'
end

function grfi
    grep -rni $argv . | egrep -v 'Binary|.git'
end

function gsup
    set -l branch (git branch --show-current)
    git branch --set-upstream-to "origin/$branch" "$branch"
end

function mkcd
    mkdir -p "$argv[1]"
    cd "$argv[1]"
end

function add-db
    set -l db_name "$argv[1]"
    set -l db_user "$db_name-user"
    set -l db_pass "$db_user-password"

    psql -Upostgres -c "CREATE DATABASE \"$db_name\";"
    psql -Upostgres -c "CREATE USER \"$db_user\" WITH LOGIN;"
    psql -Upostgres -c "ALTER USER \"$db_user\" WITH PASSWORD '$db_pass';"
    psql -Upostgres -c "GRANT ALL ON DATABASE \"$db_name\" to \"$db_user\";"
    goose -dir ./migrations postgres "host=127.0.0.1 port=5432 user=$db_user dbname=$db_name password=$db_pass sslmode=disable" up
end

function migrate-db
    set -l db_name "$argv[1]"
    set -l db_user "$db_name-user"
    set -l db_pass "$db_user-password"
    set -l action "up"
    if test (count $argv) -eq 2
        set action "$argv[2]"
    end

    goose -dir ./migrations postgres "host=127.0.0.1 port=5432 user=$db_user dbname=$db_name password=$db_pass sslmode=disable" "$action"
end

function local-db
    set -l db_name (basename (git rev-parse --show-toplevel))
    pgcli -Upostgres "$db_name"
end

function mr
    set -l commit_msg (git log --oneline -n1 --format=format:'%s')
    set -l target "$argv[1]"
    if test (count $argv) -gt 0
        glab mr create --title "$commit_msg" --description "$commit_msg" --remove-source-branch --target-branch "$target"
    end
end

function memtop
    ps -ax -o comm,%mem \
        | awk '{ sum[$1] += $NF } END { for(var in sum) printf "%s: %s\n",var,sum[var] }' \
        | sort -nk2 \
        | tail \
        | column -t
end

function origin
    open (git remote get-url --push origin | tr -d '\n')
end

function tomp3
    if test (count $argv) -gt 0
        set -l mp3file (string replace -r '\-[\w\d]+\.\w+' '.mp3' "$argv[1]")
        ffmpeg -i "$argv[1]" -b:a 256k "$mp3file"
        rm "$argv[1]"
    end
end

function tomp3dir
    for file in (/bin/ls *.{webm,mp4,mkv})
        tomp3 "$file"
    end
end

function setmid3v2from
    if test (count $argv) -gt 0
        set delimeters "-" "—"
        for delimiter in $delimeters
            if test (echo "$argv[1]" | grep "$delimiter")
                set songdata (string replace ".mp3" "" "$argv[1]")
                set artist (string replace -r " $delimiter.*" "" "$songdata")
                set song (string replace -r ".* $delimiter " "" "$songdata")
                mid3v2 "$argv[1]" --delete-frames=TXXX --song="$song" --artist="$artist"
                return
            end
        end
    end
end

function ydlmp3
    if test (count $argv) -gt 0
        set -l filename (youtube-dl "$argv[1]" --get-filename)
        youtube-dl "$argv[1]"
        tomp3 "$filename" && setmid3v2from "$filename"
    end
end

function notify-me-at
    if test (count $argv) -eq 2
        echo notify-send "'"$argv[2]"'" | at "$argv[1]"
    end
end

function commit
    if test (count $argv) -eq 1
        set -l cticket (ticket)
        if test -f go.mod
            gmt || return
            if test -f Makefile
                make lint || return
                make test || return
            end
        end
        git add .
        git commit -m "$cticket $argv[1]"
    end
end

function godead
    unparam ./...
    staticcheck --unused.whole-program=true -- ./... \
        | egrep -v 'pb.go|^test|\.Enum|deprecated|ab/config|mock|binary_test'
end

function ungron
    if test (count $argv) -eq 1
        gron | grep -i "$argv[1]" | gron -u | jq
    end
end

function chezmoi-re-add
    for file in ~/.vimrc \
        ~/.config/fish/config.fish \
        ~/.tmux.conf \
        ~/.vim/ftplugin \
        ~/.config/git/ignore \
        ~/.config/tmuxinator \
        ~/.config/starship.toml
        chezmoi add -r $file
    end
end

function chezmoi-sync
    chezmoi git add .
    chezmoi git commit -- -m "Push local changes "(date '+%Y-%m-%d %H:%M:%S')
    chezmoi git push
end

function blog-notifier
    ssh $BLOG_NOTIFIER_HOST -i $BLOG_NOTIFIER_KEY_RSA \
        "cd ~/blog-notifier && ./blog_notifier.py $argv"
end

function rf
    if test (count $argv) -eq 3
        for file in (fd -e "$argv[1]" -X grep -H "$argv[2]" '{}' | cut -d':' -f1)
            sed -i".bak" 's!'"$argv[2]"'!'"$argv[3]"'!g' "$file"
        end
    end
end

function rfgo
    if test (count $argv) -eq 2
        rf "go" "$argv[1]" "$argv[2]"
    end
end

function _tmux_attach
    if test -n "$TMUX"
        tmux switch -t "$argv[1]"
    else
        tmux attach -t "$arfv[1]"
    end
end

function _tmux_session
    if test (count $argv) -eq 2
        if tmux has-session -t "$argv[2]"
            _tmux_attach "$argv[2]"
        else
            set -l CURRENT_DIR "$PWD"
            cd "$argv[1]"

            tmux new-session -d -s "$argv[2]"
            tmux split-window -h -t "$argv[2]:1.0"
            tmux split-window -t "$argv[2]:1.1"
            tmux select-pane -t "$argv[2]:1.0"
            for i in 0 1 2
                tmux send-keys -t "$argv[2]:1.$i" clear Enter
            end

            cd "$CURRENT_DIR"
            _tmux_attach "$argv[2]"
        end
    end
end

function tmux-session
    _tmux_session "$HOME/ny2j/projects/$argv[1]" "$argv[1]"
end

function ts
    _tmux_session "$PWD" (basename $PWD)
end

function notify-on-finish
    if test (count $argv) -eq 2
        while pgrep -f "$argv[1]" > /dev/null
            sleep 5
        end
        notify-send "$argv[2]"
    else
        echo -e "Usage:\n  notify-on-finish <command> <message>" | notify-send
    end
end

function drop-caches
    sudo sync
    sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
end

function gitconfig-common
    cp "$HOME/.gitconfig.common" "$HOME/.gitconfig"
end

function gitconfig-work
    cp "$HOME/.gitconfig.work" "$HOME/.gitconfig"
end

function _git-split-diff
    git diff $argv | git-split-diffs --color | less -RFX
end

function html-to-pdf
    set -l OUT_PDF "/tmp/"(cat /dev/random | tr -cd 'a-z0-9' | head -c 12)".pdf"
    puppeteer print "$argv[1]" "$OUT_PDF"
    open "$OUT_PDF"
end

function docable
    function _docable
        cd "$HOME/ny2j/projects/docable-notebooks"
        open "http://localhost:3000" &
        yarn dev
    end
    _restore_dir _docable
end

function poli
    function _poli
        cd "$HOME/Programms/poli-0.12.1"
        ./start.sh
    end
    _restore_dir _poli
end

function _restore_dir
    if test (count $argv) -eq 1
        set -l CURRENT_DIR "$PWD"
        $argv[1]
        cd $CURRENT_DIR
    end
end

function go-mod-init
    if test (count $argv) -eq 1
        mkcd "$argv[1]"
        go mod init "$argv[1]"
        gmt
        vim main.go
    end
end

function fish-functions
    grep -Eo "^function (.*)" "$HOME/.config/fish/config.fish" \
        | choose 1 -f ' ' | egrep -v '^_' | sort \
        | xargs -I'{}' printf "\033[0;32m{}\033[0m\n"
end


function teng
    trans -t eng -s ru "$argv"
end

function tru
    trans -t ru "$argv"
end

function grammarly
    firefox https://app.grammarly.com/docs/new &
end

function vifd
    vim -p (fd "$argv[1]")
end

test -s "$HOME/.config/fish/pass.fish"; and source "$HOME/.config/fish/pass.fish"
test -s "$HOME/.config/fish/work.fish"; and source "$HOME/.config/fish/work.fish"
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"

if test -n (which starship 2>/dev/null)
    starship init fish | source
end
