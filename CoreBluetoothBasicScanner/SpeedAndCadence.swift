//
//  SpeedAndCadence.swift
//  Topeak Speed and Cadence Sensor
//
//  Created by Alan Hasty 9/15/2015.
//  Copyright (c) 2015 Alan Hasty. All rights reserved.
//

import Foundation
import CoreBluetooth


let deviceName = "PanoBike BLE CSS"

// Service UUIDs
let BatteryServiceUUID                = CBUUID(string: "180F")
let CyclingSpeedandCadenceServiceUUID = CBUUID(string: "1816")
//let HumidityServiceUUID      = CBUUID(string: "F000AA20-0451-4000-B000-000000000000")
//let MagnetometerServiceUUID  = CBUUID(string: "F000AA30-0451-4000-B000-000000000000")
//let BarometerServiceUUID     = CBUUID(string: "F000AA40-0451-4000-B000-000000000000")
//let GyroscopeServiceUUID     = CBUUID(string: "F000AA50-0451-4000-B000-000000000000")

// Characteristic UUIDs
let CSCMeasurementDataUUID   = CBUUID(string: "00002a5b-0000-1000-8000-00805f9b34fb")
let CSCMeasurementConfigUUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
let BatteryLevelDataUUID     = CBUUID(string: "00002a19-0000-1000-8000-00805f9b34fb")
let BatteryLevelConfigUUID   = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")

//00002a19-0000-1000-8000-00805f9b34fb
//00002a5b-0000-1000-8000-00805f9b34fb
//00002a23-0000-1000-8000-00805f9b34fb
//00002a24-0000-1000-8000-00805f9b34fb
//00002a25-0000-1000-8000-00805f9b34fb
//let AccelerometerDataUUID   = CBUUID(string: "F000AA11-0451-4000-B000-000000000000")
//let AccelerometerConfigUUID = CBUUID(string: "F000AA12-0451-4000-B000-000000000000")
//let HumidityDataUUID        = CBUUID(string: "F000AA21-0451-4000-B000-000000000000")
//let HumidityConfigUUID      = CBUUID(string: "F000AA22-0451-4000-B000-000000000000")
//let MagnetometerDataUUID    = CBUUID(string: "F000AA31-0451-4000-B000-000000000000")
//let MagnetometerConfigUUID  = CBUUID(string: "F000AA32-0451-4000-B000-000000000000")
//let BarometerDataUUID       = CBUUID(string: "F000AA41-0451-4000-B000-000000000000")
//let BarometerConfigUUID     = CBUUID(string: "F000AA42-0451-4000-B000-000000000000")
//let GyroscopeDataUUID       = CBUUID(string: "F000AA51-0451-4000-B000-000000000000")
//let GyroscopeConfigUUID     = CBUUID(string: "F000AA52-0451-4000-B000-000000000000")


class CSCTag {
    
    // Check name of device from advertisement data
    class func sensorTagFound (advertisementData: [NSObject : AnyObject]!) -> Bool {
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        return (nameOfDeviceFound == deviceName)
    }
    
    
    // Check if the service has a valid UUID
    class func validService (service : CBService) -> Bool {
        if service.UUID == BatteryServiceUUID || service.UUID == CyclingSpeedandCadenceServiceUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid data UUID
    class func validDataCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == CSCMeasurementDataUUID || characteristic.UUID == BatteryLevelDataUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid config UUID
    class func validConfigCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == CSCMeasurementConfigUUID || characteristic.UUID == BatteryLevelConfigUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
//    // Get labels of all sensors
//    class func getSensorLabels () -> [String] {
//        let sensorLabels : [String] = [
//            "Ambient Temperature",
//            "Object Temperature",
//            "Accelerometer X",
//            "Accelerometer Y",
//            "Accelerometer Z",
//            "Relative Humidity",
//            "Magnetometer X",
//            "Magnetometer Y",
//            "Magnetometer Z",
//            "Gyroscope X",
//            "Gyroscope Y",
//            "Gyroscope Z"
//        ]
//        return sensorLabels
//    }
    
    
    
    // Process the values from sensor
    
    
    // Convert NSData to array of bytes
    class func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int16))
        return array
    }
    
    class func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
        let count = value.length
        var array = [UInt16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(UInt16))
        return array
    }
    
    class func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int8))
        return array
    }
  
    // Get CSC data values
    class func getCSCData(value: NSData) -> [Double] {
        let dataFromSensor = dataToUnsignedBytes16(value)
        var wheelR : UInt32
        wheelR = UInt32(dataFromSensor[0]) << 16 | UInt32(dataFromSensor[1])
        let WheelRev = Double(wheelR)
    
        let WheelEvt  = Double(dataFromSensor[2])
        let CrankRev  = Double(dataFromSensor[3])
        let CrankEvt  = Double(dataFromSensor[4])
        return [WheelRev, WheelEvt, CrankRev, CrankEvt]
    }
    

    class func getBatteryLevel(value: NSData) -> [Int8] {
        let dataFromSensor = dataToSignedBytes8(value)
        return dataFromSensor
    }
}