//
//  FirstViewController.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 01/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import MobileCoreServices
import CloudKit

class FirstViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var customDescription: UITextView!
    
    fileprivate var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doSnapPhoto(_ sender: Any) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) == true else {
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func doAddPhoto(_ sender: Any) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true else {
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func doSave(_ sender: Any) {
        
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
        
        foodEntry["customDescription"] = customDescription.text as NSString?
        foodEntry["createdAt"] = NSDate()
        
        DispatchQueue.main.async {
            database.save(foodEntry, completionHandler: {
                (record:CKRecord?, error:Error?) in
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
                    (records:[CKRecord]?, error: Error?) in
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
    
    fileprivate func validate() {
        
        var isValid = true
        if selectedImage == nil {
            isValid = false
        }

        saveButton.isEnabled = isValid
    }
}

extension FirstViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard
            let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == kUTTypeImage as String else {
            return
        }
        
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        selectedImage = originalImage
        
        DispatchQueue.main.async {
            self.imagePreview.image = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        validate()
        
    }
    
}

extension FirstViewController: UINavigationControllerDelegate {
    
}
