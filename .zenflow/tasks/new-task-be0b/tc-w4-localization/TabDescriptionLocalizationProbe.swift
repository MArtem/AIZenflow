import Foundation

@main
struct TabDescriptionLocalizationProbe {
    static func main() {
        guard let language = ProcessInfo.processInfo.arguments.dropFirst().first,
              ["en", "ru"].contains(language),
              let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            print("FAIL: exact language resource bundle unavailable")
            exit(1)
        }
        guard Bundle.main.preferredLocalizations.first == language else {
            print("FAIL: requested process language not selected: \(Bundle.main.preferredLocalizations)")
            exit(1)
        }
        for tab in AppTab.allCases {
            let expectedKey = "tab.\(tab.rawValue).stubDescription"
            let sentinel = "__probe_missing__"
            let expected = localizedBundle.localizedString(forKey: expectedKey, value: sentinel, table: "Localizable")
            guard expected != sentinel, !expected.isEmpty else {
                print("FAIL: existing translation unavailable for \(expectedKey)")
                exit(1)
            }
            // Exercise the unchanged app facade and actual property; no copied lookup implementation.
            let actual = tab.placeholderDescription
            guard actual == expected else {
                print("FAIL: wrong language/key result for \(tab.rawValue)")
                exit(1)
            }
            print("PASS \(language) \(tab.rawValue)")
        }
        print("RESULT: 5/5 exact app-property/resource lookups PASS")
    }
}
