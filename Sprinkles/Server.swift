import Criollo
import Foundation
import Regex

public enum ServerState {
  case stopped
  case booting
  case running
}

class Server: NSObject {
  static var instance = Server()

  let server = CRHTTPServer()

  var state: ServerState = .stopped {
    didSet { store.dispatch(.serverStateChanged(state)) }
  }

  override init() {
    super.init()

    server.isSecure = true
    server.certificatePath = SprinklesCertificate.certPath
    server.privateKeyPath = SprinklesCertificate.keyPath

    server.delegate = self

    server.mount("/", fileAtPath: Bundle.main.path(forResource: "index", ofType: "html")!)

    server.get("/favicon.ico") { (_, res, _) in res.send(bundleImage("favicon", ext: "ico")) }
    server.get("/favicon.png") { (_, res, _) in res.send(bundleImage("favicon", ext: "png")) }
    server.get("/logo.png") { (_, res, _) in res.send(bundleImage("logo", ext: "png")) }

    server.get("/[a-zA-Z0-9-\\.]+") { (req, res, _) in
      self.handleScriptsReq(req, res)
    }
  }

  public func start(_ port: UInt = 3133) {
    if state != .stopped { return }

    state = .booting

    var error: NSError?

    server.startListening(&error, portNumber: port)

    if error != nil {
      Diagnostics.send("[server]: error -- \(String(describing: error))")
    }
  }

  public func stop() {
    self.server.stopListening()
  }

  private func handleScriptsReq(_ req: CRRequest, _ res: CRResponse) {
    res.setAllHTTPHeaderFields([
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "text/javascript; charset=utf-8",
    ])

    guard let domain = "/(.*)\\.js".r?.findFirst(in: req.url.path)?.group(at: 1)
    else { return res.send("console.log('Failed parsing domain')") }

    let directory = store.state.directory

    let globalJsURL = directory.appendingPathComponent("global.js")
    let jsURL = directory.appendingPathComponent("\(domain).js")
    let globalCssURL = directory.appendingPathComponent("global.css")
    let cssURL = directory.appendingPathComponent("\(domain).css")

    var javascript = [globalJsURL, jsURL].reduce(
      "",
      { (result, url) in
        return result.appending(";\n\(self.tryReading(url))")
      })
    let css = [globalCssURL, cssURL].reduce(
      "",
      { (result, url) in
        return result.appending("\n\(self.tryReading(url))")
      })

    if css != "" {
      javascript.append(injectStyleElement(css))
    }

    res.send(javascript)
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
}

extension Server: CRServerDelegate {
  func serverDidStartListening(_ server: CRServer) {
    Server.instance.state = .running
    Diagnostics.send("[server]: Running")
  }

  func serverDidStopListening(_ server: CRServer) {
    Server.instance.state = .stopped
    Diagnostics.send("[server]: Stopped")
  }
}

var bundeImageCache: [URL: Data] = [:]

func bundleImage(_ name: String, ext: String) -> Data {
  let url = Bundle.main.url(forResource: name, withExtension: ext)!

  if bundeImageCache[url] != nil {
    return bundeImageCache[url]!
  }

  do {
    let data = try Data(contentsOf: url)
    bundeImageCache[url] = data
    return (data)
  } catch {
    print(error)
    bundeImageCache[url] = Data(capacity: 0)
    return bundeImageCache[url]!
  }
}

func injectStyleElement(_ css: String) -> String {
  return """
    function _SprinklesInjectStyles() {
      var d = document;
      var e = d.createElement('style');
      e.innerHTML = `\(css)`;
      d.body.appendChild(e);
    };
    _SprinklesInjectStyles();
    """
}
