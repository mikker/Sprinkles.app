import Foundation

public enum Action {
    case setDirectory(URL)
    case serverStateChanged(ServerState)
    case hasCert(Bool)
    case setIsOnboarding(Bool)
}

public struct State {
    var directory = Bookmark.url
    var files: [String] = []
    var serverState: ServerState = .stopped
    var hasCert = JoofCertificate.exists
    var isOnboarding = false
}

public let reducer = Reducer<Action, State> { action, state in
    switch action {

    case .setDirectory(let url):
        state.directory = url

    case .serverStateChanged(let serverState):
        state.serverState = serverState

    case .hasCert(let value):
        state.hasCert = value
        
    case .setIsOnboarding(let value):
        state.isOnboarding = value
    }

    return nil
}

public let store = Store([reducer], initialState: State(), debug: false)
