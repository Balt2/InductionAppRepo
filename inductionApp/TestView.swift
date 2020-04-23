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
    let pages = testPDF().pages
    @Environment(\.undoManager) var undoManager
            
    var body: some View {
        HStack{
            AnswerSheetList().frame(width: 300)
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

//struct DrawViewUI: UIViewRepresentable {
//    @Binding var drawView: DrawView
//
//    func makeUIView(context: Context) -> DrawView {
//        return drawView
//    }
//
//    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
//}
struct PageView: View{
    var model: PageModel
    @State private var canvas: PKCanvasView = PKCanvasView()
    
    var body: some View {
        ZStack{
            Image(uiImage: model.uiImage).resizable().aspectRatio(contentMode: .fill)
            CanvasRepresentable(canvasToDraw: $canvas)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
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
        while let pdfImage = createUIImage(url: url, page: pageCounter){
            pages.append(PageModel(uiImage: pdfImage, id: pageCounter - 1))
            pageCounter = pageCounter + 1
            if (pageCounter>30){ //TODO: Get rid of this. Figure out why the PDF file is corrupted
                break
            }
        }
    }
    
    func createUIImage(url: URL, page: Int) -> UIImage?{
        
        guard let document = CGPDFDocument(url as CFURL) else {return nil}
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
