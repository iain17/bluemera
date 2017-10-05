//
//  PictureCollectionViewController.swift
//  Bluemera
//
//  Created by Iain Munro on 03/10/2017.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import UIKit
import Toaster

private let reuseIdentifier = "SharedPicture"
class PictureCollectionViewController: UICollectionViewController, BluemeraBrainDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var brain: BlueMeraBrain?
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        do {
            try self.brain = BlueMeraBrain(delegate: self)
         } catch let error{
            print(error)
         }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sharePicture(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            return
        }
        Toast(text: "Can't share a picture. Neither the camera or the photo library are available!").show()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let resizedImage = image.resizeImage(newWidth: CGFloat(150)) {
                self.brain?.addToInventory(data: UIImageJPEGRepresentation(resizedImage, 0.5)!, from: UIDevice.current.name)
            } else {
                print("could not resize...")
            }
        } else {
            print("Could not get the image")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func InventoryChanged() {
        self.collectionView?.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.brain?.inventory.count)!
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let inventory = brain?.getFromInventory(position: indexPath.row) {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SharedPictureCollectionViewCell {
                cell.display(inventory: inventory)
                return cell
            }
        }
        
        print("Somethign went very wrong!")
        return UICollectionViewCell()
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let inventory = brain?.getFromInventory(position: indexPath.row) {
            
            let alert = UIAlertController(title: "Alert", message: "Do you want to save this picture to your photo library?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                if let image = UIImage(data: inventory.data) {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "The shared photo has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
