//
//  ViewController.swift
//  CoreBluetoothBasicScanner
//
//  Created by GrownYoda on 3/6/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

// Clean and upload


import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // UI Stuff
    @IBOutlet weak var progressViewRSSI: UIProgressView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var myTextView: UITextView!


    // BLE Stuff
    var myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]() // create now empty array.
    

    // Put CentralManager in the main queue
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())

    }
    
    // Color Code
    
    
    var myBlueColor = UIColor(red: 0.0, green: 0.5, blue: 0.75, alpha: 1)
    var myBeigeDark = UIColor(red: 0.8, green: 0.6, blue: 0.33, alpha: 1)
    var myBeigeLight = UIColor(red: 0.92, green: 0.78, blue: 0.63, alpha: 1)
    var myBlackColor = UIColor(red: 0.12, green: 0.15, blue: 0.16, alpha: 1)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup color code
        view.backgroundColor = myBlueColor
        myTextView.textColor = myBeigeLight
        labelStatus.textColor = myBeigeLight
        
        myTextView.backgroundColor = myBlackColor
        labelStatus.backgroundColor = myBlackColor
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


// Mark   CBCentralManager Methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        updateStatusLabel("centralManagerDidUpdateState")
       
        /*
        typedef enum {
            CBCentralManagerStateUnknown  = 0,
            CBCentralManagerStateResetting ,
            CBCentralManagerStateUnsupported ,
            CBCentralManagerStateUnauthorized ,
            CBCentralManagerStatePoweredOff ,
            CBCentralManagerStatePoweredOn ,
        } CBCentralManagerState;
     */
        switch central.state{
        case .PoweredOn:
            updateStatusLabel("poweredOn")
            
            
        case .PoweredOff:
            updateStatusLabel("Central State PoweredOFF")

        case .Resetting:
            updateStatusLabel("Central State Resetting")

        case .Unauthorized:
            updateStatusLabel("Central State Unauthorized")
        
        case .Unknown:
            updateStatusLabel("Central State Unknown")
            
        case .Unsupported:
            updateStatusLabel("Central State Unsupported")
            
        default:
            updateStatusLabel("Central State None Of The Above")
            
        }
        
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {

        updateStatusLabel(" - didDiscoverPeripheral - ")
        
//        if RSSI.intValue > -100 ||
        if   peripheral?.name != nil {  // Look for your device by Name
            
            printToMyTextView("Description: \(peripheral.identifier.UUIDString)")
            printToMyTextView("Services: \(advertisementData)")
            printToMyTextView("RSSI: \(RSSI)")
            printToMyTextView("Name: \(peripheral.name)")
            printToMyTextView("\r")
            
        }

        
//        if peripheral?.name == "RedYoda"{  // Look for your device by Name
        
        if (advertisementData[CBAdvertisementDataLocalNameKey] != nil) {
            myCentralManager.stopScan()  // stop scanning to save power
           println("myCentralManager.stopScan()")
            
            peripheralArray.append(peripheral) // add found device to device array to keep a strong reverence to it.
            updateStatusLabel("peripheralArray.append(peripheral)")

            
            myCentralManager.connectPeripheral(peripheralArray[0], options: nil)  // connect to this found device
            updateStatusLabel("myCentralManager.connectPeripheral(peripheralArray[0]")

            updateStatusLabel("Attempting to Connect to \(peripheral.name)  \r")
            printToMyTextView("Attempting to Connect to \(peripheral.name)  \r")
            
        }
    }
    
    func peripheralDidUpdateName(peripheral: CBPeripheral!) {
        printToMyTextView("** peripheralDidUpdateName **")
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        printToMyTextView("\r\r Did Connect to \(peripheral.name) \r\r")
        peripheral.delegate = self
        peripheral.discoverServices(nil)  // discover services
        printToMyTextView("Scanning For Services")

        labelStatus.text = peripheral.name
        
      //  peripheralArray.append(peripheral)

        }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        labelStatus.text = "didDisconnectPeripheral"
    }
    
// Mark   CBPeriperhalManager

    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
       updateStatusLabel("\r\r Discovered Services for \(peripheral.name) \r\r")
        printToMyTextView("\r\r Discovered Services for \(peripheral.name) \r\r")
        
        for service in peripheral.services as! [CBService]{
            printToMyTextView("Service.UUID \(service.UUID) Service.UUID.UUIDString \(service.UUID.UUIDString)"  )
            
            if CSCTag.validService(service) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, forService: service)
            }

            
//            if service.UUID.UUIDString == "180F"{
//                printToMyTextView("------ FOUND BATT service.")
//                peripheral.discoverCharacteristics(nil, forService: service)
//            }
//            
//            if service.UUID.UUIDString == "1816" {
//                printToMyTextView("____ Found Cycling Speed and Cadence\r")
//                peripheral.discoverCharacteristics(nil, forService: service)
//            }
        }
    }
    
  
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        printToMyTextView("DidDiscoverCharacteristicsForService:  Service.UUID \(service.UUID)  UUIDString \(service.UUID.UUIDString)\r")
        printToMyTextView("Enabling sensors")
        
        for characteristic in service.characteristics as! [CBCharacteristic]{
            
            //peripheral.readValueForCharacteristic(characteristic)
            printToMyTextView("\(characteristic)")
            if CSCTag.validDataCharacteristic(characteristic)
            {
               peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
  
    
    
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        
        println("readRSSI")
    }

    func peripheralDidUpdateRSSI(peripheral: CBPeripheral!, error: NSError!) {
        println("didUpdateRSSI")
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        //let convertedReading = "\u{2B}"
        //println("converted reading:\(convertedReading)")
        printToMyTextView("  Read Char Property:Value: \(characteristic.properties):\(characteristic.value)\r")
        
        var myData = NSData()
        if let foo = characteristic.value {
            myData = characteristic.value
            printToMyTextView("MyData: \(myData)")
        }
        
        //     return [WheelRev, WheelEvt, CrankRev, CrankEvt]
        
        
        if characteristic.UUID == CSCMeasurementDataUUID
        {
            var wheelData : [Double] = CSCTag.getCSCData(characteristic.value)
            printToMyTextView("Wheel Event ms \(wheelData[1]) : Crank Event ms\(wheelData[3])")
            printToMyTextView("Wheel Revs \(wheelData[0]) : Crank Revs\(wheelData[2])")
        }
    }
    
    
//  Mark UI Stuff
    
    
    @IBAction func scanSwitch(sender: UISwitch) {
        if sender.on{

        myCentralManager.scanForPeripheralsWithServices(nil, options: nil )   // call to scan for services
        printToMyTextView("\r scanning for Peripherals")
          
        }else{
        myCentralManager.stopScan()   // stop scanning to save power
        printToMyTextView("stop scanning")
     
            if (peripheralArray.count > 0 ) {
            myCentralManager.cancelPeripheralConnection(peripheralArray[0])
            }
        }
    }
    
    
    
    func printToMyTextView(passedString: String){
        println("\(passedString)\r")
        myTextView.text = passedString + "\r" + myTextView.text
    }

    func updateStatusLabel(passedString: String){
        labelStatus.text = passedString
    }
    
}












