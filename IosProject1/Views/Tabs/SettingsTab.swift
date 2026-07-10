//
//  SettingsTab.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.08, blue: 0.20),
                        Color(red: 0.15, green: 0.06, blue: 0.30)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        section(title: "Preferences") {
                            SettingRow(
                                icon: "bell.fill",
                                tint: .red,
                                label: "Notifications"
                            ) {
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                            }

                            Divider().background(.white.opacity(0.1))

                            SettingRow(
                                icon: "speaker.wave.2.fill",
                                tint: .blue,
                                label: "Sound Effects"
                            ) {
                                Toggle("", isOn: $soundEnabled)
                                    .labelsHidden()
                            }
                        }

                        section(title: "About") {
                            SettingRow(
                                icon: "info.circle.fill",
                                tint: .gray,
                                label: "Version"
                            ) {
                                Text("1.0")
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

private struct SettingRow<Trailing: View>: View {
    let icon: String
    let tint: Color
    let label: String
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.callout.bold())
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(label)
                .font(.body)
                .foregroundStyle(.white)

            Spacer()

            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

#Preview {
    SettingsTab()
}
