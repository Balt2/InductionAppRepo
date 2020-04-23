



import Foundation
import SwiftUI
import PencilKit


struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasToDraw: PKCanvasView
    
//    class Coordinator: NSObject {
//        @Binding var canvasToDraw: PKCanvasView?
//
//        init(canvasToDraw: Binding<UIImage?>){
//            _canvasToDraw = canvasToDraw
//        }
//
////        @objc func drawingImageChanged(_ sender: CanvasView) {
////          self.drawingImage = sender.drawingImage
////        }
//    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let c = PKCanvasView()
        c.isOpaque = false
        c.allowsFingerDrawing = true
        return c
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
    
    
}
