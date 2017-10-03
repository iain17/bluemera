//
//  BluemeraBrain.swift
//  Bluemera
//
//  Created by Iain Munro on 03/10/2017.
//  Copyright © 2017 Ramon Schriks. All rights reserved.
//

import Foundation
import BluetoothKit

class BlueMeraBrain : BKCentralDelegate, BKPeripheralDelegate, BKAvailabilityObserver {
    let serviceUUID = UUID(uuidString: "3442AE8B-9C9B-4562-B299-4D7307231EDD")!//BlueMeraBrain UUID
    let characteristicUUID = UUID()//Generate a random new one.
    
    let central = BKCentral()
    let peripheral = BKPeripheral()
    
    var inventory = [String:Inventory]()//hash, inventory
    var inventoryIndex = [String]()//position (row), hash.
    
    open var discoveries = [BKDiscovery]()
    private let delegate: BluemeraBrainDelegate
    
    init(delegate: BluemeraBrainDelegate) throws {
        self.delegate = delegate
        try self.setupCentral()
        try self.setupPeripheral()
    }
    
    private func setupCentral() throws {
        self.central.delegate = self
        self.central.addAvailabilityObserver(self)
        let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
        try self.central.startWithConfiguration(configuration)
    }
    
    private func setupPeripheral() throws {
        self.peripheral.delegate = self
        let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID,
                                                      dataServiceCharacteristicUUID: characteristicUUID,
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
    }
    
    open func getFromInventory(position: Int) -> Inventory? {
        let hash = self.inventoryIndex[position]
        return self.inventory[hash]
    }
    
    private func scan() {
        self.central.scanContinuouslyWithChangeHandler(self.ScanChanged, stateHandler: { newState in
            print(newState)
        }, duration: 3, inBetweenDelay: 3, errorHandler: { error in
            print(error)
        })
    }
    
    private func ScanChanged(_ changes: [BKDiscoveriesChange], _ discoveries: [BKDiscovery]) {
        self.discoveries = discoveries
        for discovery in changes {
            //Hey a new one. Lets tell him or her about what we have!
        }
    }
    
    internal func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("a")
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
    
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        print("d")
    }
    
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        print("e")
    }
}
