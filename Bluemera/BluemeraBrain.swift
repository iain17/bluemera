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
class BlueMeraBrain : BKCentralDelegate, BKPeripheralDelegate, BKAvailabilityObserver, BKRemotePeerDelegate {
    //BlueMeraBrain UUIDs
    let dataServiceUUID = UUID(uuidString: "3442AE8B-9C9B-4562-B299-4D7307231EDD")!
    let dataServiceCharacteristicUUID = UUID(uuidString: "C3D0261D-4084-40A1-A3A0-D7C9F946AF83")!
    
    let central = BKCentral()
    let peripheral = BKPeripheral()
    
    var inventory = [String:Inventory]()//hash, inventory
    var inventoryIndex = [String]()//position (row), hash.
    
    open var connected = [BKRemoteCentral]()
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
    
    open func addToInventory(data: Data) {
        let hash = data.MD5()
        if inventory[hash] != nil {
            print("we've already got this image. Thank you!")
            return
        }
        self.inventory[hash] = Inventory(from: "UNKNOWN", data: data)
        self.inventoryIndex.append(hash)
        //Call delegate. Tell them something has changed!
        self.delegate.InventoryChanged()
        self.boast()
    }
    
    func boast() {
        for peer in self.connected {
            print("boasting...")
            let data = "Hello beloved central!".data(using: String.Encoding.utf8)
            self.peripheral.sendData(data!, toRemotePeer: peer) { data, remoteCentral, error in
                print(error)
            }
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
                    print(error)
                    return
                }
                remotePeripheral.delegate = self
            }
        }
    }
    
    internal func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("central::disconnected")
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
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        print("received data.... \(data)")
        let data = "Hello beloved peer!".data(using: String.Encoding.utf8)
        self.central.sendData(data!, toRemotePeer: remotePeer) { data, remoteCentral, error in
            print(error)
        }
        self.peripheral.sendData(data!, toRemotePeer: remotePeer) { data, remoteCentral, error in
            print(error)
        }
    }
    
    //MARK: Peripheral
    
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        print("peripheral::connected")
        remoteCentral.delegate = self
        self.connected.append(remoteCentral)
    }
    
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("peripheral::disconnected")
        self.connected = self.connected.filter { $0 != remoteCentral }
    }
}
