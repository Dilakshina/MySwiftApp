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
        VStack {
            switch vm.viewState {
            case .loading:
                loadingView
            case .failed(let message):
                errorView(message: message)
            case .loaded:
                loadedView
            }
        }
        .navigationTitle("Quiz Rush")
        .task {
            await vm.loadQuestions()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading questions…")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await vm.loadQuestions() }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
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
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func questionView(for question: TriviaQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Q\(vm.currentIndex + 1) / \(vm.questions.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Score: \(vm.score)")
                    .font(.subheadline.bold())
                Text("🔥 \(vm.streak)")
                    .font(.subheadline)
            }

            Text(question.question)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            ForEach(question.allAnswers, id: \.self) { answer in
                Button {
                    vm.submit(answer: answer)
                } label: {
                    Text(answer)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding()
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Text("Quiz Complete!")
                .font(.largeTitle.bold())
            Text("Final Score: \(vm.score)")
                .font(.title2)
            Button("Play Again") {
                Task { await vm.loadQuestions() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
