//
//  MapTab.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $position)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapTab()
}
