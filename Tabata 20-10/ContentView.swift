import SwiftUI
import AVFoundation
import AudioToolbox

struct ContentView: View {
        @State private var isActive = false
        @State private var isWorkInterval = true
        @State private var secondsRemaining = 20
        @State private var totalSecondsElapsed = 0
        @State private var timer: Timer?
        @State private var audioPlayer: AVAudioPlayer?

        let workInterval = 20
        let restInterval = 10

        init() {
            setupAudioSession()
        }

    var body: some View {
        VStack(spacing: 30) {
                Text("Total Time: \(formatTime(totalSecondsElapsed))")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(isWorkInterval ? "Exercise" : "Rest")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("\(secondsRemaining)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .padding()

                HStack(spacing: 20) {
                    Button(action: { self.isActive.toggle() }) {
                        Text(isActive ? "Pause" : "Start")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(isActive ? Color.red.opacity(0.5) : Color.green.opacity(0.8))
                            .cornerRadius(40)
                            .foregroundColor(.white)
                            .font(.title2)
                    }

                    Button(action: { self.resetTimer() }) {
                        Text("Reset")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(40)
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 130)

            Spacer()

        .onAppear {
            setupAudioPlayer()
            setupTimer()
        }
        .onChange(of: isActive, perform: { active in
            if active {
                self.startTimer()
            } else {
                self.pauseTimer()
            }

        })
        .onChange(of: isWorkInterval, perform: { _ in
            self.playBeep()
        })

    }


    func setupTimer() {
        resetTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
                self.totalSecondsElapsed += 1
            } else {
                self.isWorkInterval.toggle()
                self.secondsRemaining = self.isWorkInterval ? self.workInterval : self.restInterval
            }
        }
    }

    func pauseTimer() {
        timer?.invalidate()
    }

    func resetTimer() {
        timer?.invalidate()
        isWorkInterval = true
        secondsRemaining = workInterval
        totalSecondsElapsed = 0
    }

    func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 3600) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "m4a") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Unable to initialize audio player: \(error.localizedDescription)")
        }
    }

    private func playBeep() {
        audioPlayer?.play()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
