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

//Model for individual pdf pages
class PageModel: ObservableObject, Hashable, Identifiable {
    
    static func == (lhs: PageModel, rhs: PageModel) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
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
    
    func reset(){
        canvas = nil
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    
}

//Model for a PDF with multiple pages
class TestPDF: Hashable {
    static func == (lhs: TestPDF, rhs: TestPDF) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var pages = [PageModel]()
    var pdfName = ""
    var testRef: String
    
    init(name: String){
        self.pdfName = name
        self.testRef = "BEN"
        self.createPages(name: name)
    }
    init(data: Data, testRef: String){
        self.testRef = testRef
        let pdfURL = self.getDocumentsDirectory().appendingPathComponent("\(String(describing: testRef))1.jpg")
        if FileManager.default.fileExists(atPath: pdfURL.path){
            print("TRYING TO GET IMAGES FROM DISK!")
            self.createPages()
        }else{
            self.createPages(data: data)
        }
    }
    
    init(pngData: [Data]){
        self.testRef = "BEN"
        self.createPages(fromPNGData: pngData)
    }
    
    func createPages(fromPNGData pngData: [Data]){
        for (index, png) in pngData.enumerated() {
            if let pngImage = UIImage(data: png){
                pages.append(PageModel(image: pngImage, pageID: index + 1))
            }
        }
    }
    
    func createPages(name: String){
        var pageCounter = 1
        let path = Bundle.main.path(forResource: name, ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        if let document = CGPDFDocument(url as CFURL) {
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                print("Creating image: \(pageCounter)")
                pages.append(PageModel(image: pdfImage, pageID: pageCounter - 1))
                pageCounter = pageCounter + 1
            }
        }
    }
    
    func createPages(){
        var pageCounter = 1
        var pdfURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef)1.jpg")
        while FileManager.default.fileExists(atPath: pdfURL.path){
            do{
                let imageData = try Data(contentsOf: pdfURL)
                let imageTest = UIImage(data: imageData)
                guard let pdfImage = imageTest else {
                    pageCounter = pageCounter + 1
                    pdfURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef + String(pageCounter)).jpg")
                    return
                }
                pages.append(PageModel(image: pdfImage, pageID: pageCounter - 1))
                print("GOT PAGE AT: \(pageCounter) from the file")
            }catch{
                print("ERROR GETTING IMAGE AT: \(pdfURL)")
            }
            
            pageCounter = pageCounter + 1
            pdfURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef + String(pageCounter)).jpg")
        }
    }
    
    func createPages(data: Data){
        var pageCounter = 1
        let dataProvider = CGDataProvider(data: data as CFData)
        if let document = CGPDFDocument(dataProvider!){
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                print("Creating image: \(pageCounter)")
                
                pages.append(PageModel(image: pdfImage, pageID: pageCounter - 1))
                
                if let imageD = pdfImage.jpegData(compressionQuality: 0.8){
                    print("GOT INTO WRITE PDFIMAGE PNG DATA")
                    let filename = getDocumentsDirectory().appendingPathComponent("\(testRef + String(pageCounter)).jpg")
                    print(filename)
                    try? imageD.write(to: filename)
                    print("SUCSSES WRITING PDFIMAGE PNG DATA")
                }
                
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
    
    func hash(into hasher: inout Hasher){
        hasher.combine(pages)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
