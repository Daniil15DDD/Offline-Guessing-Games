import AVFoundation

/// Plays plain sine tones. Used by Pitch Match for its notes and by Beat
/// Keeper for its clicks. Nothing is loaded from disk: the wave is computed
/// as it plays.
final class TonePlayer {
    static let shared = TonePlayer()

    private let engine = AVAudioEngine()
    private var source: AVAudioSourceNode?
    private var sampleRate = 44_100.0
    private var isReady = false

    // Read by the audio thread while it renders.
    private var frequency = 440.0
    private var targetVolume = 0.0
    private var volume = 0.0
    private var phase = 0.0

    private var stopWork: DispatchWorkItem?

    private init() {}

    /// Plays one tone. A tone that is already playing is replaced.
    func play(frequency: Double, duration: Double) {
        guard prepare() else { return }
        self.frequency = frequency
        targetVolume = 0.25
        stopWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.targetVolume = 0
        }
        stopWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }

    func stop() {
        stopWork?.cancel()
        targetVolume = 0
    }

    /// Builds the audio graph the first time a tone is needed. Returns false
    /// if audio could not be started, in which case the games stay silent.
    private func prepare() -> Bool {
        if isReady {
            if !engine.isRunning {
                try? engine.start()
            }
            return engine.isRunning
        }

        do {
            // Playback keeps the tones audible when the ring switch is on
            // silent, because these games cannot be played without sound.
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // Carry on: the engine may still work with the default session.
        }

        let outputRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        if outputRate > 0 {
            sampleRate = outputRate
        }
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return false
        }

        let node = AVAudioSourceNode { [unowned self] _, _, frameCount, audioBufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let step = 2 * Double.pi * self.frequency / self.sampleRate
            for frame in 0..<Int(frameCount) {
                // Ease the volume so tones start and stop without a click.
                self.volume += (self.targetVolume - self.volume) * 0.003
                let sample = Float(sin(self.phase) * self.volume)
                self.phase += step
                if self.phase > 2 * Double.pi {
                    self.phase -= 2 * Double.pi
                }
                for buffer in buffers {
                    let samples = UnsafeMutableBufferPointer<Float>(buffer)
                    if frame < samples.count {
                        samples[frame] = sample
                    }
                }
            }
            return noErr
        }

        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        source = node

        do {
            try engine.start()
            isReady = true
            return true
        } catch {
            return false
        }
    }
}
