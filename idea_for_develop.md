Суда пишу идеи для последующей реализации:  
========================

Сделать модуль  
1. Lingua-Cirrilic-Perligata  
------------------------
https://metacpan.org/source/DCONWAY/Lingua-Romana-Perligata-0.50  

Перевести на русский  
2. YAPE::Regex::Explain  
------------------------

3. Идеи по отладке регулярных выражений  
------------------------
```
perl -M"re debug" 01_simple_regex.pl   
```

4. Прочитать книгу
------------------------
http://lib.alpinadigital.ru/library/book/2951

5. Пока есть на наброски для презентаций: 
------------------------

“Рекурсия в регулярных выражениях” 
------------------------
(фактически это будут выдержки из документации perlre
https://metacpan.org/pod/distribution/POD2-RU/lib/POD2/RU/perlre.pod )
“Vroom - Slide Shows in Vim”
------------------------
(а здесь будет скорее всего улучшенный перевод
http://blogs.perl.org/users/buddy_burden/2013/06/slideshows-in-vroom-so-noted.html )

6. Перевод документации
------------------------

- perlootut - Object-Oriented Programming in Perl Tutorial
- perlopentut - simple recipes for opening files and pipes in Perl
- perlreftut - Mark's very short tutorial about references +
- perlpacktut - tutorial on pack and unpack
- perldebtut - Perl debugging tutorial
- perlthrtut - Tutorial on threads in Perl
- perlhacktut - Walk through the creation of a simple C code patch


.profile
------------------------
````
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

alias got='git '
alias get='git '
alias gh='git hist '
alias gt='git type '
alias gu='git dump '

пше() {
    name="git"
    args=${@:2}
    space=" "
    case $1 in
            "додать") sub="add";;
            "бисект") sub="bisect";;
            "бранч") sub="branch";;
            "чекаут") sub="checkout";;
            "комит") sub="commit";;
            "клон") sub="clone";;
            "диф") sub="diff";;
            "фетч") sub="fetch";;
            "греп") sub="grep";;
            "инит") sub="init";;
            "лог") sub="log";;
            "мерж") sub="merge";;
            "мув") sub="mv";;
            "пул") sub="pull";;
            "пуш") sub="push";;
            "ребейз") sub="rebase";;
            "резет") sub="reset";;
            "ремув") sub="rm";;
            "шоу") sub="show";;
            "стан") sub="status";;
            "тег") sub="tag";;
            *) sub=""; args=$@;;
    esac;
	command=$name$space$sub$space$args;
	eval $command;
}

_pshe() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "додать бисект бранч чекаут комит клон диф фетч греп инит лог мерж мув пул пуш ребейз резет ремув шоу стан тег" -- $cur) )
}

complete -F _pshe пше
````

.gitconfig
------------------------
````
[user]
	name = Nikolay Mishin
	email = mi@ya.ru
[core]
	autocrlf = false
	safecrlf = true
	excludesfile = C:\\Users\\rb102870\\Documents\\gitignore_global.txt
[gui]
	recentrepo = C:/Users/rb102870/Documents/job/23072014/сделанное
[alias]
	co = checkout
	ci = commit
	st = status
	br = branch
	#hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
	hist = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
	type = cat-file -t
	dump = cat-file -p
````
