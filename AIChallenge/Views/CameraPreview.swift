import SwiftUI
import AVFoundation

class PreviewView: NSView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        self.wantsLayer = true
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer?.addSublayer(layer)
        self.previewLayer = layer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        previewLayer?.frame = self.bounds
    }
}

struct CameraPreview: NSViewRepresentable {
    var session: AVCaptureSession
    
    func makeNSView(context: Context) -> PreviewView {
        return PreviewView(session: session)
    }
    
    func updateNSView(_ nsView: PreviewView, context: Context) {
        // Sem atualizações dinâmicas necessárias por agora
    }
}
