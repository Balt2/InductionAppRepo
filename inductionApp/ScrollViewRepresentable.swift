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



//TO make correct CollectionViewRepresentable Steps.
//1. Look at how PKCanvasView is implemented normally
//2. Set the controller of the canvas view to the CollectionView controller and implement any funcitons
//3. look at how UIViewRepresentable is implemented for UITable view or Scroll or anything that has cells rather than whole view controllers as subclasses.
class PageCell: UICollectionViewCell, PKCanvasViewDelegate {
    
    private static let reuseId = "pageCell"
    //INFORMATION ABOUT SPECIFIC PAGE
    //TEST SECTION
    var testSection: TestSection?
    //WHAT PAGE IS THIS
    var pageIndex: Int?
    //LOGIC FOR REPRESENTABLS
    static func registerWithCollectionView(collectionView: UICollectionView) {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: reuseId)
        
    }
    //GIVING THE CELL THE INFORMATION ABOUT THE PAGE
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
    
    
    //INITAILZING VIEWS THAT WILL GO IN EACH CELL
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
        //UIVIEW STUFF
        
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
    //THE COLLECTION VIEW REPRESENTABLE THAT WE PUT ALL OUR COLLECTION VIEW PAGE CELLS IN
    //INFORMATION ABOTU THE TEST
    @ObservedObject var test: Test
    //SHOULD THE USER BE ABLE TO SCROLL (IF NOT THEN THEY CAN DRAW WITH THEIR FINGERS
    @Binding var twoFingerScroll: Bool
    //SCROLL TO THE TOP WHEN THEY START A NEW SECTION AND THE PDF IMAGES CHANGE
    @Binding var scrollToTop: Bool
    @EnvironmentObject var orientationInfo: OrientationInfo
    
    
    func makeUIView(context: Context) -> UICollectionView {
        
        let collectionLayout = UICollectionViewFlowLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
       // collectionView.backgroundColor = .yellow
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        PageCell.registerWithCollectionView(collectionView: collectionView)
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context){
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
        //RELOAD THE DATA IN THE COLLECTION VIEW
        uiView.reloadData()
        
    }
    
    
    
    

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        
        let parent: CollectionViewRepresentable

        init(_ collectionViewRepresentable: CollectionViewRepresentable) {
            self.parent = collectionViewRepresentable
            
        }

        // MARK: UICollectionViewDataSource

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

            return self.parent.test.currentSection!.pages.count
            
        }
        

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            if parent.test.currentSection!.pages[indexPath.row].canvas == nil{
                parent.test.currentSection!.pages[indexPath.row].canvas = PKCanvasView()
            }
            
            let cell = PageCell.getReusedCellFrom(collectionView: collectionView, cellForItemAt: indexPath, currentSection: parent.test.currentSection!)

            
            cell.imageView.image = parent.test.currentSection!.pages[indexPath.row].uiImage
            return cell
        }

        // MARK: UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            return CGSize(width: width-20, height: (width-20)*1.294) //Aspect ratio of each pdf image
        }
    }
}

