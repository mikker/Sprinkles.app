import Foundation
import Criollo
import Regex
import Sentry

func injectStyleElement(_ css: String) -> String {
    return """
    function _joofInjectStyles() {
      var d = document;
      var e = d.createElement('style');
      e.innerHTML = `\(css)`;
      d.body.appendChild(e);
    };
    _joofInjectStyles();
    """
}

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
        server.certificatePath = JoofCertificate.certPath
        server.certificateKeyPath = JoofCertificate.keyPath

        server.delegate = self

        server.mount("/", fileAtPath: Bundle.main.path(forResource: "index", ofType: "html")!)

        server.get("/favicon.ico") { (_, res, _) in res.send(favicon("ico")) }
        server.get("/favicon.png") { (_, res, _) in res.send(favicon("png")) }

        server.get("/[a-zA-Z0-9-\\.]+") { (req, res, _) in
            res.setAllHTTPHeaderFields([
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "text/javascript; charset=utf-8"
            ])

            guard let domain = "/(.*)\\.js".r?.findFirst(in: req.url.path)?.group(at: 1)
                else { return res.send("console.log('Failed parsing domain')") }

            guard let directory = store.state.directory
                else { return res.send("console.log('No joof dir yet?')") }

            let globalJsURL = directory.appendingPathComponent("global.js")
            let jsURL = directory.appendingPathComponent("\(domain).js")
            let globalCssURL = directory.appendingPathComponent("global.css")
            let cssURL = directory.appendingPathComponent("\(domain).css")

            var javascript = [globalJsURL, jsURL].reduce("", { (result, url) in
                return result.appending(";\n\(self.tryReading(url))")
            })
            let css = [globalCssURL, cssURL].reduce("", { (result, url) in
                return result.appending("\n\(self.tryReading(url))")
            })

            if css != "" {
                javascript.append(injectStyleElement(css))
            }

            res.send(javascript)
        }
    }

    public func start(_ port: UInt = 3133) {
        if state != .stopped { return }

        state = .booting

        var error: NSError?

        server.startListening(&error, portNumber: port)
    }

    public func stop() {
        self.server.stopListening()
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

        let event = Event(level: .info)
        event.message = "Server running"
        Client.shared?.send(event: event, completion: nil)
    }
    func serverDidStopListening(_ server: CRServer) {
        Server.instance.state = .stopped

        let event = Event(level: .info)
        event.message = "Server stopped"
        Client.shared?.send(event: event, completion: nil)
    }
}

func favicon(_ ext: String) -> Data {
    let url = Bundle.main.url(forResource: "favicon", withExtension: ext)!

    if cache[url] != nil {
        return cache[url]!
    }

    do {
        let data = try Data(contentsOf: url)
        cache[url] = data
        return (data)
    } catch {
        print(error)
        cache[url] = Data(capacity: 0)
        return cache[url]!
    }
}

var cache: [URL: Data] = [:]
