let attempt = 0

function apply(script) {
    if (!script) { return }
    
    if (!document.body) {
        attempt++;
        if (attempt >= 5) return;
        
        setTimeout(function() { apply(script); }, 200);
        return;
    }
    
    try {
        eval(script);
    } catch (e) {
        console.groupCollapsed('%cSprinkles failed eval\'ing your script', 'color:red')
        console.error(e)
        console.groupEnd()
    }
}

const filename = location.hostname.replace(/^www\./, "") + ".js";

fetch('https://localhost:3133/' + filename)
.then(resp => resp.text())
.then(apply)
