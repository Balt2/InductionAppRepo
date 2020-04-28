



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
            if parent.isAnswerSheet == true{
                for i in 0..<4 {
                    let rect = CGRect(x: parent.protoRect.width * (CGFloat(i) + 1) - 10, y: parent.protoRect.height - 10, width: parent.protoRect.minX, height: parent.protoRect.minX)
                    self.bubbleRects[parent.question.answerLetters[i]] = rect
                }
            }
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            
            //This function is called by the PKCanvasView when it is done being edited

            //UIImageWriteToSavedPhotosAlbum(imageCreated, self.parent, nil, nil)
                        
            if parent.isAnswerSheet == true {
                checkAnswerSheet(canvasView: canvasView)
            }
            
        }
        
        func checkAnswerSheet(canvasView: PKCanvasView){
            for (question,rec) in bubbleRects {
                print(rec)
                //print(canvasView.drawing.bounds
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
                print("After looping through points: \(numberOfPixels)")
                if numberOfPixels > 100{
                    print("LOTS OF PIXELS")
                    if (parent.question.currentState == .ommited) {
                        parent.question.userAnswer = question
                        parent.question.currentState = .selected
                        print("Selected: \(question)")
                        
                    }else if !parent.question.userAnswer.contains(question){
                        parent.question.userAnswer.insert(contentsOf: question, at: parent.question.userAnswer.startIndex)
                        parent.question.currentState = .invalidSelection
                        
                    }
                }else if (parent.question.userAnswer.contains(question)) {
                    parent.question.userAnswer = parent.question.userAnswer.replacingOccurrences(of: question, with: "")
                    if parent.question.userAnswer.count > 1 { //There are more than one still selected
                        parent.question.currentState = .invalidSelection
                    } else if parent.question.userAnswer.count == 1 { //There is one selected
                        parent.question.currentState = .selected
                    } else{ //There are non selected
                        parent.question.currentState = .ommited
                    }
                }

            }
        }
        
        
    }
    
    
    
    
    func makeCoordinator() -> Coordinator {
        print("Make Coordinator")
        return Coordinator(self)
        
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        if isAnswerSheet {
            print("Make UIVIEW")
            let c = question.canvas
            c.isOpaque = false
            c.allowsFingerDrawing = true
            c.delegate = context.coordinator
            return c
        }else{
            let c = PKCanvasView()
            c.isOpaque = false
            c.allowsFingerDrawing = true
            c.delegate = context.coordinator
            return c
        }
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        print("UPDATE VIEW: \(question.location.row)")

    }
    
    
}




struct CanvasRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

extension UIImage {
    subscript (x: Int, y: Int) -> UIColor? {
        guard x >= 0 && x < Int(size.width) && y >= 0 && y < Int(size.height),
            let cgImage = cgImage,
            let provider = cgImage.dataProvider,
            let providerData = provider.data,
            let data = CFDataGetBytePtr(providerData) else {
            return nil
        }

        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

        let r = CGFloat(data[pixelData]) / 255.0
        let g = CGFloat(data[pixelData + 1]) / 255.0
        let b = CGFloat(data[pixelData + 2]) / 255.0
        let a = CGFloat(data[pixelData + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

