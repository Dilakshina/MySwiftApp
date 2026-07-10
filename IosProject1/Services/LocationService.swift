//
//  LocationService.swift
//  IosProject1
//
//  Thin wrapper around CLLocationManager so the rest of the app never
//  imports CoreLocation directly. Handles authorization + one-shot lookups.
//
//  Callers (game VMs at end-of-game):
//      LocationService.shared.requestPermission()
//      let coord = LocationService.shared.latestLocation
//
//  MapTab and HomeTab observe the singleton to react to permission changes.
//

import Foundation
import CoreLocation

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    /// Single instance used across the app.
    /// Kept as a singleton so authorization state and manager lifecycle
    /// are shared — creating multiple CLLocationManagers is wasteful.
    static let shared = LocationService()

    /// The current permission state. Published so views can react
    /// (e.g. hide the map when denied, show a "Grant Location" button).
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    /// The most recent coordinate we received from the system.
    /// `nil` until the first fix comes back or permission is granted.
    @Published private(set) var latestLocation: CLLocationCoordinate2D?

    private let manager = CLLocationManager()

    override init() {
        // Snapshot current status before wiring the delegate so the
        // published value is correct on first read.
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - Public API

    /// Prompts the user for "When In Use" permission if not decided.
    /// Safe to call multiple times — the system only shows the dialog once.
    func requestPermission() {
        guard authorizationStatus == .notDetermined else { return }
        manager.requestWhenInUseAuthorization()
    }

    /// Asks for a single location fix. Result arrives on the delegate
    /// callback below and updates `latestLocation`.
    /// Call this at the end of a game — we don't want continuous tracking.
    func requestLocation() {
        guard [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus) else {
            return
        }
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    /// Called by iOS whenever the permission status changes (initial launch,
    /// user tap on Settings, revoke, etc). Mirrors the change into `@Published`.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        // If the user just granted permission, kick off a fetch so we have
        // a coordinate ready for the next game finish.
        if [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus) {
            manager.requestLocation()
        }
    }

    /// Called when a new location is available. Publishes the coordinate
    /// so any observing view or VM can pick it up.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        latestLocation = coord
    }

    /// Called when the fetch failed — timeout, denied, hardware off, etc.
    /// We deliberately swallow the error: a missing coordinate is a valid
    /// state for GameSession (its lat/lon are optional), so nothing crashes.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // no-op — session will simply be recorded without coordinates
    }
}
