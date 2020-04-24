



import Foundation
import SwiftUI
import PencilKit


struct CanvasRepresentable: UIViewRepresentable {
    //This is the canvas that we are passed from the initailzer and what we draw on
    @Binding var canvasToDraw: PKCanvasView
    @ObservedObject var question: Question
    var isAnswerSheet: Bool
    
    //This checks to see if this instance of the struct is an answer sheet. If it is we want to check location
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var bubbleRects = [CGRect(x: 37, y: 34.0, width: 20, height: 20), CGRect(x: 87, y: 34.0, width: 20, height: 20), CGRect(x: 137, y: 34.0, width: 20, height: 20), CGRect(x: 187, y: 34.0, width: 20, height: 20)]
        var parent: CanvasRepresentable
        
        init(_ parent: CanvasRepresentable) {
            self.parent = parent
            
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            //This function is called by the PKCanvasView when it is done being edited
            
            if parent.isAnswerSheet {
                for (index,rec) in bubbleRects.enumerated() {
                    let imageCreated = canvasView.drawing.image(from: rec, scale: 4.0)
                    var numberOfPixels = 0
                     for r in (1..<20){
                        for c in (1..<20){
                            if let colorSpace = imageCreated.getColor(at: CGPoint(x: r, y: c)){
                                if colorSpace.cgColor.alpha > 0 {
                                    numberOfPixels = numberOfPixels + 1
                                    print("Index: \(index)")
                                    print(numberOfPixels)
                                    
                                }
                                //print(colorSpace.cgColor.alpha)
                            }
                            
                        }
                        //UIImageWriteToSavedPhotosAlbum(imageCreated, self, nil, nil)
                    }
                    print("After looping through points")
                    if numberOfPixels > 100{
                        if (parent.question.currentState == .ommited) {
                            parent.question.userAnswer = String(index)
                            parent.question.currentState = .selected
                            print("Selected: \(index)")
                        }else{
                            parent.question.currentState = .invalidSelection
                        }
                    }else{
                        numberOfPixels = 0
                    }

                    
                }

            }
           
            
        }
        
        
    }
    
    
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let c = PKCanvasView()
        c.isOpaque = false
        c.allowsFingerDrawing = true
        c.delegate = context.coordinator
        return c
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        print("UPDATE VIEW")
    }
    
    
}



