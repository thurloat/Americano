rm js/notes.js
rm js/domready.js

coffee --join js/notes.js --compile ../../scripts/Americano.coffee scripts/notes.coffee 
coffee --join js/domready.js --compile scripts/domready.coffee