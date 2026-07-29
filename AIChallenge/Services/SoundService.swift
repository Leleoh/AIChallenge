// Ref: docs/sdd/AudioSettings_Spec.md
import Foundation
import AVFoundation
import AppKit
import SwiftUI
import Combine

class SoundService: ObservableObject {
    static let shared = SoundService()
    
    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "isMusicEnabled")
            if !isMusicEnabled {
                stopBGM()
            } else {
                playBGM(named: "OST", volume: 0.18)
            }
        }
    }
    
    @Published var isSFXEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSFXEnabled, forKey: "isSFXEnabled")
        }
    }
    
    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []
    
    private init() {
        // Se a chave ainda não existe, padrão é true
        if UserDefaults.standard.object(forKey: "isMusicEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "isMusicEnabled")
        }
        if UserDefaults.standard.object(forKey: "isSFXEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "isSFXEnabled")
        }
        
        self.isMusicEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
        self.isSFXEnabled = UserDefaults.standard.bool(forKey: "isSFXEnabled")
    }
    
    /// Toca um efeito sonoro (SFX) genérico a partir de um NSDataAsset em Assets.xcassets
    func playSFX(named name: String, volume: Float = 1.0) {
        guard isSFXEnabled else { return }
        
        guard let dataAsset = NSDataAsset(name: name) else {
            print("⚠️ Sound asset '\(name)' não encontrado no Assets.xcassets")
            return
        }
        
        do {
            let player = try AVAudioPlayer(data: dataAsset.data)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            
            sfxPlayers.append(player)
            sfxPlayers.removeAll { !$0.isPlaying }
        } catch {
            print("⚠️ Erro ao reproduzir o efeito '\(name)': \(error)")
        }
    }
    
    /// Toca o som do OVNI vinculado a um ID específico para permitir interrupção imediata
    func playUfoSFX(volume: Float = 0.5) -> AVAudioPlayer? {
        guard isSFXEnabled else { return nil }
        guard let dataAsset = NSDataAsset(name: "Ovni") else { return nil }
        do {
            let player = try AVAudioPlayer(data: dataAsset.data)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            return player
        } catch {
            print("⚠️ Erro ao reproduzir som do OVNI: \(error)")
            return nil
        }
    }
    
    /// Toca a música de fundo (BGM) em loop contínuo
    func playBGM(named name: String = "OST", volume: Float = 0.18) {
        guard isMusicEnabled else { return }
        if bgmPlayer?.isPlaying == true { return }
        
        guard let dataAsset = NSDataAsset(name: name) else {
            print("⚠️ BGM asset '\(name)' não encontrado no Assets.xcassets")
            return
        }
        
        do {
            bgmPlayer = try AVAudioPlayer(data: dataAsset.data)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = volume
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
        } catch {
            print("⚠️ Erro ao reproduzir BGM '\(name)': \(error)")
        }
    }
    
    /// Reinicia a música de fundo (BGM) do início (0s)
    func restartBGM(named name: String = "OST", volume: Float = 0.18) {
        stopBGM()
        playBGM(named: name, volume: volume)
    }
    
    /// Para a música de fundo
    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }
}
