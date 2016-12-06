//
//  BTDiscovery.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 9/24/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth





class BTDiscovery: NSObject, CBCentralManagerDelegate {
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
    
    var keyBoardControl : KeyboardViewController?
    init(kbControl: KeyboardViewController?) {
        super.init()
        keyBoardControl = kbControl
        let centralQueue = DispatchQueue(label: "com.raywenderlich", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        
    }
    public func boot(kbControl: KeyboardViewController){
        print("start to discover")
        keyBoardControl = kbControl
        if self.bleService != nil{
            self.bleService?.boot(kbControl: kbControl);
        }
    }
    
    func startScanning() {
        print("startScanning")

        if let central = centralManager {
            central.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
        }
    }
    
    var bleService: BTService? {
        didSet {
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Be sure to retain the peripheral or it will fail during connection.
        
        print("CBCentralManagerDelegate")

        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        // If not already connected to a peripheral, then connect to this one
        if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
            // Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral
            
            // Reset service
            self.bleService = nil
            
            // Connect to peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Create new service class")

        
        // Create new service class
        if (peripheral == self.peripheralBLE) {
            self.bleService = BTService(initWithPeripheral: peripheral, kbControl: keyBoardControl)
        }
        
        // Stop scanning for new devices
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("See if it was our peripheral that disconnected")

        
        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE) {
            self.bleService = nil;
            self.peripheralBLE = nil;
        }
        
        // Start scanning for new devices
        self.startScanning()
    }
    
    // MARK: - Private
    
    func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        switch (central.state) {
        case .poweredOff:
            print("power off")
            self.clearDevices()
            
        case .unauthorized:
            print("unauthorized")
            // Indicate to user that the iOS device does not support BLE.
            break
            
        case .unknown:
            print("unknown")

            // Wait for another event
            break
            
        case .poweredOn:
            print("poweredOn")

            self.startScanning()
            
        case .resetting:
            print("resetting")

            self.clearDevices()
            
        case .unsupported:
            print("unsupported")

            break
        }
    }
    
}
