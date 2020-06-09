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
    
    let totalData = BarData(title: "ACT Perfomance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 30, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 35, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 36, color: Color.orange)])
    ])
    
    let totalDataR = BarData(title: "ACT Reading Perfomance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 28, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 35, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 36, color: Color.orange)])
    ])
    
    let totalDataM = BarData(title: "ACT Math Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 32, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 35, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 32, color: Color.orange)])
    ])
    
    let totalDataE = BarData(title: "ACT English Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 33, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 36, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 36, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 35, color: Color.orange)])
    ])
    
    let totalDataS = BarData(title: "ACT Science Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 30, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 32, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 33, color: Color.orange)])
    ])
    
    
    
    //var detailIndex: Int?
    
//    {
//        didSet{
//            if detailIndex! < allTestData!.count{
//                self.currentDetailData = allTestData![detailIndex!]
//            }
//        }
//    }
    
    //var currentDetailData: ACTFormatedTestData?
    var allTestData: [ACTFormatedTestData]?
    var sectionNames: [String]
    var overallPerformance: BarData?
    var sectionsOverall: [String: BarData]
    init(tests: [ACTFormatedTestData]){
        if tests.count > 0{
            self.allTestData = tests
            self.sectionNames = tests[0].sectionsOverall.map {$0.key}
            var overallBarData = BarData(title: "ACT Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [])
            var sectionEntries = [String: [BarEntry]]()
            for test in tests{
                overallBarData.barEntries.append(test.overall)
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
            self.sectionNames = []
            self.overallPerformance = nil
            self.sectionsOverall = [:]
        }
            
    }
    
}


struct ACTFormatedTestData: Hashable, Identifiable{
    
    static func == (lhs: ACTFormatedTestData, rhs: ACTFormatedTestData) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    
    var overall: BarEntry //BarEntry(xLabel: date, yEntries: ([height: overallScore], orange)
    //var overallTime: BarEntry //BarEntry(xLabel: date, yEntries: ([height: time], orange)
    var sectionsOverall: [String: BarEntry] //(SectionName, Entry for the section)
    var subSectionGraphs: [String: BarData] //(SectionName, BarData)
    var subSectionTime: [String: BarData]
    
    init(test: Test, index: Int) {
        self.overall = BarEntry(xLabel: "\(test.testFromJson!.dateTaken!)", yEntries: [(height: CGFloat(test.overallScore), color: Color.orange)], index: index)
        var sectionsOverall = [String : BarEntry]()
        var subSectionGraphs = [String: BarData]()
        var subSectionTime = [String: BarData]()
        //var scatterTiming = BarData(title: "\(section.name) by sub section", xAxisLabel: "Categories", yAxisLabel: "Questions", yAxisSegments: 5, yAxisTotal: 30, barEntries: [])
        for section in test.sections{
            var data = [String:(r: CGFloat, w: CGFloat, o: CGFloat)]()
            var timingDataYTotal: CGFloat = 0
            var timingData = BarData(title: "\(section.name): Timing by Question", xAxisLabel: "Question #", yAxisLabel: "Seconds", yAxisSegments: 8, yAxisTotal: 0, barEntries: [])
            let subSectionEntry = BarEntry(xLabel: "\(test.testFromJson!.dateTaken!)", yEntries: [(height: CGFloat(section.scaledScore!), color: Color.orange)], index: index)
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
                    case .ommited: //Ommited
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
            timingData.yAxisTotal = Int(timingDataYTotal)
            subSectionTime[section.name] = timingData
            
            var barData = BarData(title: "\(section.name) by Sub Section", xAxisLabel: "Categories", yAxisLabel: "Questions", yAxisSegments: 5, yAxisTotal: 0, barEntries: [])
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
        self.sectionsOverall = sectionsOverall
        self.subSectionGraphs = subSectionGraphs
        self.subSectionTime = subSectionTime
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
