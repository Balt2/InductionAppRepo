//
//  PerformanceDataModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 6/8/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import SwiftUI

class AllACTData: ObservableObject{
    
    var allTestData: [ACTFormatedTestData]?
    var sectionNames: [String]?
    var overallPerformance: BarData?
    var sectionsOverall: [String: BarData]?
    init(tests: [ACTFormatedTestData]){
        if tests.count > 0{
            self.allTestData = tests
            self.sectionNames = tests[0].sectionsOverall.map {$0.key}
            var overallBarData = BarData(title: "ACT Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [])
            var sectionEntries = [String: [BarEntry]]()
            for test in tests{
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
                let tempGraph = BarData(title: "ACT \(section) Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: entries)
                sectionGraphs[section] = tempGraph
            }
            
            self.overallPerformance = overallBarData
            self.sectionsOverall = sectionGraphs
            
        }else{
            print("Invalid Creation of AllACTDATA: No tests")
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
        self.createData(index: index)
        self.startTest()

    }
    
    func createData(index: Int){
        self.overall = BarEntry(xLabel: "\(self.testFromJson!.dateTaken!)", yEntries: [(height: CGFloat(self.overallScore), color: Color("salmon"))], index: index)
//        var sectionsOverall = [String : BarEntry]()
//        var subSectionGraphs = [String: BarData]()
//        var subSectionTime = [String: BarData]()

        for section in self.sections{
            var data = [String:(r: CGFloat, w: CGFloat, o: CGFloat)]()
            var timingDataYTotal: CGFloat = 0
            var timingData = BarData(title: "\(section.name): Timing by Question", xAxisLabel: "Question #", yAxisLabel: "Seconds", yAxisSegments: 8, yAxisTotal: 0, barEntries: [])
            let subSectionEntry = BarEntry(xLabel: "\(testFromJson!.dateTaken!)", yEntries: [(height: CGFloat(section.scaledScore!), color: Color("salmon"))], index: index)
            sectionsOverall[section.name] = subSectionEntry
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
                        
                        let barEntryTiming = BarEntry(xLabel: String(question.location.row + 1), yEntries: [(height: secondsToAnswerTemp, color: Color.green)])
                        timingData.barEntries.append(barEntryTiming)
                    case .wrong:
                        if data[question.officialSub] != nil{
                            data[question.officialSub]?.w+=1
                        }else{
                            data[question.officialSub] = (r:0, w: 1, o: 0)
                        }
                        let barEntryTiming = BarEntry(xLabel: String(question.location.row + 1), yEntries: [(height: secondsToAnswerTemp, color: Color.red)])
                        timingData.barEntries.append(barEntryTiming)
                    case .omitted: //omitted
                        if data[question.officialSub] != nil{
                            data[question.officialSub]?.o+=1
                        }else{
                            data[question.officialSub] = (r:0, w: 0, o: 1)
                        }
                        let barEntryTiming = BarEntry(xLabel: String(question.location.row + 1), yEntries: [(height: 0, color: Color.gray)])
                        timingData.barEntries.append(barEntryTiming)
                    default:
                        print("Impossible Question State")
                    }
                }
            timingData.yAxisTotal = Int(timingDataYTotal + 10) //TODO: Make a global variable with the radius of the scatter plot circles
            subSectionTime[section.name] = timingData
            
            var barData = BarData(title: "\(section.name) by sub section", xAxisLabel: "Categories", yAxisLabel: "Questions", yAxisSegments: 5, yAxisTotal: 0, barEntries: [])
            var yAxisMax = 0
            for (subSectionString, values) in data{
                let totalInSubSection = Int(values.r +  values.w + values.o)
                yAxisMax = yAxisMax < totalInSubSection ? totalInSubSection : yAxisMax
                let barEntry = BarEntry(xLabel: subSectionString, yEntries: [(height: values.r, color: Color.green), (height: values.w, color: Color.red), (height: values.o, color: Color.gray)])
                
                barData.barEntries.append(barEntry)
            }
            barData.yAxisTotal = yAxisMax
            subSectionGraphs[section.name] = barData
        }
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
