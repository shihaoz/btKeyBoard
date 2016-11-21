//
//  BTService.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth



/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
//let PositionCharUUID = CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")
let CommandUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

let MessageNotification = "MessageNotification"


class BTService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var positionCharacteristic: CBCharacteristic?
    var keyBoardControl: KeyboardViewController?
    init(initWithPeripheral peripheral: CBPeripheral, kbControl: KeyboardViewController) {
        super.init()
        
        print("start to service")
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        keyBoardControl = kbControl
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        print("startDiscoveringServices")

        self.peripheral?.discoverServices([BLEServiceUUID])
    }
    
    func reset() {
        print("reset")

        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
//        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("CBPeripheralDelegate")

        
        let uuidsForBTService: [CBUUID] = [CommandUUID]
        
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services! {
            if service.uuid == BLEServiceUUID {
                
                
                //reading value
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
        }
    }
    

    //Receive the result of discovering characteristics.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Receive the result of discovering characteristics.")

        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CommandUUID {
                    
                    self.positionCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    
//                    // Send notification that Bluetooth is connected and all required characteristics are discovered
//                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                    
                    //Read
                    peripheral.readValue(for: characteristic)
                    //Receive the result of reading.
                    
                    
                    
                    //let Mdata = characteristic.value
                    
//                    let datastring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)

                    
                    
                    print("characteristic uuid: \(characteristic.uuid), value: \(characteristic.value?[0])")

                    
                    peripheral.setNotifyValue(true, for: characteristic)

                    
//                    //send received meaasge
//                    self.sendmessage((datastring as String?)!)
                    
                    

                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
                    error: NSError?)
        
    {
        print("isNotifying: \(characteristic.isNotifying)")
    }

    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueForCharacteristic characteristic: CBCharacteristic,
                    error: NSError?)
    {
        print("UPDATE")

        
        print("characteristic UUID: \(characteristic.uuid), value: \(characteristic.value?[0])")
        
        if (characteristic.value?[0] == 3) {
            print("LEFT")
            keyBoardControl?.btSignal(move: .Left)
        }
        
        else if (characteristic.value?[0] == 4) {
            print("RIGHT")
            keyBoardControl?.btSignal(move: .Right)
        }
        
        else if (characteristic.value?[0] == 5) {
            print("UP")
            keyBoardControl?.btSignal(move: .Up)
        }
        
        else if (characteristic.value?[0] == 6) {
            print("DOWN")
            keyBoardControl?.btSignal(move: .Down)
        }
        
        else if (characteristic.value?[0] == 1) {
            print("CLICK")
            keyBoardControl?.btSignal(move: .Click)
        }
        
        else if (characteristic.value?[0] == 2) {
            print("DOULBE CLICK")
            keyBoardControl?.btSignal(move: .BackSpace)
            // ??
        }
        
    }
    
    
 
    
    //write
    
//
//    // Mark: - Private
//    func writePosition(_ position: UInt8) {
//        // See if characteristic has been discovered before writing to it
//        if let positionCharacteristic = self.positionCharacteristic {
//            let data = Data(bytes: [position])
//            self.peripheral?.writeValue(data, for: positionCharacteristic, type: CBCharacteristicWriteType.withResponse)
//        }
//    }
    
//    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
//        print("sendBTServiceNotificationWithIsBluetoothConnected")
//        
//        let connectionDetails = ["isConnected": isBluetoothConnected]
//        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
//    }
//    
//    
//    func sendmessage(_ text: String) {
//        print("sendmessage")
//
//        let message = ["message": text]
//        NotificationCenter.default.post(name: Notification.Name(rawValue: MessageNotification), object: self, userInfo: message)
//    }

    
}
