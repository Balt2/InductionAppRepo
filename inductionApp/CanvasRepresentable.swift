



import Foundation
import SwiftUI
import PencilKit


struct CanvasRepresentable: UIViewRepresentable {
    //This is the canvas that we are passed from the initailzer and what we draw on
    //@Binding var canvasToDraw: PKCanvasView
    @ObservedObject var question: Question
    var isAnswerSheet: Bool
    
    
    //This checks to see if this instance of the struct is an answer sheet. If it is we want to check location
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var bubbleRects: [CGRect]
        var parent: CanvasRepresentable
        
        init(_ parent: CanvasRepresentable) {
            self.parent = parent
            bubbleRects = [CGRect(x: 44, y: 43.3, width: 20, height: 20), CGRect(x: 99, y: 43.3, width: 20, height: 20), CGRect(x: 153, y: 43.3, width: 20, height: 20), CGRect(x: 207, y: 43.3, width: 20, height: 20)]
            
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            
            //This function is called by the PKCanvasView when it is done being edited

            //UIImageWriteToSavedPhotosAlbum(imageCreated, self.parent, nil, nil)
                        
            if parent.isAnswerSheet {
                for (index,rec) in bubbleRects.enumerated() {
                    let imageCreated = canvasView.drawing.image(from: rec, scale: UIScreen.main.scale)
                    var numberOfPixels = 0
                    for r in (1..<20){
                        for c in (1..<20){
                            if let color = imageCreated[r, c] {
                                var red: CGFloat = 0.0
                                var green: CGFloat = 0.0
                                var blue: CGFloat = 0.0
                                var alpha: CGFloat = 0.0
                                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                if alpha > 0 {
                                    numberOfPixels+=1
                                }
                            }

                        }

                    }
                    print("After looping through points")
                    if numberOfPixels > 100{
                        if (parent.question.currentState == .ommited) {
                            parent.question.userAnswer = String(index)
                            parent.question.currentState = .selected
                            //UIImageWriteToSavedPhotosAlbum(imageCreated, self, nil, nil)
                            print("Selected: \(index)")
                        }else if String(index) != parent.question.userAnswer {
                            parent.question.currentState = .invalidSelection
                        }
                    }


                }

            }
            
            
           
            
        }
        
        
    }
    
    
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let c = question.canvas
        c.isOpaque = false
        c.allowsFingerDrawing = true
        c.delegate = context.coordinator
        return c
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        print("UPDATE VIEW: \(question.location.row)")
        //uiView.drawing = canvasToDraw.drawing
    }
    
    
}



