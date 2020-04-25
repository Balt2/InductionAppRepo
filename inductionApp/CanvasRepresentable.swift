



import Foundation
import SwiftUI
import PencilKit


struct CanvasRepresentable: UIViewRepresentable {
    //This is the canvas that we are passed from the initailzer and what we draw on
    //@Binding var canvasToDraw: PKCanvasView
    @ObservedObject var question: Question
    var isAnswerSheet: Bool
    var protoRect: CGRect
    
    //This checks to see if this instance of the struct is an answer sheet. If it is we want to check location
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var bubbleRects = [String: CGRect]()
        var parent: CanvasRepresentable
        
        init(_ parent: CanvasRepresentable) {
            self.parent = parent
            
            for i in 0..<4 {
                let rect = CGRect(x: parent.protoRect.width * (CGFloat(i) + 1) - 10, y: parent.protoRect.height - 10, width: parent.protoRect.minX, height: parent.protoRect.minX)
                self.bubbleRects[parent.question.answerLetters[i]] = rect
            }
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            
            //This function is called by the PKCanvasView when it is done being edited

            //UIImageWriteToSavedPhotosAlbum(imageCreated, self.parent, nil, nil)
                        
            if parent.isAnswerSheet {
                
                for (question,rec) in bubbleRects {
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
                            parent.question.userAnswer = question
                            parent.question.currentState = .selected
                            print("Selected: \(question)")
                            //parent.question.checkAnswer() //This fuunction should only be called when they check their ansnwers.
                        }else if question != parent.question.userAnswer {
                            parent.question.currentState = .invalidSelection
                            //parent.question.checkAnswer() //This fuunction should only be called when they check their ansnwers.
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
        
        //When the view is pushed back on too the stack this funciton is called
        //print("UPDATE VIEW: \(question.location.row)")
    }
    
    
}



