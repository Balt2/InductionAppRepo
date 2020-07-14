//
//  PerformanceDataModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 6/8/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import SwiftUI
import PencilKit

class AllACTData{
    
    var allTestData: [ACTFormatedTestData]?
    var sectionNames: [String]?
    var higherSectionNames: [String]? //SAT only has math and english while act should have all for sub sections for this
    var overallPerformance: BarData?
    var sectionsOverall: [String: BarData]?
    var isACT: Bool
    init(tests: [ACTFormatedTestData], isACT: Bool){
        if tests.count > 0{
            self.isACT = isACT
            let tempTests = tests.sorted(by: {$0.dateTaken! < $1.dateTaken!})
            for (index, test) in tempTests.enumerated(){
                test.createData(index: index)
            }
            self.allTestData = tempTests //TODO: Two many loops
            print("CHECKING SECTION NAMES")
            print(self.allTestData![0].act)
            print(self.allTestData![0].sectionsOverall)
            print(self.allTestData![0].sectionsOverall.map{$0.key})
            self.sectionNames = Array(self.allTestData![0].subSectionGraphs.keys)
            self.higherSectionNames = self.allTestData![0].sectionsOverall.map{$0.key}
            self.createSelf(user: nil)
        }else{
            self.isACT = isACT
            print("Invalid Creation of AllACTDATA: No tests")
        }
    }
    
    func addTest(test: ACTFormatedTestData, user: User){
        print("IN ADD TEST")
        print("ALLTESTDATA NOT NIL")
        self.allTestData!.append(test)
        
        print("CREATING SELF")
        self.createSelf(user: user)
    }
    
    func createSelf(user: User?){
        print("CREATE SELF!")
        DispatchQueue.global(qos: .utility).async {
            var overallBarData = BarData(
                title: self.isACT ? "ACT Performance" : "SAT Performance",
                xAxisLabel: "Dates",
                yAxisLabel: "Score",
                yAxisSegments: 4,
                yAxisTotal: self.isACT ? 36 : 1600,
                barEntries: [])
            var sectionEntries = [String: [BarEntry]]()
            for test in self.allTestData!{
                overallBarData.barEntries.append(test.overall!)
                for (key, sectionData) in test.sectionsOverall{
                    if sectionEntries[key] == nil{
                        sectionEntries[key] = [sectionData]
                    }else{
                        sectionEntries[key]!.append(sectionData)
                    }
                }
            }
            var sectionGraphs = [String: BarData]()
            
            for (section, entries) in sectionEntries{
                let tempGraph = BarData(
                    title: "\(self.isACT ? "ACT" : "SAT") \(section) Performance",
                    xAxisLabel: "Dates",
                    yAxisLabel: "Score",
                    yAxisSegments: 4,
                    yAxisTotal: self.isACT ? 36 : 1600,
                    barEntries: entries)
                sectionGraphs[section] = tempGraph
            }
            
            
            
            DispatchQueue.main.sync {
                self.overallPerformance = overallBarData
                self.sectionsOverall = sectionGraphs
                if user != nil {
                    print("SETTING PERFORAMNCE BACK")
                    user?.getPerformanceDataComplete = true
                }
            }
        }
    }
}




class ACTFormatedTestData: Test{
    
    //    static func == (lhs: ACTFormatedTestData, rhs: ACTFormatedTestData) -> Bool {
    //        return lhs.id == rhs.id
    //    }
    //
    //    var id = UUID() //DELETE
    //    var name: String //DELETE
    //var testPDF = [PageModel]() //DELETE
    
    
    var overall: BarEntry? //BarEntry(xLabel: date, yEntries: ([height: overallScore], orange)
    //var overallTime: BarEntry //BarEntry(xLabel: date, yEntries: ([height: time], orange)
    var sectionsOverall = [String: BarEntry]() //(SectionName, Entry for the section)
    var subSectionGraphs = [String: BarData]() //(SectionName, BarData)
    var subSectionTime = [String: BarData]()
    var tutorPDF: TestPDF
    
    
    init(data: Data, index: Int, tutorPDFName: String) {
        self.tutorPDF = TestPDF(name: tutorPDFName)
        super.init(jsonData: data)
        //self.createData(index: index)
        //self.resetQuestions()
    }
    
    //For corrections
    func resetQuestions(){
        for section in self.sections{
            for question in section.questions{
                if question.finalState != .right {
                    question.userAnswer = ""
                    question.finalState = .omitted // sets teh current state
                }
            }
            section.inkingTool = PKInkingTool(.pen, color: .red, width: 1)
        }
    }
    
    
    func createData(index: Int){
        self.overall = BarEntry(
            xLabel: "\(self.testFromJson!.dateTaken!)",
            yEntries: [(height: CGFloat(self.overallScore),
                        color: Color("salmon"))],
            index: index)

        
        //Only for SAT:
        if self.act == false{
            let englishSectionEntry = BarEntry(
            xLabel: "\(testFromJson!.dateTaken!)",
                yEntries: [(height: CGFloat(self.englishScore!),
                        color: Color("salmon"))],
            index: index)
            sectionsOverall["English"] = englishSectionEntry
            let mathSectionEntry = BarEntry(
            xLabel: "\(testFromJson!.dateTaken!)",
                yEntries: [(height: CGFloat(self.mathScore!), //TODO Sometime mathScore will crash bc its nil
                        color: Color("salmon"))],
            index: index)
            sectionsOverall["Math"] = mathSectionEntry
        }
        
        for section in self.sections{
            
            print("PRINGTING SECTION NAME")
            print(section.name)
            var data = [String:(r: CGFloat, w: CGFloat, o: CGFloat)]()
            var timingDataYTotal: CGFloat = 0
            var timingData = BarData(
                title: "\(section.name): Timing by Question",
                xAxisLabel: "Question #",
                yAxisLabel: "Seconds",
                yAxisSegments: 8,
                yAxisTotal: 0,
                barEntries: [])
            //Only for ACT because all 4 sections have their own scaled score
            if self.act == true{
                let subSectionEntry = BarEntry(
                    xLabel: "\(testFromJson!.dateTaken!)",
                    yEntries: [(height: CGFloat(section.scaledScore!),
                                color: Color("salmon"))],
                    index: index)
                sectionsOverall[section.name] = subSectionEntry
            }
            for question in section.questions{
                let secondsToAnswerTemp = CGFloat(question.secondsToAnswer)
                timingDataYTotal = timingDataYTotal < secondsToAnswerTemp ? secondsToAnswerTemp : timingDataYTotal

                switch question.finalState{
                case .right:
                    if data[question.officialSub] != nil{
                        data[question.officialSub]?.r+=1
                    }else{
                        data[question.officialSub] = (r:1, w: 0, o: 0)
                    }
                    
                    let barEntryTiming = BarEntry(
                        xLabel: String(question.location.row + 1),
                        yEntries: [(height: secondsToAnswerTemp,
                                    color: Color.green)])
                    timingData.barEntries.append(barEntryTiming)
                case .wrong:
                    if data[question.officialSub] != nil{
                        data[question.officialSub]?.w+=1
                    }else{
                        data[question.officialSub] = (r:0, w: 1, o: 0)
                    }
                    let barEntryTiming = BarEntry(
                        xLabel: String(question.location.row + 1),
                        yEntries: [(height: secondsToAnswerTemp,
                                    color: Color.red)])
                    timingData.barEntries.append(barEntryTiming)
                case .omitted: //omitted
                    if data[question.officialSub] != nil{
                        data[question.officialSub]?.o+=1
                    }else{
                        data[question.officialSub] = (r:0, w: 0, o: 1)
                    }
                    let barEntryTiming = BarEntry(
                        xLabel: String(question.location.row + 1),
                        yEntries: [(height: 0, color: Color.gray)])
                    timingData.barEntries.append(barEntryTiming)
                default:
                    print("Impossible Question State")
                }
            }
            timingData.yAxisTotal = Int(timingDataYTotal + 10) //TODO: Make a global variable with the radius of the scatter plot circles
            subSectionTime[section.name] = timingData
            
            var barData = BarData(
                title: "\(section.name) by sub section",
                xAxisLabel: "Categories",
                yAxisLabel: "Questions",
                yAxisSegments: 5,
                yAxisTotal: 0,
                barEntries: [])
            var yAxisMax = 0
            for (subSectionString, values) in data{
                let totalInSubSection = Int(values.r +  values.w + values.o)
                yAxisMax = yAxisMax < totalInSubSection ? totalInSubSection : yAxisMax
                let barEntry = BarEntry(
                    xLabel: subSectionString,
                    yEntries: [(height: values.r, color: Color.green),
                               (height: values.w, color: Color.red),
                               (height: values.o, color: Color.gray)])
                
                barData.barEntries.append(barEntry)
            }
            barData.yAxisTotal = yAxisMax
            subSectionGraphs[section.name] = barData
        }
        print("FINNISHED CREATE DATA")
        //        self.sectionsOverall = sectionsOverall
        //        self.subSectionGraphs = subSectionGraphs
        //        self.subSectionTime = subSectionTime
        
    }
    
    
}


struct BarData: Hashable, Identifiable{
    static func == (lhs: BarData, rhs: BarData) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var title: String
    var xAxisLabel: String
    var yAxisLabel: String
    var yAxisSegments: Int
    var yAxisTotal: Int
    var barEntries: [BarEntry]
    
}

struct BarEntry: Hashable, Identifiable, Equatable{
    static func == (lhs: BarEntry, rhs: BarEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var xLabel: String
    var yEntries: [(height: CGFloat, color: Color)]
    var index: Int?
}
