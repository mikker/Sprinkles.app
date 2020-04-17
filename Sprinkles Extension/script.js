let attempt = 0;

function log(message, error) {
  console.groupCollapsed(`%c${message}`, "color:red");
  if (error) console.error(error);
  console.groupEnd();
}

function apply(script) {
  if (!script) return;
  
  if (!document.body) {
    attempt++;
    if (attempt >= 5) return;
    
    setTimeout(function() {
      apply(script);
    }, 200);
    return;
  }
  
  try {
    eval(script);
    safari.extension.dispatchMessage("ok")
  } catch (error) {
    log("Sprinkles failed running your script", error)
    safari.extension.dispatchMessage("eval-failed", { error: error.message });
  }
}

const filename = location.hostname.replace(/^www\./, "") + ".js";

fetch("https://localhost:3133/" + filename)
.then(resp => resp.text())
.then(apply)
.catch(error => {
  log("Sprinkles failed requesting your scripts", error)
  safari.extension.dispatchMessage("request-failed", { error: error.message })
});
