//
//  DataSource.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 02/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import RealmSwift
import CloudKit

struct DailyEntries {
    let date: Date
    var entries: [FoodEntry] = []
}

/**
 Unifies date/time to midnight
 */
internal func DayFromDate(date:Date) -> Date? {
    
    let result:Date?
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY/MM/dd"
    let dateAsString = dateFormatter.string(from: date)
    result = dateFormatter.date(from: dateAsString)
    
    return result
}

class DataSource: NSObject {

    let realm: Realm
    
    override init() {
        
        realm = try! Realm()
        let fileURL = realm.configuration.fileURL
        print("fileURL: \(fileURL)")
        
        super.init()
    }
    
    public func findAllFoodEntries() -> [DailyEntries] {
        let allEntries = findAllFoodEntriesInRealm()
        let result = groupFoodEntries(entries: allEntries)
        return result
    }
    
    internal func groupFoodEntries(entries:[FoodEntry]) -> [DailyEntries] {
        var entriesByDay: [Date:DailyEntries] = [:]
        
        entries.forEach {
            (foodEntry: FoodEntry) in
            
            guard let normalisedDate = DayFromDate(date: foodEntry.createdAt) else {
                return
            }
            
            let theDay = normalisedDate
            var entriesOnTheDay: DailyEntries
            if let e = entriesByDay[theDay] {
                entriesOnTheDay = e
            } else {
                entriesOnTheDay = DailyEntries(date: theDay, entries: [])
            }
            entriesOnTheDay.entries.append(foodEntry)
            entriesByDay[theDay] = entriesOnTheDay
        }
        
        let result:[DailyEntries] = entriesByDay.values.sorted {
            (entry1: DailyEntries, entry2: DailyEntries) -> Bool in
            let result = (entry1.date.compare(entry2.date) == .orderedDescending)
            return result
        }
        return result

    }

    public func save(foodEntry: FoodEntry) {

        do {

            try saveInRealm(foodEntry: foodEntry)

            // CloudKit not in use at the moment
            saveInCloudKit(foodEntry: foodEntry)

        } catch let error as NSError {
            print(error)
        }

    }

}

// MARK: - Realm DB
extension DataSource {

    fileprivate func saveInRealm(foodEntry: FoodEntry) throws {

        try realm.write {
            realm.add(foodEntry)
        }
    }

    fileprivate func findAllFoodEntriesInRealm() -> [FoodEntry] {

        let realm = try! Realm()
        let entries: Results<FoodEntry> = realm.objects(FoodEntry.self).sorted(byProperty: "createdAt", ascending: false)
        let result = Array(entries)

        return result

    }
}

// MARK: - CloudKit
extension DataSource {

    fileprivate func saveInCloudKit(foodEntry: FoodEntry) {

        let privateDB = CKContainer.default().privateCloudDatabase

        let zoneID = CKRecordZoneID(zoneName: "FoodEntries", ownerName: CKCurrentUserDefaultName)
        let zone = CKRecordZone(zoneID: zoneID)
        let createZone = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
        createZone.modifyRecordZonesCompletionBlock = {
            (zones: [CKRecordZone]?, zoneIDs: [CKRecordZoneID]?, error: Error?) in
            return
        }
        privateDB.add(createZone)

        let foodEntryRecord = CKRecord(recordType: "FoodEntry", zoneID: zoneID)
        do {
            let filename = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)!

            if let data = foodEntry.imageData {
                try data.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
            } else {
                return
            }
            let asset = CKAsset(fileURL: tempURL)
            foodEntryRecord["image"] = asset
        } catch {
            print("Error writing data", error)
            return
        }

        foodEntryRecord["customDescription"] = foodEntry.customDescription as NSString?
        foodEntryRecord["createdAt"] = foodEntry.createdAt as CKRecordValue?
        let saveRecord = CKModifyRecordsOperation(recordsToSave: [foodEntryRecord], recordIDsToDelete: nil)
        saveRecord.modifyRecordsCompletionBlock = {
            (records: [CKRecord]?, recordIDs: [CKRecordID]?, error: Error?) in
            return
        }
        privateDB.add(saveRecord)

    }

    // --
    private func syncCloudKit(selectedImage: UIImage?) {

        guard let img = selectedImage else {
            return
        }

        // save the image and the description
        let privateDB = CKContainer.default().privateCloudDatabase
        let zoneID = CKRecordZoneID(zoneName: "FoodEntries", ownerName: CKCurrentUserDefaultName)
        let zone = CKRecordZone(zoneID: zoneID)
        privateDB.save(zone, completionHandler: {
            (zone: CKRecordZone?, error: Error?) in
            if let e = error {
                print(e)
            } else {
                DispatchQueue.main.async {
                    self.saveFoodEntry(database: privateDB, zoneID: zoneID, image: img)
                }
            }
        })
    }

    private func saveFoodEntry(database: CKDatabase, zoneID: CKRecordZoneID, image: UIImage) {

        let foodEntry = CKRecord(recordType: "FoodEntry", zoneID: zoneID)

        do {
            let filename = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)!

            if let data = UIImageJPEGRepresentation(image, 0.8) as NSData? {
                try data.write(to: tempURL, options: NSData.WritingOptions.atomicWrite)
            } else {
                return
            }
            let asset = CKAsset(fileURL: tempURL)
            foodEntry["image"] = asset
        } catch {
            print("Error writing data", error)
            return
        }

        foodEntry["customDescription"] = NSString() // customDescription.text as NSString?
        foodEntry["createdAt"] = NSDate()

        DispatchQueue.main.async {
            database.save(foodEntry, completionHandler: {
                (record: CKRecord?, error: Error?) in
                if let e = error {
                    print(e)
                } else {
                    DispatchQueue.main.async { self.queryData() }
                }
            })
        }

    }

    private func queryData() {

        let privateDB = CKContainer.default().privateCloudDatabase
        let zoneID = CKRecordZoneID(zoneName: "FoodEntries", ownerName: CKCurrentUserDefaultName)
        privateDB.fetch(withRecordZoneID: zoneID) {
            (recordZone: CKRecordZone?, error: Error?) in
            if let e = error {
                print(e)
            } else {
                let allAcceptedPredicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "FoodEntry", predicate: allAcceptedPredicate)
                privateDB.perform(query, inZoneWith: zoneID, completionHandler: {
                    (records: [CKRecord]?, error: Error?) in
                    if let e = error {
                        print(e)
                    } else {
                        self.printRecords(records: records)
                    }
                })
            }
        }
    }

    private func printRecords(records: [CKRecord]?) {

        records?.forEach({

            (record: CKRecord) in
            print("\(record["createdAt"]): \(record["customDescription"])")

        })
    }
}
