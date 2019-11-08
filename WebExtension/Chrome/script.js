function apply(script) {
  if (document.body) {
    if (script) {
      try {
        eval(script);
      } catch (e) {
        console.groupCollapsed('%cSprinkles failed eval\'ing your script', 'color:red')
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

const filename = location.hostname.replace(/^www\./, "") + ".js";

fetch('https://localhost:3133/' + filename)
  .then(resp => resp.text())
  .then(apply)
