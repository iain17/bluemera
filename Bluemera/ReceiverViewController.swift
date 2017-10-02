//
//  BluetoothController.swift
//  Bluemera
//
//  Created by Ramon Schriks on 30-09-17.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import UIKit

class ReceiverViewController: UIViewController {
    // Model: Photo album
    public func savePhoto(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
