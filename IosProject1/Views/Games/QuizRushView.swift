//
//  QuizRushView.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushVM()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.05, blue: 0.30),
                    Color(red: 0.25, green: 0.08, blue: 0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Group {
                switch vm.viewState {
                case .loading:
                    loadingView
                case .failed(let message):
                    errorView(message: message)
                case .loaded:
                    loadedView
                }
            }
            .padding()
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await vm.loadQuestions()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.white)
            Text("Loading questions…")
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.65))

            Button {
                Task { await vm.loadQuestions() }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 12, y: 6)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadedView: some View {
        Group {
            if vm.isFinished {
                finishedView
            } else if let question = vm.currentQuestion {
                questionView(for: question)
            } else {
                Text("No questions available.")
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private func questionView(for question: TriviaQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                statPill(label: "Question", value: "\(vm.currentIndex + 1) / \(vm.questions.count)")
                statPill(label: "Score", value: "\(vm.score)")
                statPill(label: "🔥 Streak", value: "\(vm.streak)")
            }

            ProgressView(value: Double(vm.currentIndex), total: Double(max(vm.questions.count, 1)))
                .tint(.purple)

            Text(question.question.htmlDecoded)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )

            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    Button {
                        withAnimation { vm.submit(answer: answer) }
                    } label: {
                        HStack {
                            Text(answer.htmlDecoded)
                                .font(.callout.bold())
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundStyle(.yellow)

            Text("Quiz Complete!")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(vm.score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }

            Button {
                Task { await vm.loadQuestions() }
            } label: {
                Text("Play Again")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

private extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil).string) ?? self
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
