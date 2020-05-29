



import Foundation
import SwiftUI
import PencilKit


struct CanvasRepresentable: UIViewRepresentable {
    //This is the canvas that we are passed from the initailzer and what we draw on
    //@Binding var canvasToDraw: PKCanvasView
    
    @ObservedObject var question: Question
    @ObservedObject var page: PageModel
    var section: TestSection? //TODO: Should be observed Object?
    var isAnswerSheet: Bool
    var protoRect: CGRect
    var canvasGeo: CGSize
    
    
    //This checks to see if this instance of the struct is an answer sheet. If it is we want to check location
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var bubbleRects = [String: CGRect]()
        var parent: CanvasRepresentable
        
        init(_ parent: CanvasRepresentable) {
            //print("Init Represenatable")
            self.parent = parent
            if parent.isAnswerSheet == true && parent.question.isACTMath == false{
                for i in 0..<4 {
                    let rect = CGRect(x: 54 + parent.protoRect.width * (CGFloat(i)) - 10, y: parent.protoRect.height - 10, width: parent.protoRect.minX, height: parent.protoRect.minX)
                    self.bubbleRects[parent.question.answerLetters[i]] = rect
                }
            }else if parent.isAnswerSheet == true{
                for i in 0..<5 {
                    let rect = CGRect(x: 54 + parent.protoRect.width * (CGFloat(i)) - 10, y: parent.protoRect.height - 10, width: parent.protoRect.minX, height: parent.protoRect.minX)
                    self.bubbleRects[parent.question.answerLetters[i]] = rect
                }
            }
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
           //print("Canvas View Did Change")
            //This function is called by the PKCanvasView when it is done being edited

            //UIImageWriteToSavedPhotosAlbum(imageCreated, self.parent, nil, nil)
            
            if parent.isAnswerSheet == true {
                checkAnswerSheet(canvasView: canvasView)
            }
        }
        
        func checkAnswerSheet(canvasView: PKCanvasView){
            for (question,rec) in bubbleRects {
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
                    if (parent.question.currentState == .ommited) {
                        parent.question.userAnswer = question
                        parent.question.currentState = .selected
                        parent.question.secondsToAnswer += parent.section!.sectionTimer.timeDelta
                        
                        //Logic to set the order Answered in. The numbers will have jumps
                        //but the order will represent the correct order based on erasing as well
                        parent.section!.numAnsweredQuestions += 1
                        parent.question.answerOrdredIn += parent.section!.numAnsweredQuestions
                        print("Selected: \(question)")
                        
                    //They are trying to answer more than one values
                    }else if !parent.question.userAnswer.contains(question){
                        parent.question.userAnswer.insert(contentsOf: question, at: parent.question.userAnswer.startIndex)
                        parent.question.currentState = .invalidSelection
                        
                    }
                //Maybe using eraser
                }else if (parent.question.userAnswer.contains(question)) {
                    parent.question.userAnswer = parent.question.userAnswer.replacingOccurrences(of: question, with: "")
                    if parent.question.userAnswer.count > 1 { //There are more than one still selected
                        parent.question.currentState = .invalidSelection
                    } else if parent.question.userAnswer.count == 1 { //There is one selected
                        //We want to add time becuase they have indicated an answer to the question
                        parent.question.secondsToAnswer += parent.section!.sectionTimer.timeDelta
                        parent.question.currentState = .selected
                        
                        //Logic to set the order Answered in. The numbers will have jumps
                        //but the order will represent the correct order based on erasing as well
                        parent.section!.numAnsweredQuestions += 1
                        parent.question.answerOrdredIn += parent.section!.numAnsweredQuestions
                        
                    } else{ //There are non selected
                        parent.question.currentState = .ommited
                        
                    }
                }

            }
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        //question.coordinator =
        //print("Made Coordinator")
        return Coordinator(self)
        
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        print("Make UIView")
        //if isAnswerSheet {
        if question.canvas == nil && isAnswerSheet == true {
            let c = PKCanvasView()
            c.isOpaque = false
            c.allowsFingerDrawing = true
            c.tool = PKInkingTool(.pen, color: .black, width: 1)
            c.delegate = context.coordinator
            question.canvas = c
            print("ONE")
            return c
        }else if isAnswerSheet == true{
            let c = question.canvas!
            c.delegate = context.coordinator
            c.tool = PKInkingTool(.pen, color: .black, width: 1)
            question.canvas = c
            print("TWO")
            return c
        }else if page.canvas == nil {
            let c = PKCanvasView()
            c.isOpaque = false
            c.allowsFingerDrawing = true
            c.tool = PKInkingTool(.pen, color: .black, width: 1)
            c.isScrollEnabled = false
            print("THREE")
            c.delegate = context.coordinator
            page.canvas = c
            return c
        }else{
            let c = page.canvas!
            c.delegate = context.coordinator
            c.tool = PKInkingTool(.pen, color: .black, width: 1)
            page.canvas = c
            print("FOUR")
            return c
        }
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
//        print(tool.width)
//        uiView.tool
//        uiView.tool = PKInkingTool(.pen, color: .black, width: 0.2)
//        tool = uiView.tool as! PKInkingTool
//        print(tool.width)
       
        
//        if isAnswerSheet == true{
//           // uiView.layer.addSublayer(question.canvas!.layer)
//
//            if question.canvas == nil{
//                print("NILLL VIEW")
//                //question.canvas = uiView
//            }else if question.canvas != uiView{
//                print("DIFFFERENT VIEW")
//            }
//            if question.canvas?.delegate == nil{
//                print("Nill Delgate")
//                question.canvas?.delegate = context.coordinator
//            }
//
////            if question.canvas?.delegate as! Coordinator != context.coordinator{
////
////                print("Different Coordinator")
////                //question.canvas?.delegate = context.coordinator
////            }
////
//
//
////            print("UPDATE VIEW")
////            print(uiView)
////            print(question.canvas)
////
////            print(context.coordinator)
////            print(question.canvas?.delegate)
//        }
        if page.pageID != -1 { //It is a real page rather than a question
            
            let scale = (x: CGFloat(canvasGeo.width) / uiView.bounds.size.width, y: CGFloat(canvasGeo.height) / uiView.bounds.size.height)
//            print("CANVAS GEO: \(canvasGeo)")
//            print("View sent: \(uiView.bounds)")
//            print("Canvas View: \(page.canvas?.bounds)")
//            print("Drawing View: \(uiView.drawing.bounds)")
//            print("Page View: \(page.uiImage.size)")
//            print("SCALE: \(scale) ")
            if page.shouldScale == true && scale.x != CGFloat(1.0) {
                page.canvas?.drawing.transform(using: CGAffineTransform(scaleX: scale.x , y: scale.y))
                page.shouldScale = false
            }
            
        }
        
       //print("UPDATE VIEW: \(question.location.row)")
        //context.coordinator =

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

// custom inking tool
class MyInkingTool : PKInkingToolReference {
    override class func defaultWidth(forInkType inkType: __PKInkType) -> CGFloat {
        return 1
    }

    override class func maximumWidth(forInkType inkType: __PKInkType) -> CGFloat {
        return 1
    }

    override class func minimumWidth(forInkType inkType: __PKInkType) -> CGFloat {
        return 1
    }
}



