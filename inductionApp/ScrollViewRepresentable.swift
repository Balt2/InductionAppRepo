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








class PageCell: UICollectionViewCell {
    private static let reuseId = "pageCell"
    var imageView: UIImageView?

    static func registerWithCollectionView(collectionView: UICollectionView) {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: reuseId)
    }

    static func getReusedCellFrom(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PageCell{
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! PageCell
    }

//    var pageView: UIImageView = {
//        let view = UIImageView(image: image)
//        return view
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("DHSLDFJSDF")
        //contentView
        contentView.addSubview(self.imageView!)

        imageView!.translatesAutoresizingMaskIntoConstraints = false

        imageView!.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView!.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView!.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not been implemented")
    }
}

struct CollectionViewRepresentable: UIViewRepresentable {
    @ObservedObject var currentSection: TestSection

    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator

        PageCell.registerWithCollectionView(collectionView: collectionView)
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        //
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
            self.parent.currentSection.pages.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = PageCell.getReusedCellFrom(collectionView: collectionView, cellForItemAt: indexPath)
            let imageView = UIImageView(image: parent.currentSection.pages[indexPath.row].uiImage)
            
            let c = PKCanvasView(frame: imageView.frame)
            c.isOpaque = false
            c.allowsFingerDrawing = false
            //c.isScrollEnabled = true
            parent.currentSection.pages[indexPath.row].canvas = c
            imageView.addSubview(c)
            
            cell.imageView = imageView
            print("HELLO WORLD")
            return cell
        }

        // MARK: UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width / 3
            return CGSize(width: width, height: width)
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
