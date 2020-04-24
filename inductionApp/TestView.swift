//
//  TestView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI
import PencilKit

struct TestView: View {
    @EnvironmentObject var tests: TestList
    let pages = testPDF().pages
    @ObservedObject var testData = Test(jsonFile: "test1json")
    
    
    
            
    var body: some View {
        ZStack {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(.black)
        HStack{
            AnswerSheetList(test: testData).frame(width: 300)
            ScrollView { 
                VStack {
                    ForEach(pages, id: \.self){ page in
                        PageView(model: page)
                        
                    }
                }
                }
            }
        }
    }
}

struct PageView: View{
    var model: PageModel
    @State private var canvas: PKCanvasView = PKCanvasView()
    
    var body: some View {
        
        ZStack{
            Image(uiImage: model.uiImage).resizable().aspectRatio(contentMode: .fill)
            
            CanvasRepresentable(canvasToDraw: $canvas, question: Question(q: QuestionFromJson(id: "", satSub: "", sub: "", answer: "", reason: ""), ip: IndexPath(row: 0, section: 0)), isAnswerSheet: false)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static let tests = TestList()
    static var previews: some View {
        TestView().environmentObject(tests)
    }
}




struct PageModel: Hashable {
    var uiImage: UIImage
    var id: Int
}

class testPDF {
    var pages = [PageModel]()
    
    init(){
        var pageCounter = 1
        let path = Bundle.main.path(forResource: "pdf_sat-practice-test-1", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        if let document = CGPDFDocument(url as CFURL) {
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                pages.append(PageModel(uiImage: pdfImage, id: pageCounter - 1))
                pageCounter = pageCounter + 1
                if (pageCounter>30){ //TODO: Get rid of this. Figure out why the PDF file is corrupted
                    break
                }
            }
        }
    }
    
    func createUIImage(document: CGPDFDocument, page: Int) -> UIImage?{
        
        guard let page = document.page(at: page) else {return nil}


        let pageRect = page.getBoxRect(.mediaBox) //Media box
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image{ ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y : -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        return img
        
    }
    
    
    
}

extension UIImage {
  func getColor(at location: CGPoint) -> UIColor? {
    guard let cgImage = cgImage,
      let dataProvider = cgImage.dataProvider,
      let pixelData = dataProvider.data else {
        return nil
    }
    let scale = UIScreen.main.scale
    let pixelLocation = CGPoint(x: location.x * scale,
                                y: location.y * scale)
    
    let pixel = cgImage.bytesPerRow * Int(pixelLocation.y) +
      cgImage.bitsPerPixel / 8 * Int(pixelLocation.x)
    guard pixel < CFDataGetLength(pixelData) else {
      print("WARNING: mismatch of pixel data")
      return nil
    }
    guard let pointer = CFDataGetBytePtr(pixelData) else {
      return nil
    }
    func convert(_ color: UInt8) -> CGFloat {
      return CGFloat(color) / 255.0
    }
    let red = convert(pointer[pixel])
    let green = convert(pointer[pixel + 1])
    let blue = convert(pointer[pixel + 2])
    let alpha = convert(pointer[pixel + 3])
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}

