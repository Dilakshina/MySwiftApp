//
//  GameSession.swift
//  IosProject1
//
//  A single completed play. Persisted to UserDefaults as JSON.
//  Owned by: Models. Written by: game VMs on completion.
//  Read by: StatsVM (charts, aggregates), MapTab (markers).
//

import Foundation
import CoreLocation

/// One completed game — the atomic unit of history in PlayHub.
///
/// Sessions are append-only. Every finish creates a new record so the
/// Stats tab can compute totals/averages and the Map tab can pin plays.
struct GameSession: Codable, Identifiable, Hashable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date

    /// Location is optional because the user may deny permission or be
    /// offline. Games must still finish successfully in that case.
    let latitude: Double?
    let longitude: Double?

    init(
        id: UUID = UUID(),
        mode: GameMode,
        score: Int,
        timestamp: Date = Date(),
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension GameSession {
    /// Convenience: builds a MapKit-friendly coordinate when location is present.
    /// Returns `nil` when latitude/longitude are missing so callers can skip
    /// rendering markers instead of crashing on default `(0, 0)` values.
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
