//
//  QuizRushView.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushVM()
    @AppStorage("quizRushHighScore") private var highScore = 0
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Premium background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.22),
                    Color(red: 0.06, green: 0.04, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await vm.loadQuestions()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.purple)
            
            Text("Fetching Live Trivia...")
                .font(.headline)
                .foregroundColor(.purple)
            
            Text("Connecting to Open Trivia Database")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple)
                .shadow(color: .purple.opacity(0.4), radius: 10)
            
            Text("Connection Failed")
                .font(.title2).bold()
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                Task { await vm.loadQuestions() }
            } label: {
                Label("Retry Connection", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(25)
                    .shadow(color: .purple.opacity(0.3), radius: 8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loaded Content Switcher
    private var loadedView: some View {
        Group {
            if vm.isFinished {
                finishedView
                    .onAppear {
                        if vm.score > highScore {
                            highScore = vm.score
                        }
                    }
            } else if let question = vm.currentQuestion {
                questionView(for: question)
            } else {
                VStack(spacing: 16) {
                    Text("No Questions Available")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                    Button("Reload") {
                        Task { await vm.loadQuestions() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    // MARK: - Question View
    private func questionView(for question: TriviaQuestion) -> some View {
        VStack(spacing: 24) {
            // Stats Header Row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "number.circle.fill")
                        .foregroundColor(.purple)
                    Text("Q: \(vm.currentIndex + 1) / \(vm.questions.count)")
                        .foregroundColor(.white)
                }
                .font(.subheadline.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)

                Spacer()

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(vm.score)")
                            .foregroundColor(.white)
                    }
                    
                    if vm.streak > 0 {
                        HStack(spacing: 4) {
                            Text("🔥")
                            Text("\(vm.streak)")
                                .foregroundColor(.white)
                        }
                        .scaleEffect(vm.streak > 3 ? 1.15 : 1.0)
                        .animation(.spring(), value: vm.streak)
                    }
                }
                .font(.subheadline.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
            .padding(.horizontal)

            // Custom progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .frame(
                            width: geometry.size.width * CGFloat(vm.currentIndex) / CGFloat(max(1, vm.questions.count)),
                            height: 8
                        )
                        .animation(.spring(), value: vm.currentIndex)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)

            // Category card
            Text(question.category.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(2)
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.15))
                .cornerRadius(8)

            // Question Main Card
            VStack {
                Text(question.question)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal)

            Spacer()

            // Shuffled Answer Buttons
            VStack(spacing: 16) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    let isSelected = vm.selectedAnswer == answer
                    let isCorrect = answer == question.correctAnswer
                    
                    Button {
                        if !vm.isSubmitting {
                            let correct = answer == question.correctAnswer
                            if !correct {
                                // Trigger red shake animation
                                withAnimation(.linear(duration: 0.08).repeatCount(5, autoreverses: true)) {
                                    shakeOffset = 10
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    shakeOffset = 0
                                }
                            }
                            Task {
                                await vm.submit(answer: answer)
                            }
                        }
                    } label: {
                        HStack {
                            Text(answer)
                                .font(.body.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            Group {
                                if isSelected {
                                    isCorrect ? Color.green : Color.red
                                } else if vm.selectedAnswer != nil && isCorrect {
                                    // Highlight the correct answer if the user picked wrong
                                    Color.green.opacity(0.4)
                                } else {
                                    Color.white.opacity(0.06)
                                }
                            }
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected 
                                    ? (isCorrect ? Color.green : Color.red) 
                                    : (vm.selectedAnswer != nil && isCorrect ? Color.green.opacity(0.5) : Color.white.opacity(0.12)),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.isSubmitting)
                    .opacity(vm.isSubmitting && !isSelected && !(vm.selectedAnswer != nil && isCorrect) ? 0.4 : 1.0)
                    .offset(x: isSelected && !isCorrect ? shakeOffset : 0)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .padding(.vertical)
    }

    // MARK: - Finished Summary View
    private var finishedView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Score circle animation
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 16)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(vm.score) / CGFloat(max(100, vm.score))) // Simple ratio circle
                    .stroke(
                        AngularGradient(
                            colors: [.purple, .indigo, .purple],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.4), radius: 8)
                    
                    Text("\(vm.score)")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Points")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                Text("Quiz Complete!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(feedbackMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Stats Row
            HStack(spacing: 40) {
                VStack(spacing: 6) {
                    Text("High Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(highScore)")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 6) {
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(vm.score > 0 ? Int((Double(vm.score) / 210.0) * 100) : 0)%")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
            
            Spacer()
            
            Button {
                Task { await vm.loadQuestions() }
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.4), radius: 10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }

    private var feedbackMessage: String {
        if vm.score >= 180 {
            return "Incredible! You are a trivia master!"
        } else if vm.score >= 120 {
            return "Great job! Very impressive knowledge!"
        } else if vm.score >= 60 {
            return "Good effort! Keep playing to improve."
        } else {
            return "Better luck next time! Trivia can be tough."
        }
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
