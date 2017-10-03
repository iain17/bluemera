//
//  PeerDelegate.swift
//  Bluemera
//
//  Created by Iain Munro on 03/10/2017.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import Foundation

protocol PeerDelegate {
    func received(_ remotePeer: Peer, data: Data)
}
