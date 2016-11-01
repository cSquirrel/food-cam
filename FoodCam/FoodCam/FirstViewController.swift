//
//  FirstViewController.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 01/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import MobileCoreServices

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
        
        // save the image and the description
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
