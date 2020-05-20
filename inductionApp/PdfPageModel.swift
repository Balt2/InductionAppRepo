//
//  PdfPageModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/17/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase
import PencilKit
import Combine

class PageModel: ObservableObject, Hashable, Identifiable {
    static func == (lhs: PageModel, rhs: PageModel) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    var id = UUID()
    @Published var shouldScale = false
         
    @Published var canvas: PKCanvasView?
    var uiImage: UIImage
    var pageID: Int
    
    init(image: UIImage, pageID: Int){
        self.uiImage = image
        self.pageID = pageID
    }
    init(page: PageModel){
        self.uiImage = page.uiImage
        self.pageID = page.pageID
    }
    
    
}

class TestPDF {
    var pages = [PageModel]()
    var pdfName = ""
    
    init(name: String){
        self.pdfName = name
        self.createPages(name: name)
    }
    init(data: Data){
        self.createPages(data: data)
    }
    
    func createPages(name: String){
        var pageCounter = 1
        let path = Bundle.main.path(forResource: name, ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        if let document = CGPDFDocument(url as CFURL) {
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                pages.append(PageModel(image: pdfImage, pageID: pageCounter - 1))
                pageCounter = pageCounter + 1
//                if (pageCounter > 5){ //Get rid of this. Figure out why the PDF file is corrupted
//                    break
//                }
            }
        }
    }
    
    func createPages(data: Data){
        var pageCounter = 1
        let dataProvider = CGDataProvider(data: data as CFData)
        if let document = CGPDFDocument(dataProvider!){
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                pages.append(PageModel(image: pdfImage, pageID: pageCounter - 1))
                pageCounter = pageCounter + 1
            }
        }
    }
    
    private func createUIImage(document: CGPDFDocument, page: Int) -> UIImage?{
        
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