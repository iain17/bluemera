//
//  BluemeraBrain.swift
//  Bluemera
//
//  Created by Iain Munro on 03/10/2017.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import Foundation
import BluetoothKit


//This method iterates through each peer and boasts about how many hashes it has.
//If then one of these peers like what he has to offer. He'll ask him to send him the inventoryItem of that hash.
//Easy peasy, lemon squeezy.
class BlueMeraBrain : BKCentralDelegate, BKPeripheralDelegate, BKAvailabilityObserver, PeerDelegate {
    //BlueMeraBrain UUIDs
    let dataServiceUUID = UUID(uuidString: "3442AE8B-9C9B-4562-B299-4D7307231EDD")!
    let dataServiceCharacteristicUUID = UUID(uuidString: "C3D0261D-4084-40A1-A3A0-D7C9F946AF83")!
    
    let central = BKCentral()
    let peripheral = BKPeripheral()
    
    var inventory = [String:Inventory]()//hash, inventory
    var inventoryIndex = [String]()//position (row), hash.
    
    open var connected = [Peer]()
    private let delegate: BluemeraBrainDelegate
    
    init(delegate: BluemeraBrainDelegate) throws {
        self.delegate = delegate
        try self.setupCentral()
        try self.setupPeripheral()
    }
    
    private func setupCentral() throws {
        self.central.delegate = self
        self.central.addAvailabilityObserver(self)
        let configuration = BKConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID)
        try self.central.startWithConfiguration(configuration)
    }
    
    private func setupPeripheral() throws {
        self.peripheral.delegate = self
        let configuration = BKPeripheralConfiguration(dataServiceUUID: dataServiceUUID,
                                                      dataServiceCharacteristicUUID: dataServiceCharacteristicUUID,
                                                      localName: UIDevice.current.name)
        try self.peripheral.startWithConfiguration(configuration)
    }
    
    open func addToInventory(data: Data, from: String) {
        let hash = data.MD5()
        if inventory[hash] != nil {
            print("we've already got this image. Thank you!")
            return
        }
        self.inventory[hash] = Inventory(from: from, data: data)
        self.inventoryIndex.append(hash)
        //Call delegate. Tell them something has changed!
        self.delegate.InventoryChanged()
        self.boast()
    }
    
    //Returns the current inventoryIndex in data
    private func getInventory() throws -> Data {
        let inventory = Pb.Inventory.Builder()
        inventory.hash = self.inventoryIndex
        let message = Pb.Message.Builder()
        message.inventory = try inventory.build()
        return try message.build().data()
    }
    
    func boast() {
        do {
            let inventory = try getInventory()
            for peer in self.connected {
                print("boasting...")
                peer.sendData(inventory) { data, remoteCentral, error in
                    print(error)
                }
            }
        } catch let err {
            print(err)
        }
    }
    
    open func getFromInventory(position: Int) -> Inventory? {
        let hash = self.inventoryIndex[position]
        return self.inventory[hash]
    }
    
    //MARK: Central
    
    private func scan() {
        self.central.scanContinuouslyWithChangeHandler(self.ScanChanged, stateHandler: { newState in
            print(newState)
        }, duration: 3, inBetweenDelay: 3, errorHandler: { error in
            print(error)
        })
    }
    
    //Connect to all peripheral we find.
    private func ScanChanged(_ changes: [BKDiscoveriesChange], _ discoveries: [BKDiscovery]) {
        for discovery in discoveries {
            self.central.connect(remotePeripheral: discovery.remotePeripheral) { remotePeripheral, error in
                if error != nil {
                    //print(error)
                    return
                }
                self.central(self.central, remotePeripheralDidConnect: remotePeripheral)
            }
        }
    }
    
    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        switch availability {
        case .available:
            scan()
        default:
            print("report this back to the user? \(availability)")
        }
    }
    
    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        print("c")
    }
    
    internal func central(_ central: BKCentral, remotePeripheralDidConnect remotePeripheral: BKRemotePeripheral) {
        print("central::connected")
        self.connected.append(Peer(peer: central, remotePeer: remotePeripheral, delegate: self))
    }
    
    internal func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("central::disconnected")
        self.connected = self.connected.filter { $0.remotePeer != remotePeripheral }
    }
    
    //MARK: Peripheral
    
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        print("peripheral::connected")
        let peer = Peer(peer: peripheral, remotePeer: remoteCentral, delegate: self)
        self.connected.append(peer)
        
        //Boast to this one device.
        do {
            let inventory = try getInventory()
            peer.sendData(inventory) { data, remoteCentral, error in
                print(error)
            }
        } catch let err {
            print(err)
        }
    }
    
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("peripheral::disconnected")
        self.connected = self.connected.filter { $0.remotePeer != remoteCentral }
    }
    
    //MARK: Shared
    func received(_ remotePeer: Peer, data: Data) {
        print("We received a message \(data) from \(remotePeer)")
        var _responses: [Data]?
        do {
            let message = try Pb.Message.parseFrom(data: data)
           
            if let inventory = message.inventory {
                print("Received inventory listing")
                _responses = try requestMissingInventoryItems(available: inventory.hash)
            }
            
            if let inventoryReq = message.inventoryRequest {
                print("Received a inventory request")
                _responses = try sendInventoryItem(hashes: inventoryReq.hash)
            }
            
            if let inventoryRes = message.inventoryResponse {
                print("Received a inventory response")
                //TODO: Check if we can do without encoding it.
                if let imageData = Data(base64Encoded: inventoryRes.data) {
                    self.addToInventory(data: imageData, from: inventoryRes.from)
                }
            }
            
        } catch let err {
            print(err)
        }
        if let responses = _responses {
            for response in responses {
                print("Sending \(response) response")
                remotePeer.sendData(response) { data, remoteCentral, error in
                    print(error)
                }
            }
        }
    }
    
    func requestMissingInventoryItems(available hashes: [String]) throws -> [Data] {
        let inventoryReq = Pb.InventoryItemRequest.Builder()
        for hash in hashes {
            if inventory[hash] != nil {
                continue
            }
            inventoryReq.hash.append(hash)
        }
        let msg = Pb.Message.Builder()
        msg.inventoryRequest = try inventoryReq.build()
        print("Requesting \(inventoryReq.hash.count) items")
        return try [msg.build().data()]
    }
    
    func sendInventoryItem(hashes: [String]) throws -> [Data]  {
        var results = [Data]()
        for hash in hashes {
            if let inventory = self.inventory[hash] {
                let inventoryRes = Pb.InventoryItemResponse.Builder()
                inventoryRes.data = inventory.data.base64EncodedString()
                inventoryRes.from = inventory.from
                let msg = Pb.Message.Builder()
                msg.inventoryResponse = try inventoryRes.build()
                results.append(try msg.build().data())
            }
        }
        return results
    }
}
