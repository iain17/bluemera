//
//  ChoiceViewController.swift
//  Bluemera
//
//  Created by Ramon Schriks on 30-09-17.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import UIKit

class ChoiceViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectionVC = segue.destination.contents
        selectionVC.title = (sender as? UIButton)?.currentTitle
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }
        return self
    }
}
