# The next line updates PATH for the Google Cloud SDK.
export EDITOR=vim

set -e _OLD_FISH_PROMPT_OVERRIDE
set -e _OLD_VIRTUAL_PYTHONHOME
set -e _OLD_VIRTUAL_PATH

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

eval (direnv hook fish)

# Set PATH properly
function appendToPath
    set PATH (string replace ":$argv[1]" "" "$PATH")
    set PATH $PATH "$argv[1]"
end

appendToPath "/home/antik/bin"
appendToPath "/home/antik/go/bin"
appendToPath "/home/antik/.cargo/bin"
appendToPath "/home/antik/.local/bin"
appendToPath "/home/antik/.npm-global/bin"
appendToPath "/home/antik/.fly/bin"
appendToPath "/var/lib/snapd/snap/bin"

alias allow='direnv allow'
alias c='curl'
alias cloc='cloc --exclude-list-file=.gitignore'
alias dush='du -sh'
alias fishrc='vim ~/.config/fish/config.fish'
alias gmt='go mod tidy'
alias iconv1251='iconv -fcp1251'
alias k='kubectl'
alias ls=logo-ls
alias ncdu='ncdu --color dark -rr -x --exclude .git --exclude node_modules'
alias r='source ~/.config/fish/config.fish '
alias semgrep-go='semgrep -f ~/go/pkg/mod/github.com/dgryski/semgrep-go@v0.0.0-20210819041707-9f189cc213ef/'
alias ticket='echo -n "["(git rev-parse --abbrev-ref HEAD | sed -s "s/\(release\|hotfix\)\///g")"]"'
alias tree='tree -C'
alias vimrc='vim ~/.vimrc'

# Helpers
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# git aliases
alias amend='git commit -a --amend'
alias checkout='git checkout'
alias gci='gitci'
alias gd='git diff'
alias gitci='git add .; git commit -a'
alias gp='git push'
alias gpl='git pull'
alias last_commit='git log -1 --pretty=%B'
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

function newbranch
    git push --set-upstream origin (git rev-parse --abbrev-ref HEAD)
end

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

function add
    echo "alias "$argv[1]"='"$argv[2]"'" >> /home/antik/.config/fish/config.fish
end

function duration
    ffmpeg -i "$argv[1]" 2>&1 | grep Duration
end

function mkcd
    mkdir -p "$argv[1]"
    cd "$argv[1]"
end

function add_db
    set -l db_name "$argv[1]"
    set -l db_user "$db_name-user"
    set -l db_pass "$db_user-password"

    psql -Upostgres -c "CREATE DATABASE \"$db_name\";"
    psql -Upostgres -c "CREATE USER \"$db_user\" WITH LOGIN;"
    psql -Upostgres -c "ALTER USER \"$db_user\" WITH PASSWORD '$db_pass';"
    psql -Upostgres -c "GRANT ALL ON DATABASE \"$db_name\" to \"$db_user\";"
    goose -dir ./migrations postgres "host=127.0.0.1 port=5432 user=$db_user dbname=$db_name password=$db_pass sslmode=disable" up
end

function migrate_db
    set -l db_name "$argv[1]"
    set -l db_user "$db_name-user"
    set -l db_pass "$db_user-password"
    set -l action "up"
    if test (count $argv) -eq 2
        set action "$argv[2]"
    end

    goose -dir ./migrations postgres "host=127.0.0.1 port=5432 user=$db_user dbname=$db_name password=$db_pass sslmode=disable" "$action"
end

function local_db
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
    for file in ~/.vimrc ~/.config/fish/config.fish ~/.tmux.conf ~/.vim/ftplugin
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

function rfgo
    if test (count $argv) -eq 2
        for file in (fd -e go -X grep -H "$argv[1]" '{}' | cut -d':' -f1)
            sed -i 's:'"$argv[1]"':'"$argv[2]"':g' "$file"
        end
    end
end

function vginit
    if test (count $argv) -eq 1
        git clone "https://github.com/ant1k9/vagrant-basic-centos" "$argv[1]"
        cd "$argv[1]"
    end
end

test -f "$HOME/.config/fish/pass.fish" && source "$HOME/.config/fish/pass.fish"
test -f "$HOME/.config/fish/work.fish" && source "$HOME/.config/fish/work.fish"
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"
