let attempt = 0;

function log(title, msg) {
  console.groupCollapsed(`%c${title}`, msg.error ? "color:red" : "");
  if (msg.error) console.error(msg.error);
  if (msg.debug) console.debug(msg.debug);
  console.groupEnd();
}

async function dispatch(msg) {
  return browser.runtime.sendMessage(msg).then((resp) => {
    if (resp) {
      if (resp.error) {
        log("Error response", { error: resp });
      } else {
        log("Response", { debug: resp });
      }
    }
  });
}

function apply(script) {
  dispatch({ event: "begin_apply" });

  if (!script) return;

  if (!document.body) {
    attempt++;
    if (attempt >= 5) return;

    setTimeout(function () {
      apply(script);
    }, 200);
    return;
  }

  try {
    eval(script);
    dispatch({ event: "ok" });
  } catch (error) {
    log("Sprinkles failed running your script", { error });
    dispatch({ event: "eval_failed", error: `${error}` });
  }
}

const filename = location.hostname.replace(/^www\./, "") + ".js";

fetch("https://localhost:3133/s/" + filename)
  .then((resp) => resp.text())
  .then(apply)
  .catch((error) => {
    log("Sprinkles failed requesting your scripts", { error });
    dispatch({ event: "request_failed", error: `${error}` });
  });
