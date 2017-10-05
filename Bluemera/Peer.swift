//
//  Peer.swift
//  Bluemera
//
//  Created by Iain Munro on 03/10/2017.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import Foundation
import BluetoothKit

//To simplify the whole central, peripheral thing.
class Peer: BKRemotePeerDelegate {
    
    open let peer: BKPeer//Can be a central or peripheral. its the object we use to send our data.
    open let remotePeer: BKRemotePeer
    private let delegate: PeerDelegate
    
    init( peer: BKPeer, remotePeer: BKRemotePeer, delegate: PeerDelegate) {
        self.peer = peer
        self.remotePeer = remotePeer
        self.delegate = delegate
        self.remotePeer.delegate = self
    }
    
    open func sendData(_ data: Data, completionHandler: BKSendDataCompletionHandler?) {
        self.peer.sendData(data, toRemotePeer: self.remotePeer, completionHandler: completionHandler)
    }
    
    internal func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        print("received data.... \(data)")
        self.delegate.received(self, data: data)
    }
    
}
