function apply(script) {
    if (document.body) {
        if (script) {
            try {
                eval(script);
            } catch (e) {
                console.groupCollapsed('%cjoof failed eval\'ing your script', 'color:red')
                console.error(e)
                console.groupEnd()
            }
        }
    } else {
        setTimeout(function() {
                   apply(script);
                   }, 200);
    }
}

var xhr = new XMLHttpRequest();
var filename = location.hostname.replace(/^www\./, "") + ".js";

xhr.open("get", "https://localhost:3133/" + filename, true);
xhr.responseType = "text";
xhr.onload = function(event) {
    apply(this.responseText);
};
xhr.send();
