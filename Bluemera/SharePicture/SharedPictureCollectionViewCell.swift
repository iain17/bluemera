//
//  SharedPictureCollectionViewCell.swift
//  Bluemera
//
//  Created by Iain Munro on 03/10/2017.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import Foundation
import UIKit
class SharedPictureCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
   
    func display(inventory: Inventory) {
        self.image.image = UIImage(data: inventory.data)
    }
}
