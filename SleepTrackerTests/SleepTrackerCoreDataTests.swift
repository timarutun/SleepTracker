//
//  SleepTrackerCoreDataTests.swift
//  SleepTrackerTests
//
//  Created by Timur on 7/22/24.
//

import XCTest
import CoreData
@testable import SleepTracker

class SleepTrackerCoreDataTests: XCTestCase {
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
    }

    func testAddSleepRecord() {
        let newRecord = SleepRecord(context: viewContext)
        newRecord.date = Date()
        newRecord.sleepTime = Date()
        newRecord.wakeTime = Date().addingTimeInterval(3600 * 8)
        newRecord.quality = 4
        newRecord.notes = "Good sleep"

        do {
            try viewContext.save()
        } catch {
            XCTFail("Failed to save record: \(error)")
        }

        let fetchRequest: NSFetchRequest<SleepRecord> = SleepRecord.fetchRequest()
        do {
            let results = try viewContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.notes, "Good sleep")
        } catch {
            XCTFail("Failed to fetch records: \(error)")
        }
    }
}

