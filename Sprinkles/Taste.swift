import Foundation

public class Reducer<A, S> {
    public typealias MoreActions = [A]
    public typealias CallbackFn = (A, inout S) -> (MoreActions?)

    var run: CallbackFn

    init(_ callbackFunction: @escaping CallbackFn) {
        self.run = callbackFunction
    }
}

public typealias UnsubscribeFn = () -> Void

public class Store<A, S> {
    public typealias MoreActions = [A]
    public typealias Subscriber = ((S) -> Void)

    public typealias ReducerCollection = [Reducer<A, S>]
    public typealias SubscriberCollection = [String: Subscriber]

    public var state: S

    public var reducers: ReducerCollection
    public var subscribers: SubscriberCollection

    public var debug = false

    init(_ reducers: ReducerCollection, initialState: S, debug: Bool = false) {
        self.reducers = reducers
        self.state = initialState
        self.subscribers = [:]
        self.debug = debug
    }

    public func dispatch(_ action: A, _ payload: Any?) {
        DispatchQueue.global(qos: .background).async {
            var next: MoreActions = []

            for reducer in self.reducers {
                if let more = reducer.run(action, &self.state) {
                    next.append(contentsOf: more)
                }
            }

            print("Taste:dispatch \t\(Date())\tA:\(action)")
            if self.debug {
                print("\tSTATE:\(self.state)")
            }

           for (_, subscriber) in self.subscribers {
                DispatchQueue.main.async {
                    subscriber(self.state)
                }
            }

            while let action = next.popLast() {
                DispatchQueue.main.async {
                    self.dispatch(action, payload)
                }
            }
        }
    }

    public func dispatch(_ action: A) { dispatch(action, nil) }

    public func subscribe(_ handler: @escaping Subscriber) -> UnsubscribeFn {
        let uuid = UUID().uuidString
        subscribers[uuid] = handler

        handler(state)

        return {
            self.subscribers.removeValue(forKey: uuid)
        }
    }
}
