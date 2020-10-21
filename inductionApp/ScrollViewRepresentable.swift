//
//  ScrollViewRepresentable.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/22/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

//
import Foundation
import SwiftUI
import PencilKit
import UIKit



//TO make correct CollectionViewRepresentable Steps. Currently We use introspect
//1. Look at how PKCanvasView is implemented normally
//2. Set the controller of the canvas view to the CollectionView controller and implement any funcitons
//3. look at how UIViewRepresentable is implemented for UITable view or Scroll or anything that has cells rather than whole view controllers as subclasses.
class PageCell: UICollectionViewCell, PKCanvasViewDelegate {
    private static let reuseId = "pageCell"
    //var imageView: UIImageView?
    var testSection: TestSection?
    var pageIndex: Int?
    static func registerWithCollectionView(collectionView: UICollectionView) {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: reuseId)
        
    }

    static func getReusedCellFrom(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, currentSection: TestSection) -> PageCell{
        print("WHAT ABOUT HIS>")
        let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! PageCell
        newCell.testSection = currentSection
        newCell.pageIndex = indexPath.row
        newCell.canvasView.drawing = currentSection.pages[indexPath.row].canvas!.drawing
        newCell.canvasView.tool = currentSection.pages[indexPath.row].canvas!.tool
        //newCell.canvasView.tool = currentSection.
        
        return newCell
    }
    
    

    var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var canvasView: PKCanvasView = {
        let view = PKCanvasView()
        return view
    }()
    
    //var canvasView = PKCanvasView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("IS THIS BEING RUN EVERY TIE?")
        canvasView.frame = frame
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.imageView)
        contentView.addSubview(self.canvasView)
        
        NSLayoutConstraint.activate([
                    canvasView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    canvasView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    canvasView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    canvasView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                ])
        
        
        
        
        imageView.contentMode = .scaleAspectFill
        
        
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        //canvasView.backgroundColor = .clear
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .anyInput
        } else {
            canvasView.allowsFingerDrawing = true
        }
        canvasView.tool =  PKInkingTool(.pen, color: .black, width: 1)
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.isScrollEnabled = false
        
        
        
        
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not been implemented")
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.testSection?.pages[self.pageIndex!].canvas!.drawing = canvasView.drawing
       print("CANVAS DRAWIG")
        
    }
}

struct CollectionViewRepresentable: UIViewRepresentable {
    @ObservedObject var test: Test
    @Binding var twoFingerScroll: Bool
    @Binding var scrollToTop: Bool
    
    
    func makeUIView(context: Context) -> UICollectionView {
        
        let collectionLayout = UICollectionViewFlowLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
       // collectionView.backgroundColor = .yellow
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        PageCell.registerWithCollectionView(collectionView: collectionView)
        print("HELLO?")
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        print("UPDATE UIVIEW")
        
        if !self.twoFingerScroll{
            uiView.panGestureRecognizer.minimumNumberOfTouches = 2
        }else{
            uiView.panGestureRecognizer.minimumNumberOfTouches = 1
        }
        
        if self.test.currentSection!.allotedTime - self.test.currentSection!.sectionTimer.timeRemaining < 0.5{
            uiView.scrollToTop(adjustedContentOffset: 0)
            //self.scrollToTop = false
        }
        
        uiView.reloadData()
        
    }
    
    
    
    

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        
        let parent: CollectionViewRepresentable

        init(_ collectionViewRepresentable: CollectionViewRepresentable) {
            self.parent = collectionViewRepresentable
            print("BENSDFSDFSDGS")
            
        }

        // MARK: UICollectionViewDataSource

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print("PAGES IN COLLECTION VIEW")
            print(self.parent.test.name)
            print(self.parent.test.currentSection!.pages.count)
            return self.parent.test.currentSection!.pages.count
            
        }
        

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            if parent.test.currentSection!.pages[indexPath.row].canvas == nil{
                parent.test.currentSection!.pages[indexPath.row].canvas = PKCanvasView()
            }
            
            let cell = PageCell.getReusedCellFrom(collectionView: collectionView, cellForItemAt: indexPath, currentSection: parent.test.currentSection!)

            
            cell.imageView.image = parent.test.currentSection!.pages[indexPath.row].uiImage
            print(indexPath.row)
            print("HELLO WORLD")
            return cell
        }

        // MARK: UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            return CGSize(width: width-20, height: (width-20)*1.294) //Aspect ratio of each pdf image
        }
    }
}




//
//struct CollectionViewRepresentable: UIViewRepresentable {
//    @ObservedObject var currentSection: TestSection
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> UICollectionView  {
//        UICollectionViewFlowLayout
//        let collectionView = UICollectionView(f)
//
//        for page in currentSection.pages {
//            let collectionCell = UICollectionViewCell()
//            let imageSubview = UIImageView(image: page.uiImage)
//            let c = PKCanvasView(frame: imageSubview.frame)
//            c.isOpaque = false
//            c.allowsFingerDrawing = false
//            //c.isScrollEnabled = true
//            page.canvas = c
//            imageSubview.addSubview(c)
//            collectionCell.addSubview(imageSubview)
//            collectionView.addSubview(collectionCell)
//
//        }
//        collectionView.backgroundColor = .blue
//
//
//        return collectionView
//    }
//
//    func updateUIView(_ uiView: UICollectionView, context: Context) {
//        print("BEN")
//        // code to update scroll view from view state, if needed
//    }
//
//    class Coordinator: NSObject {
//        var collectionView: CollectionViewRepresentable
//
//        init(_ collectionView: CollectionViewRepresentable) {
//            self.collectionView = collectionView
//        }
//
//    }
//
//
//}
//
//
