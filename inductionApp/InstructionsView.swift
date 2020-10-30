//
//  InstructionsView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/12/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI


struct InstructionScroll: View {
    var imageNames: [String]
    @Binding var page: Int
    var body: some View {
        ScrollView {
            if #available(iOS 14.0, *) {
                LazyHStack{
                    InstructionPageView(imageNames: imageNames, page: self.$page)
                }
            }else{
                // Fallback on earlier versions
            }
        }
    }
}


struct InstructionPageView: View {
    var imageNames: [String]
    @Binding var page : Int
    var body: some View {
        if #available(iOS 14.0, *) {
            TabView(selection: self.$page) {
                ForEach(0..<imageNames.count) { i in
                    ZStack {
                        //Text("BEN")
                        Image(imageNames[i]).resizable().aspectRatio(contentMode: .fit)
                    }.clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    .tag(i)
                }
                .padding(.all, 10)
            }
            .frame(width: UIScreen.main.bounds.width * 0.6, height: 500)
            .tabViewStyle(PageTabViewStyle())
        } else {
            // Fallback on earlier versions
        }
    }
}


struct PagedUIScrollView : UIViewRepresentable {
    
    
    func makeCoordinator() -> Coordinator {
        
        return PagedUIScrollView.Coordinator(parent1: self)
    }
    var imageNames: [String]
    var size : CGSize
    @Binding var page : Int
    
    func makeUIView(context: Context) -> UIScrollView{
        
        // ScrollView Content Size...
        
        let total = size.width * CGFloat(imageNames.count)
        let view = UIScrollView()
        view.isPagingEnabled = true
        //1.0  For Disabling Vertical Scroll....
        view.contentSize = CGSize(width: total, height: 1.0)
        view.bounces = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = context.coordinator
        
        // Now Going to  embed swiftUI View Into UIView...
        
        let view1 = UIHostingController(rootView: InstructionList(page: self.$page, imageNames: self.imageNames, size: self.size))
        view1.view.frame = CGRect(x: 0, y: 0, width: total, height: self.size.height)
        view1.view.backgroundColor = .clear
        
        view.addSubview(view1.view)
        
        return view
        
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
    }
    
    class Coordinator : NSObject,UIScrollViewDelegate{
        
        
        var parent : PagedUIScrollView
        
        init(parent1: PagedUIScrollView) {
            
        
            parent = parent1
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            
            // Using This Function For Getting Currnet Page
            // Follow Me...
//            CGFloat width = scrollView.frame.size.width;
//            NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
            
            let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            print("PAGE VALUE: \(page)")
            self.parent.page = page
        }
    }
}

struct InstructionList : View {
     
     @Binding var page : Int
     var imageNames: [String]
    var size: CGSize
     var body: some View{
         
         HStack(spacing: 0){
             
            ForEach(imageNames, id: \.self){image in
                 
                     
                 // Mistakenly Used Geomtry Reader...
                Image(image).resizable().aspectRatio(contentMode: .fit)
                
                //.padding(10)
                 //Card(page: self.$page, width: UIScreen.main.bounds.width, data: i)
             }
         }
     }
 }


