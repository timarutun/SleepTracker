//
//  StatisticsViewTests.swift
//  SleepTrackerTests
//
//  Created by Timur on 7/22/24.
//

import XCTest
import SwiftUI
import CoreData
@testable import SleepTracker

class StatisticsViewTests: XCTestCase {
    
    var viewContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        let persistenceController = PersistenceController.preview
        viewContext = persistenceController.container.viewContext
    }
    
    func createSleepRecord(quality: Int, date: Date, sleepTime: Date, wakeTime: Date) -> SleepRecord {
        let record = SleepRecord(context: viewContext)
        record.quality = Int16(quality)
        record.date = date
        record.sleepTime = sleepTime
        record.wakeTime = wakeTime
        return record
    }
}

