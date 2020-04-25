//
//  AnswerSheetList.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI

struct AnswerSheetList: View {
    @ObservedObject var test: Test
    var body: some View {
        GeometryReader { g in
            List {
                Section(header: TimerHeader(timer: self.test.timers[0], text: "Section 1")) {
                    ForEach(self.test.questions[0], id: \.self){ question in
                        AnswerSheetRow(question: question) //.disabled( !(self.test.timers[0].started == false && self.test.timers[0].isDone == false) )
                    }
                    
                }
                Section(header: TimerHeader(timer: self.test.timers[1], text: "Section 2")){
                    ForEach(self.test.questions[1], id: \.self){ question in
                        AnswerSheetRow(question:question) //.disabled( !(self.test.timers[1].started && self.test.timers[1].isDone == false) )
                    }
                }
                Section(header: TimerHeader(timer: self.test.timers[2], text: "Section 3")){
                    ForEach(self.test.questions[2], id: \.self){ question in
                        AnswerSheetRow(question:question) //.disabled( !(self.test.timers[2].started && self.test.timers[2].isDone == false) )
                    }
                }
                Section(header: TimerHeader(timer: self.test.timers[3], text: "Section 4")){
                    ForEach(self.test.questions[3], id: \.self){ question in
                        AnswerSheetRow(question:question) //.disabled( !(self.test.timers[3].started && self.test.timers[3].isDone == false) )
                        
                    }
                }
            }.navigationBarItems(trailing: CheckButton(test: self.test))
        }
    }
}

struct TimerHeader: View {
    @ObservedObject var timer: SectionTimer
    var text: String
    var body: some View {
        HStack{
            Text(text)
            Spacer()
            TimerView(timer: timer)
        }.frame(width: 270, height: 35)
    }
}

struct TimerView: View{
    @ObservedObject var timer: SectionTimer
    let uiUpdateTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect() //Changes text ui every 1 second
    //TODO: There is a bug where, if you have a timer going and you go too far away from the view in the scrolling, the timer stops.
    var body: some View {
        
        HStack{
            if (self.timer.started == true && self.timer.isDone == false) {
                Text("\(self.timer.timeLeftFormated.min):\(self.timer.timeLeftFormated.sec) left")
                    .onReceive(uiUpdateTimer){ _ in
                        self.timer.timeLeft += -1
                        if self.timer.timeLeft <= 0 {
                            print("Timer Done")
                            self.timer.endTimer()
                        }
                }.onDisappear(){
                    
                }
            }else if (self.timer.started == false){
                Button(action: {
                    self.timer.startTimer()
                    
                }){
                    Text("Start Section")
                }
            }else if (self.timer.isDone == true){
                Text("Section Over")
            }
        }
        
    }
    
}




struct CheckButton: View{
    @ObservedObject var test: Test
    var body: some View {
        Button(action: {
            
            print(self.test.computedData)
            //print(self.test.computeData())
            //print("WORKIG")
        }){
            Text("Check")
        }
    }
}

struct AnswerSheetList_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSheetList(test: Test(jsonFile: "test1json"))
    }
}
