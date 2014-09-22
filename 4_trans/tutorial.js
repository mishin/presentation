netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect'); 

var ifile = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);

ifile.initWithPath("/usr/lib/firefox/browser/extensions/translate.sqlite");

if(!(ifile.exists())){

alert('does not exist');

} 

http://javascript.ru/forum/css-html-firefox-mizilla/13718-executeasync-sqlite-firefox-extension.html
