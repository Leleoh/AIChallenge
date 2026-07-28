// Ref: docs/sdd/CowsAbduction_GameLoop_Spec.md
import Foundation
import AVFoundation
import AppKit

class SoundService {
    static let shared = SoundService()
    
    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []
    
    private init() {}
    
    /// Toca um efeito sonoro (SFX) genérico a partir de um NSDataAsset em Assets.xcassets
    func playSFX(named name: String, volume: Float = 1.0) {
        guard let dataAsset = NSDataAsset(name: name) else {
            print("⚠️ Sound asset '\(name)' não encontrado no Assets.xcassets")
            return
        }
        
        do {
            let player = try AVAudioPlayer(data: dataAsset.data)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            
            // Retém a referência enquanto toca e limpa encerrados
            sfxPlayers.append(player)
            sfxPlayers.removeAll { !$0.isPlaying }
        } catch {
            print("⚠️ Erro ao reproduzir o efeito '\(name)': \(error)")
        }
    }
    
    /// Toca o som do OVNI vinculado a um ID específico para permitir interrupção imediata
    func playUfoSFX(volume: Float = 0.5) -> AVAudioPlayer? {
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
        if bgmPlayer?.isPlaying == true { return } // Mantém se já estiver tocando
        
        guard let dataAsset = NSDataAsset(name: name) else {
            print("⚠️ BGM asset '\(name)' não encontrado no Assets.xcassets")
            return
        }
        
        do {
            bgmPlayer = try AVAudioPlayer(data: dataAsset.data)
            bgmPlayer?.numberOfLoops = -1 // Loop infinito
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
