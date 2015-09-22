//
//  NewBLEDevice.swift
//  CoreBluetoothBasicScanner
//
//  Created by Alan Hasty on 9/21/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import Foundation

class BLETag {
    class func getBLEData(value: NSData) -> [UInt32] {
        return [ 0x11, 0x22, 0x33]
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
}