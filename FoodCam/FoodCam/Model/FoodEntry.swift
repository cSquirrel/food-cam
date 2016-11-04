//
//  FoodEntry.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 02/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import RealmSwift

class FoodEntry: Object {

    dynamic var id: String = "\(NSDate().timeIntervalSince1970)"
    dynamic var imageData: NSData?
    dynamic var customDescription: String?
    dynamic var createdAt = NSDate()

    var image: UIImage? {

        set {
            guard let img = newValue else {
                return
            }
            imageData = UIImageJPEGRepresentation(img, 0.8) as NSData?
        }

        get {
            guard let data = imageData as? Data else {
                return nil
            }
            let result = UIImage(data: data)
            return result
        }
    }

    override static func ignoredProperties() -> [String] {
        return ["image"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension FoodEntry {

    @discardableResult func update(block: () -> Void) throws -> FoodEntry {
        
        if let r = realm {
            try r.write {
                block()
            }
        } else {
            block()
        }
        
        try save()
        
        return self
    }
    
    private func save() throws {
        try self.realm?.write {
            realm?.add(self)
        }
    }
}
