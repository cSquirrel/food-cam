//
//  NewEntryViewController.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 03/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import MobileCoreServices
import CloudKit
import RealmSwift

class NewEntryViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var customDescription: UITextView!
    
    private var entry: FoodEntry?

    fileprivate var selectedImage: UIImage?

    func editMode(entry: FoodEntry) {
        self.entry = entry
        self.title = "Edit Entry"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        defer {
            super.viewWillAppear(animated)
        }
        
        guard let foodEntry = entry else {
            return
        }
        
        saveButton.isEnabled = true
        
        imagePreview.image = foodEntry.image
        customDescription.text = foodEntry.customDescription
        
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

        let dataSource = DataSource()
        let foodEntry = entry ?? FoodEntry()
        try! foodEntry.update {
            foodEntry.image = self.selectedImage
            foodEntry.customDescription = self.customDescription.text
        }
        dataSource.save(foodEntry: foodEntry)
        _ = navigationController?.popViewController(animated: true)
    }

    fileprivate func validate() {

        var isValid = true
        if selectedImage == nil {
            isValid = false
        }

        saveButton.isEnabled = isValid
    }

}

extension NewEntryViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

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

extension NewEntryViewController: UINavigationControllerDelegate {
}
