//
//  SenderViewController.swift
//  Bluemera
//
//  Created by Ramon Schriks on 30-09-17.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import UIKit
import Toaster

class SenderViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func createPhoto(_ sender: UIButton) { loadImage(.camera, message: "Camera is not available") }
    @IBAction func loadPhoto(_ sender: UIButton) { loadImage(.photoLibrary, message: "Cannot open Photolibrary at this moment") }
    
    private var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        disableButton(sendButton)
        imagePicker.delegate = self
    }
    
    private func loadImage(_ sourceType: UIImagePickerControllerSourceType, message msg: String) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        } else { Toast(text: msg).show() }
    }
    
    @IBAction func sendPhoto(_ sender: UIButton) {
        if imageView?.image != nil {
            // TODO: Send photo
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    private func disableButton(_ button: UIButton?) {
        button?.isEnabled = false
        button?.setTitleColor(UIColor.gray, for: .disabled)
    }
    
    private func enableButton(_ button: UIButton?) {
        button?.isEnabled = true
    }
    
    private var selectedImage: UIImage? {
        get {
            return imageView?.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            enableButton(sendButton)
        }
    }
}
