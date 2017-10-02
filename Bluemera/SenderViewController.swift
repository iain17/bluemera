//
//  SenderViewController.swift
//  Bluemera
//
//  Created by Ramon Schriks on 30-09-17.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import UIKit

class SenderViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    private var imagePicker: UIImagePickerController!
    override func viewDidLoad() {
        disableButton(sendButton)
    }
    
    @IBAction func createPhoto(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendPhoto(_ sender: UIButton) {
        if imageView?.image != nil {
            // TODO: Send photo
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
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
