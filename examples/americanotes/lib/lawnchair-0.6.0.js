var Lawnchair=function(){if(!JSON)throw"JSON unavailable! Include http://www.json.org/json2.js to fix.";if(!(arguments.length<=2&&arguments.length>0))throw"Incorrect # of ctor args!";var a=typeof arguments[0]=="function"?arguments[0]:arguments[1],b=typeof arguments[0]=="function"?{}:arguments[0];if(typeof a!="function")throw"No callback was provided";this.record=b.record||"record",this.name=b.name||"records";var c;if(b.adapter)c=Lawnchair.adapters[Lawnchair.adapters.indexOf(b.adapter)],c=c.valid()?c:undefined;else for(var d=0,e=Lawnchair.adapters.length;d<e;d++){c=Lawnchair.adapters[d].valid()?Lawnchair.adapters[d]:undefined;if(c)break}if(!c)throw"No valid adapter.";for(var f in c)this[f]=c[f];for(var d=0,e=Lawnchair.plugins.length;d<e;d++)Lawnchair.plugins[d].call(this);this.init(b,a)};Lawnchair.adapters=[],Lawnchair.adapter=function(a,b){b.adapter=a;var c="adapter valid init keys save batch get exists all remove nuke".split(" ");for(var d in b)if(c.indexOf(d)===-1)throw"Invalid adapter! Nonstandard method: "+d;Lawnchair.adapters.push(b)},Lawnchair.plugins=[],Lawnchair.plugin=function(a){for(var b in a)b==="init"?Lawnchair.plugins.push(a[b]):this.prototype[b]=a[b]},Lawnchair.prototype={isArray:Array.isArray||function(a){return Object.prototype.toString.call(a)==="[object Array]"},lambda:function(a){return this.fn(this.record,a)},fn:function(a,b){return typeof b=="string"?new Function(a,b):b},uuid:function(){var a=function(){return((1+Math.random())*65536|0).toString(16).substring(1)};return a()+a()+"-"+a()+"-"+a()+"-"+a()+"-"+a()+a()+a()},each:function(a){var b=this.lambda(a);if(this.__results)for(var c=0,d=this.__results.length;c<d;c++)b.call(this,this.__results[c],c);else this.all(function(a){for(var c=0,d=a.length;c<d;c++)b.call(this,a[c],c)});return this}},Lawnchair.adapter("webkit-sqlite",function(){var a=function(a,b){console.log("error in sqlite adaptor!",a,b)},b=function(){return new Date};Function.prototype.bind||(Function.prototype.bind=function(a){var b=[].slice,c=b.call(arguments,1),d=this,e=function(){},f=function(){return d.apply(this instanceof e?this:a||{},c.concat(b.call(arguments)))};e.prototype=d.prototype,f.prototype=new e;return f});return{valid:function(){return!!window.openDatabase},init:function(b,c){var d=this,e=d.fn(d.name,c),f="CREATE TABLE IF NOT EXISTS "+this.name+" (id NVARCHAR(32) UNIQUE PRIMARY KEY, value TEXT, timestamp REAL)",g=e.bind(this);this.db=openDatabase(this.name,"1.0.0",this.name,65536),this.db.transaction(function(b){b.executeSql(f,[],g,a)})},keys:function(b){var c=this.lambda(b),d=this,e="SELECT id FROM "+this.name+" ORDER BY timestamp DESC";this.db.transaction(function(b){var f=function(a,b){if(b.rows.length==0)c.call(d,[]);else{var e=[];for(var f=0,g=b.rows.length;f<g;f++)e.push(b.rows.item(f).id);c.call(d,e)}};b.executeSql(e,[],f,a)});return this},save:function(c,d){var e=this,f=c.key||e.uuid(),g="INSERT INTO "+this.name+" (value, timestamp, id) VALUES (?,?,?)",h="UPDATE "+this.name+" SET value=?, timestamp=? WHERE id=?",i=function(){d&&(c.key=f,e.lambda(d).call(e,c))},j=[b(),f];e.exists(c.key,function(b){e.db.transaction(function(d){var e=function(b){j.unshift(JSON.stringify(b)),d.executeSql(g,j,i,a)},f=function(b){delete b.key,j.unshift(JSON.stringify(b)),d.executeSql(h,j,i,a)};b?f(c):e(c)})});return this},batch:function(a,b){var c=[],d=!1,e=this,f=function(b){c.push(b),d=c.length===a.length},g=setInterval(function(){d&&(b&&e.lambda(b).call(e,c),clearInterval(g))},200);for(var h=0,i=a.length;h<i;h++)this.save(a[h],f);return this},get:function(b,c){var d=this,e="";this.isArray(b)?e="SELECT id, value FROM "+this.name+" WHERE id IN ('"+b.join("','")+"')":e="SELECT id, value FROM "+this.name+" WHERE id = '"+b+"'";var f=function(a,e){var f=null,g=[];if(e.rows.length)for(var h=0,i=e.rows.length;h<i;h++)f=JSON.parse(e.rows.item(h).value),f.key=e.rows.item(h).id,g.push(f);d.isArray(b)||(g=g.length?g[0]:null),c&&d.lambda(c).call(d,g)};this.db.transaction(function(b){b.executeSql(e,[],f,a)});return this},exists:function(b,c){var d="SELECT * FROM "+this.name+" WHERE id = ?",e=this,f=function(a,b){c&&e.fn("exists",c).call(e,b.rows.length>0)};this.db.transaction(function(c){c.executeSql(d,[b],f,a)});return this},all:function(b){var c=this,d="SELECT * FROM "+this.name,e=[],f=this.fn(this.name,b)||undefined,g=function(a,b){if(b.rows.length!=0)for(var d=0,g=b.rows.length;d<g;d++){var h=JSON.parse(b.rows.item(d).value);h.key=b.rows.item(d).id,e.push(h)}f&&f.call(c,e)};this.db.transaction(function(b){b.executeSql(d,[],g,a)});return this},remove:function(b,c){var d=this,e=typeof b=="string"?b:b.key,f="DELETE FROM "+this.name+" WHERE id = ?",g=function(){c&&d.lambda(c).call(d)};this.db.transaction(function(b){b.executeSql(f,[e],g,a)});return this},nuke:function(b){var c="DELETE FROM "+this.name,d=this,e=b?function(){d.lambda(b).call(d)}:function(){};this.db.transaction(function(b){b.executeSql(c,[],e,a)});return this}}}())