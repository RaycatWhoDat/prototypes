rm -rf node_modules dist .temp
npm i
haxelib deleterepo
haxelib newrepo
haxelib install all --always
