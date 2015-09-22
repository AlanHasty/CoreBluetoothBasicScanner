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
        return false
    }
    
    
    // Check if the characteristic has a valid data UUID
    class func validDataCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == CSCMeasurementDataUUID ||
           characteristic.UUID == BatteryLevelDataUUID {
           return true
        }
        return false
    }
    
    
    // Check if the characteristic has a valid config UUID
    class func validConfigCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == CSCMeasurementConfigUUID ||
           characteristic.UUID == BatteryLevelConfigUUID {
           return true
        }
        return false
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
    
    class func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int8))
        return array
    }

    // The first byte is an indicator of what data is contained
    // bit 0 - wheel revolutions info
    // bit 1 - crank revolutions info
    //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.csc_measurement.xml
    
    class func formatCSCCrankData(sensorData: [UInt8]) -> [UInt32]
    {
        // Definitions from BT spec on CSC profile
        let cscCrankPresent: UInt8 = 0x02
        
        let dataPresent: UInt8 = UInt8(sensorData[0])
        let crankDataPreset: Bool = dataPresent & cscCrankPresent != 0
        
        var crankRev :UInt16
        var crankEvt :UInt16
        
        if (crankDataPreset )
        {
            
            var gotToBeABetterWayShort : UInt16 = UInt16( sensorData[8]) << 8 | UInt16( sensorData[7] )
            crankRev = CFSwapInt16LittleToHost(gotToBeABetterWayShort)
            
            gotToBeABetterWayShort = UInt16( sensorData[10]) << 8 | UInt16( sensorData[9] )
            crankEvt = CFSwapInt16LittleToHost(gotToBeABetterWayShort)
        }
        else
        {
            crankEvt = 0
            crankRev = 0
        }
        
        return [ UInt32(crankRev), UInt32(crankEvt)]
    }
    
    class func formatCSCPresenceData(sensorData: [UInt8]) -> [Bool]
    {
        // Definitions from BT spec on CSC profile
        var cscWheelPresent: UInt8 = 0x01
        let cscCrankPresent: UInt8 = 0x02
        
        let dataPresent: UInt8 = UInt8(sensorData[0])
        
        let wheelDataPreset: Bool = dataPresent & cscWheelPresent != 0
        let crankDataPreset: Bool = dataPresent & cscCrankPresent != 0
        
        return [ wheelDataPreset, crankDataPreset]
    }
    
    class func formatCSCWheelData(sensorData: [UInt8]) -> [UInt32]
    {
        // Definitions from BT spec on CSC profile
        var cscWheelPresent: UInt8 = 0x01
        let cscCrankPresent: UInt8 = 0x02
        
        let dataPresent: UInt8 = UInt8(sensorData[0])
        
        let wheelDataPreset: Bool = dataPresent & cscWheelPresent != 0
        
        var wheelRev : UInt32
        var wheelEvt : UInt16
        
        if ( wheelDataPreset)
        {
            // gotToBeABetterWay = value.getBytes( &dataFromSensor[1], length:4)
            var gotToBeABetterWay : UInt32 = UInt32( sensorData[4]) << 24  |
                UInt32( sensorData[3]) << 16  |
                UInt32( sensorData[2]) << 8   |
                UInt32( sensorData[1])
            //wheelRev = CFSwapInt32LittleToHost(gotToBeABetterWay)
            wheelRev = gotToBeABetterWay
            
            var gotToBeABetterWayShort : UInt16 = UInt16( sensorData[6]) << 8 | UInt16( sensorData[5] )
            wheelEvt = gotToBeABetterWayShort
            //wheelEvt = CFSwapInt16LittleToHost(gotToBeABetterWayShort)
        }
        else
        {
            wheelRev = 0
            wheelEvt = 0
        }
        return [ wheelRev, UInt32(wheelEvt)]
    }
    
    // Process the values from sensor
    class func retrieveCSCData(value: NSData) -> [UInt8]
    {
        let count = value.length
        var dataFromSensor = [UInt8](count: count, repeatedValue: 0)
        value.getBytes(&dataFromSensor, length:count * sizeof(Int8))
        
        return dataFromSensor
    }
    
    class func formatCSCData(sensorData: [UInt8]) -> [UInt32]
    {
        // Definitions from BT spec on CSC profile
        var cscWheelPresent: UInt8 = 0x01
        let cscCrankPresent: UInt8 = 0x02
        
        let dataPresent: UInt8 = UInt8(sensorData[0])
        
        let wheelDataPreset: Bool = dataPresent & cscWheelPresent != 0
        let crankDataPreset: Bool = dataPresent & cscCrankPresent != 0
        
        var wheelRev : UInt32
        var wheelEvt : UInt16
        
        if ( wheelDataPreset)
        {
            // gotToBeABetterWay = value.getBytes( &dataFromSensor[1], length:4)
            var gotToBeABetterWay : UInt32 = UInt32( sensorData[1]) << 24  |
                UInt32( sensorData[2]) << 16  |
                UInt32( sensorData[3]) << 8   |
                UInt32( sensorData[4])
            wheelRev = CFSwapInt32LittleToHost(gotToBeABetterWay)
            
            var gotToBeABetterWayShort : UInt16 = UInt16( sensorData[5]) << 8 | UInt16( sensorData[6] )
            wheelEvt = CFSwapInt16LittleToHost(gotToBeABetterWayShort)
        }
        else
        {
            wheelRev = 0
            wheelEvt = 0
        }
        
        var crankRev :UInt16
        var crankEvt :UInt16
        
        if (crankDataPreset )
        {
            
            var gotToBeABetterWayShort : UInt16 = UInt16( sensorData[7]) << 8 | UInt16( sensorData[8] )
            crankRev = CFSwapInt16LittleToHost(gotToBeABetterWayShort)
            gotToBeABetterWayShort = UInt16( sensorData[9]) << 8 | UInt16( sensorData[10] )
            crankEvt = CFSwapInt16LittleToHost(gotToBeABetterWayShort)
        }
        else
        {
            crankEvt = 0
            crankRev = 0
        }
        
        return [ UInt32(dataPresent), wheelRev, UInt32(wheelEvt), UInt32(crankRev), UInt32(crankEvt)]
    }
  
    // Get CSC data values
    class func getCSCData(value: NSData) -> [UInt32] {

        var dataFromSensor: [UInt8] = retrieveCSCData(value)
        let presenceData: [Bool] = formatCSCPresenceData(dataFromSensor)
        
        let wheelDataPreset: Bool = presenceData[0]
        let crankDataPreset: Bool = presenceData[1]
        
        var wheelRev : UInt32 = 0
        var wheelEvt : UInt32 = 0
        
        if wheelDataPreset {
            let wheelData: [UInt32] = formatCSCWheelData(dataFromSensor)
            wheelRev = wheelData[0]
            wheelEvt = wheelData[1]
        }
        
        var crankRev :UInt32 = 0
        var crankEvt :UInt32 = 0

        if crankDataPreset {
            let crankData: [UInt32] = formatCSCCrankData(dataFromSensor)
            crankRev = crankData[0]
            crankEvt = crankData[1]
        }
        
        return [wheelRev, wheelEvt, crankRev, crankEvt]
    }
    

    class func getBatteryLevel(value: NSData) -> [Int8] {
        let dataFromSensor = dataToSignedBytes8(value)
        return dataFromSensor
    }
}