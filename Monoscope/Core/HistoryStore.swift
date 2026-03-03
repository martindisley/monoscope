//
//  HistoryStore.swift
//  Monoscope
//
//  Persists browsing history
//

import Foundation

struct HistoryEntry: Codable {
    let id: UUID
    let urlString: String
    let title: String?
    let visitedAt: Date

    var url: URL? {
        URL(string: urlString)
    }

    var displayTitle: String {
        if let title, !title.isEmpty {
            return title
        }
        if let url = url {
            return url.host ?? url.absoluteString
        }
        return urlString
    }
}

final class HistoryStore {
    static let shared = HistoryStore()

    private let maxEntries = 100
    private let maxMenuEntries = 20
    private let defaultsKey = "MonoscopeHistoryEntries"
    private var entriesCache: [HistoryEntry] = []

    private init() {
        load()
    }

    func add(url: URL, title: String?) {
        let scheme = url.scheme?.lowercased() ?? ""
        guard scheme == "http" || scheme == "https" else { return }

        let urlString = url.absoluteString
        if entriesCache.first?.urlString == urlString {
            return
        }

        entriesCache.removeAll { $0.urlString == urlString }
        let entry = HistoryEntry(
            id: UUID(),
            urlString: urlString,
            title: title,
            visitedAt: Date()
        )
        entriesCache.insert(entry, at: 0)

        if entriesCache.count > maxEntries {
            entriesCache.removeLast(entriesCache.count - maxEntries)
        }

        save()
    }

    func entries(limitToMenu: Bool = false) -> [HistoryEntry] {
        if limitToMenu {
            return Array(entriesCache.prefix(maxMenuEntries))
        }
        return entriesCache
    }

    func clear() {
        entriesCache.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else {
            entriesCache = []
            return
        }
        if let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            entriesCache = decoded
        } else {
            entriesCache = []
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entriesCache) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
