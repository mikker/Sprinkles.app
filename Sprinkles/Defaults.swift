import Cocoa
import Defaults

extension Defaults.Keys {
  static let userId = Key<String?>("userId")
  static let hasOnboarded = Key<Bool>("hasOnboarded", default: false)

  static let showPreferencesOnLaunch = Key<Bool>("showPreferencesOnLaunch", default: true)
}
