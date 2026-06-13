import Foundation

enum PersistenceManager {
    static func characterBest(for character: CharacterType) -> Double {
        UserDefaults.standard.double(forKey: characterBestKey(for: character))
    }

    static func record(distance: Double, for character: CharacterType) {
        let key = characterBestKey(for: character)
        UserDefaults.standard.set(max(distance, UserDefaults.standard.double(forKey: key)), forKey: key)
    }

    static func setValues(_ values: Set<String>, for key: String) {
        UserDefaults.standard.set(values.sorted().joined(separator: ","), forKey: key)
    }

    static func values(for key: String, defaults: Set<String>) -> Set<String> {
        guard let stored = UserDefaults.standard.string(forKey: key), !stored.isEmpty else { return defaults }
        return Set(stored.split(separator: ",").map(String.init))
    }

    private static func characterBestKey(for character: CharacterType) -> String {
        "bestDistance.\(character.rawValue)"
    }
}
