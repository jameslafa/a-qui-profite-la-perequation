#!zsh -f
coffee -p -c coffee/home.coffee | uglifyjs > ../../public/js/home.min.js
coffee -p -c coffee/comparer.coffee | uglifyjs > ../../public/js/comparer.min.js
coffee -p -c coffee/main.coffee | uglifyjs > ../../public/js/main.min.js