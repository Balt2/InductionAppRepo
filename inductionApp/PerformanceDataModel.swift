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
    var overallPerformanceTimeOfDay: BarData?
    var sectionsOverall: [String: BarData]?
    var testType: TestType?
    var user: User?
    init(tests: [ACTFormatedTestData], user: User){
        if tests.count > 0{
            self.testType = tests[0].testType!
            print(tests[0].dateTaken)
            let tempTests = tests.sorted(by: {$0.dateTaken! < $1.dateTaken!})
            for (index, test) in tempTests.enumerated(){
                test.createData(index: index)
            }
            self.allTestData = tempTests //TODO: Two many loops
            self.user = user

            self.sectionNames = Array(self.allTestData![0].subSectionGraphs.keys)
            self.higherSectionNames = self.allTestData![0].sectionsOverall.map{$0.key}
            self.createSelf()
        }else{
            print("Invalid Creation of AllACTDATA: No tests")
        }
    }
    
    func addTest(test: ACTFormatedTestData){
        print("IN ADD TEST")
        print("ALLTESTDATA NOT NIL")
        self.allTestData!.append(test)
        
        print("CREATING SELF")
        self.createSelf()
    }
    
    func createSelf(){
        print("CREATE SELF!")
        DispatchQueue.global(qos: .utility).async {
            var overallBarData = BarData(
                title: "\(self.testType!.rawValue) Performance",
                xAxisLabel: "Dates",
                yAxisLabel: "Score",
                yAxisSegments: 4,
                yAxisTotal: self.testType!.getTotalScore(),
                barEntries: [])
            
            //Scatter plot data
            var overallBarDataTimeOfDay = BarData(
                title: "\(self.testType!.rawValue) Performance by Time of Day",
                xAxisLabel: "Time of Day",
                yAxisLabel: "Score",
                yAxisSegments: 4,
                yAxisTotal: self.testType!.getTotalScore(),
                barEntries: [])
            
            var sectionEntries = [String: [BarEntry]]()
            for test in self.allTestData!{
                overallBarData.barEntries.append(test.overall!)
                
                if test.testType! == .psat{
                    print("HELLO PSET")
                    print(test.overall?.yEntries)
                }
                overallBarDataTimeOfDay.barEntries.append(test.todBarEntry!)
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
                    title: "\(self.testType!.rawValue) \(section) Performance",
                    xAxisLabel: "Dates",
                    yAxisLabel: "Score",
                    yAxisSegments: 4,
                    yAxisTotal: self.testType!.getSubSectionTotalScore(),
                    barEntries: entries)
                sectionGraphs[section] = tempGraph
            }
            
            
            
            DispatchQueue.main.async {
                self.overallPerformance = overallBarData
                self.overallPerformanceTimeOfDay = overallBarDataTimeOfDay
                self.sectionsOverall = sectionGraphs
                if self.user != nil {
                    print("SETTING PERFORAMNCE BACK")
                    self.user!.getPerformanceDataComplete = true
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
    var todBarEntry: BarEntry?
    var sectionsOverall = [String: BarEntry]() //(SectionName, Entry for the section)
    var subSectionGraphs = [String: BarData]() //(SectionName, BarData)
    var subSectionTime = [String: BarData]()
    var tutorPDF: TestPDF?
    
    
    init(pdfData: Data, jsonData: Data){ //} index: Int, user: User, testRefImages: String, tutorPDFName: String) {
        //self.tutorPDF = TestPDF(name: tutorPDFName)
        super.init(jsonData: jsonData, pdfData: pdfData, corrections: true)
        //super.init(jsonData: data, user: user, testRefImages: testRefImages)
        //self.createData(index: index)
        //self.resetQuestions()
    }
    
    init(pdfImages: [PageModel], jsonData: Data){
        super.init(jsonData: jsonData, pdfImages: pdfImages)
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

        //xLabel: "\(String(describing: self.testFromJson!.dateTaken!.components(separatedBy: [" "]).first!))"
        self.overall = BarEntry(xLabel: self.dateTaken!.toString(dateFormat: "MM-dd-yyyy"),
            yEntries: [(height: CGFloat(self.overallScore),
                        color: Color(red: 0.15, green: 0.68, blue: 0.37))],
            index: index)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        self.todBarEntry = BarEntry(xLabel: formatter.string(from: self.dateTaken!), yEntries: [(height: CGFloat(self.overallScore), color: Color(red: 0.15, green: 0.68, blue: 0.37))])
        
       
        
        //Only for SAT:
        if self.testType == .sat || self.testType == .psat{
            let englishSectionEntry = BarEntry(
            xLabel: self.dateTaken!.toString(dateFormat: "MM-dd-yyyy"),
                yEntries: [(height: CGFloat(self.englishScore),
                        color: Color(red: 0.15, green: 0.68, blue: 0.37))],
            index: index)
            sectionsOverall["English"] = englishSectionEntry
            let mathSectionEntry = BarEntry(
            xLabel: self.dateTaken!.toString(dateFormat: "MM-dd-yyyy"),
                yEntries: [(height: CGFloat(self.mathScore), //TODO Sometime mathScore will crash bc its nil
                        color: Color(red: 0.15, green: 0.68, blue: 0.37))],
            index: index)
            sectionsOverall["Math"] = mathSectionEntry
        }
        
        for section in self.sections{
            
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
            if self.testType == .act{
                let subSectionEntry = BarEntry(
                    xLabel: self.dateTaken!.toString(dateFormat: "MM-dd-yyyy"),
                    yEntries: [(height: CGFloat(section.scaledScore!),
                                color: Color(red: 0.15, green: 0.68, blue: 0.37))],
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
                title: "\(section.name) by Sub Category",
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



class QuickData: ObservableObject {
    
    @Published var overallBarData: BarData

    @Published var sectionBarData: [String: BarData] = [:] //English: BarData, Math: BarData
    @Published var currentSectionString: String = ""
    var currentSectionBarData: BarData {
        if sectionBarData.isEmpty {
            return BarData(title: "Test Section Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 50, barEntries: [BarEntry(xLabel: " ", yEntries: [(height: 0, color: Color.gray)])])
        }else{
            return sectionBarData[currentSectionString]!
        }
    }
    var sectionNames = [String]()
    let testType: TestType
    var databaseDictionary = [String: [String : [String: Int]]]()
    
    init(testType: TestType){
        self.testType = testType
        self.overallBarData = BarData(title: "Test Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 50, barEntries: [BarEntry(xLabel: " ", yEntries: [(height: 0, color: Color.gray)])])
    }
    
    func addNewTest(test: Test, testResultName: String){
        
        let newEntry = getNewDictEntry(test: test)
        databaseDictionary[testResultName] = newEntry
        
        self.createData(nsDictionary: databaseDictionary)
        
//        if overallBarData.barEntries[0].xLabel == " "{
//            let tempNSDictionary = [testResultName: newEntry]
//            self.createData(nsDictionary: tempNSDictionary)
//        }else{
//           let newOverallBarEntry = BarEntry(xLabel: Date().toString(dateFormat: "MM-dd-yyyy"), yEntries: [(height: CGFloat(test.overallScore), color: Color("salmon"))])
//
//            overallBarData.barEntries.append(newOverallBarEntry)
//
//
//            if testType == .sat || testType == .psat{
//                let mathSectionBarEntry = BarEntry(xLabel: Date().toString(dateFormat: "MM-dd-yyyy"), yEntries: [(height: CGFloat(test.mathScore!), color: Color("salmon"))])
//                let englishSectionBarEntry = BarEntry(xLabel: Date().toString(dateFormat: "MM-dd-yyyy"), yEntries: [(height: CGFloat(test.englishScore!), color: Color("salmon"))])
//
//                sectionBarData["Math"]?.barEntries.append(mathSectionBarEntry)
//                sectionBarData["English"]?.barEntries.append(englishSectionBarEntry)
//            }else if testType == .act {
//                for section in test.sections{
//                    let sectionBarEntry = BarEntry(xLabel: Date().toString(dateFormat: "MM-dd-yyyy"), yEntries: [(height: CGFloat(section.scaledScore!), color: Color("salmon"))])
//                    sectionBarData[section.name]?.barEntries.append(sectionBarEntry)
//                }
//            }
//        }
        
    }
    
    private func getNewDictEntry(test: Test) -> [String : [String: Int]] {
        switch testType{
        case .sat, .psat:
            return [Date().toString(dateFormat: "MM-dd-yyyy") :
            ["overall":test.overallScore,
             "Math":test.mathScore,
                "English":test.englishScore
            ]]
        case .act:
            var tempSectionDict = [String: Int]()
            tempSectionDict["overall"] = test.overallScore
            for section in test.sections{
                tempSectionDict[section.name] = section.scaledScore!
            }
            return [Date().toString(dateFormat: "MM-dd-yyyy") :
            tempSectionDict]
        }
    }
    
    func createData(nsDictionary: [String: [String : [String: Int]]]){
        if !nsDictionary.isEmpty{
            databaseDictionary = nsDictionary
            sectionBarData = [:]
            overallBarData = BarData(title: "\(testType.rawValue) Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: testType.getTotalScore(), barEntries: [])
            for (testName, dateMap) in nsDictionary{
                for (date, sectionMap) in dateMap {
                    
                    let newOverallBarEntry = BarEntry(xLabel: date, yEntries: [(height: CGFloat(sectionMap["overall"]!), color: Color(red: 0.15, green: 0.68, blue: 0.37))])
                    overallBarData.barEntries.append(newOverallBarEntry)
                    
                    
                    var sectionMapWOOverall = sectionMap
                    sectionMapWOOverall["overall"] = nil
                    
                    for (sectionName, score) in sectionMapWOOverall{
                        let newBarEntry = BarEntry(xLabel: date, yEntries: [(height: CGFloat(score), color: Color(red: 0.15, green: 0.68, blue: 0.37))])
                        if self.sectionBarData[sectionName] == nil{
                            sectionBarData[sectionName] = BarData(title: "\(sectionName) Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: testType.getSubSectionTotalScore(), barEntries: [newBarEntry])
                        }else{
                            self.sectionBarData[sectionName]?.barEntries.append(newBarEntry)
                        }
                    }
                    
                }
            }
            //Sort bar entries in quick data by date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            overallBarData.barEntries.sort(by: {dateFormatter.date(from: ($0.xLabel))! < dateFormatter.date(from: ($1.xLabel))!})
            
            sectionNames = Array(sectionBarData.keys)
            sectionNames.sort()
            currentSectionString = sectionNames[0]
            
            for sectionName in sectionNames{
                sectionBarData[sectionName]?.barEntries
                    .sort(by: {dateFormatter.date(from: ($0.xLabel))! < dateFormatter.date(from: ($1.xLabel))!})
            }
        }
        
    }
    
    
}

extension Date{
    func getHourLabel() -> String{
        return "FOUR"
    }
}
