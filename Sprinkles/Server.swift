import Defaults
import Foundation
import Regex
import Telegraph

public enum ServerState {
  case stopped
  case booting
  case running
}

class Server {
  static var instance = Server()

  let headers: HTTPHeaders = [
    .accessControlAllowOrigin: "*", .contentType: "text/javascript; charset=utf-8",
  ]
  var server: Telegraph.Server?

  var state: ServerState = .stopped {
    didSet { store.dispatch(.serverStateChanged(state)) }
  }

  public func start(_ port: Int = 3133) {
    if state != .stopped { return }

    state = .booting

    guard let caCert = Certificate(derURL: URL(fileURLWithPath: SprinklesCertificate.caPath)) else {
      print("no ca cert")
      stop()
      return
    }

    guard
      let identity = CertificateIdentity(
        p12URL: URL(fileURLWithPath: SprinklesCertificate.p12Path), passphrase: Defaults[.userId]!)
    else {
      print("no p12 cert")
      stop()
      return
    }

    let server = Telegraph.Server(identity: identity, caCertificates: [caCert])

    server.route(.GET, "/s/*", handleScriptsReq)
    server.serveBundle(.main, "/")

    do {
      try server.start(port: port)
    } catch {
      print(error)
      stop()
    }

    state = .running
    self.server = server
  }

  public func stop() {
    server?.stop()
  }

  func serverDidStop(_ server: Server, error: Error?) {
    state = .stopped

    if let error = error {
      print(error)
    }
  }

  private func handleScriptsReq(request: HTTPRequest) -> HTTPResponse {
    guard let domain = "/s\\/(.*)\\.js".r?.findFirst(in: request.uri.path)?.group(at: 1)
    else {
      return HTTPResponse(.unprocessableEntity, content: "console.log('Failed parsing domain')")
    }

    guard let directory = store.state.directory else {
      return HTTPResponse(.internalServerError, content: "console.log('No scripts directory set')")
    }

    let globalJsURL = directory.appendingPathComponent("global.js")
    let jsURL = directory.appendingPathComponent("\(domain).js")
    let globalCssURL = directory.appendingPathComponent("global.css")
    let cssURL = directory.appendingPathComponent("\(domain).css")

    var javascript = [globalJsURL, jsURL].reduce(
      "",
      { (result, url) in
        return result.appending(";\n\(tryReading(url))")
      })
    let css = [globalCssURL, cssURL].reduce(
      "",
      { (result, url) in
        return result.appending("\n\(tryReading(url))")
      })

    if css != "" {
      javascript.append(injectStyleElement(css))
    }

    return HTTPResponse(HTTPStatus.ok, headers: headers, content: javascript)
  }
}

private func tryReading(_ url: URL) -> String {
  if FileManager.default.fileExists(atPath: url.path) {
    do {
      return try String(contentsOf: url)
    } catch {
      print(error)
    }
  }

  return ""
}

func injectStyleElement(_ css: String) -> String {
  return """
    function _SprinklesInjectStyles() {
      var d = document;
      var e = d.createElement('style');
      e.dataset.sprinklesInjected = 1;
      e.innerHTML = `\(css)`;
      d.body.appendChild(e);
    };
    _SprinklesInjectStyles();
    """
}
