//
//  PersistentCallHistory.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

public final class PersistentCallHistory {
    fileprivate let origin: CallHistory
    fileprivate let storage: PropertyListStorage

    public init(origin: CallHistory, storage: PropertyListStorage) {
        self.origin = origin
        self.storage = storage
        origin.removeAll()
        load()
    }

    private func load() {
        do {
            try storage.load().forEach({ origin.add(CallHistoryRecord(dictionary: $0)) })
        } catch {
            print("Could not read call history from file: \(error)")
        }
    }
}

extension PersistentCallHistory: CallHistory {
    public var allRecords: [CallHistoryRecord] {
        return origin.allRecords
    }

    public func add(_ record: CallHistoryRecord) {
        origin.add(record)
        save()
    }

    public func remove(_ record: CallHistoryRecord) {
        origin.remove(record)
        save()
    }

    public func removeAll() {
        origin.removeAll()
        do {
            try storage.delete()
        } catch {
            print("Could not delete call history file: \(error)")
        }
    }

    public func updateTarget(_ target: CallHistoryEventTarget) {
        origin.updateTarget(target)
    }

    private func save() {
        do {
            try storage.save(dictionaries(from: origin.allRecords))
        } catch {
            print("Could not save call history to file: \(error)")
        }
    }
}

private extension CallHistoryRecord {
    init(dictionary: [String: Any]) {
        let user = dictionary[userKey] as? String ?? ""
        let host = dictionary[hostKey] as? String ?? ""
        address = ContactAddress(user: user, host: host)
        date = dictionary[dateKey] as? Date ?? Date.distantPast
        duration = dictionary[durationKey] as? Int ?? 0
        isIncoming = dictionary[incomingKey] as? Bool ?? false
        isMissed = dictionary[missedKey] as? Bool ?? false
    }
}

private func dictionaries(from records: [CallHistoryRecord]) -> [[String: Any]] {
    return records.map {
        [
            userKey: $0.address.user,
            hostKey: $0.address.host,
            dateKey: $0.date,
            durationKey: $0.duration,
            incomingKey: $0.isIncoming,
            missedKey: $0.isMissed
        ]
    }
}

private let userKey = "user"
private let hostKey = "host"
private let dateKey = "date"
private let durationKey = "duration"
private let incomingKey = "incoming"
private let missedKey = "missed"
