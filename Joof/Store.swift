import Foundation

public enum Action {
    case setDirectory(URL?)

    case listFiles
    case setFiles([String])

    case serverStateChanged(ServerState)

    case hasCert(Bool)
}

public struct State {
    var directory: URL?
    var files: [String] = []
    var serverState: ServerState = .stopped
    var hasCert = false
}

public let reducer = Reducer<Action, State> { action, state in
    switch action {

    case .setDirectory(let url):
        state.directory = url
        return [.listFiles]

    case .listFiles:
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: state.directory!.path)
            return [.setFiles(files)]
        } catch {
            print(error)
        }

    case .setFiles(let files):
        state.files = files

    case .serverStateChanged(let serverState):
        state.serverState = serverState

    case .hasCert(let has):
        state.hasCert = has
    }

    return nil
}

public let store = Store([reducer], initialState: State(), debug: false)
