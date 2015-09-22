//
//  CoreBluetoothBasicScannerTests.swift
//  CoreBluetoothBasicScannerTests
//
//  Created by GrownYoda on 3/6/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import UIKit
import XCTest
import CoreBluetoothBasicScanner
//import SpeedAndCadence

class BasicScannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    
    func testCSCDataExtraction() {
        // Test to get the extraction of CSC data correct
        var arr : [UInt8] = [3,0xf2,0x22, 0,0, 0xb0,0x73,0x5f,0x40,0xd4,0xd5]
        var result : [Bool] = BLETag.formatCSCPresenceData(arr)
        
        XCTAssertEqual(result[0], true, " Wheel flag incorrect")
        XCTAssertEqual(result[0], true, " Crank flag incorrect")

    }

    func testCSCCrankDataExtraction() {
        var arr : [UInt8] = [3,0xf2,0x22, 0,0, 0xb0,0x73,0x5f,0x40,0xd4,0xd5]
        
        var result : [UInt32] = BLETag.formatCSCCrankData(arr)
        XCTAssertEqual(result[0], 16479, "Crank Revs incorrect")
        XCTAssertEqual(result[1], 54740, "Crank Event incorrect")
    }
    
    func testCSCWheelDataExtraction() {
        var arr : [UInt8] = [3,0xf2,0x22, 0,0, 0xb0,0x73,0x5f,0x40,0xd4,0xd5]
        
        var result : [UInt32] = BLETag.formatCSCWheelData(arr)
        XCTAssertEqual(result[0], 8946, "Wheel Revs incorrect")
        XCTAssertEqual(result[1], 29616, "Wheel Event incorrect")
    }
    
}
