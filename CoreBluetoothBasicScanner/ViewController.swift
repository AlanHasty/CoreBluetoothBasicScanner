//
//  ViewController.swift
//  CoreBluetoothBasicScanner
//
//  Created by GrownYoda on 3/6/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // UI Stuff
    @IBOutlet weak var progressViewRSSI: UIProgressView!
    @IBOutlet weak var labelConnectedDevice: UILabel!

    // BLE Stuff
    let myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]() // create now empty array.
    

    // Put CentralManager in the main queue
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


// Mark   CBCentralManager Methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        printToMyTextView("centralManagerDidUpdateState")
       
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
            println("poweredOn")
            
            
        case .PoweredOff:
            printToMyTextView("Central State PoweredOFF")

        case .Resetting:
            printToMyTextView("Central State Resetting")

        case .Unauthorized:
            printToMyTextView("Central State Unauthorized")
        
        case .Unknown:
            printToMyTextView("Central State Unknown")
            
        case .Unsupported:
            printToMyTextView("Central State Unsupported")
            
        default:
            printToMyTextView("Central State None Of The Above")
            
        }
        
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {

//        printToMyTextView(" -- didDiscoverPeripheral -- ")
        
      
//        if peripheral?.name != nil {  // Look for your device by Name
//
//            printToMyTextView("Description: \(peripheral.identifier.UUIDString)")
//            printToMyTextView("Services: \(peripheral.services)")
//            printToMyTextView("RSSI: \(RSSI)")
//            printToMyTextView("Name: \(peripheral.name)")
//            println("Name: \(peripheral.name)")
//            
//            printToMyTextView("\r")
//       
//        }

        if peripheral?.name != nil {  // Look for your device by Name
            
            printToMyTextView("Description: \(peripheral.identifier.UUIDString)")
            printToMyTextView("Services: \(peripheral.services)")
            printToMyTextView("RSSI: \(RSSI)")
            printToMyTextView("Name: \(peripheral.name)")
            println("Name: \(peripheral.name)")
            
            printToMyTextView("\r")
            
        }

        
        
        
        if peripheral?.name == "RedDotBean"{  // Look for your device by Name
            myCentralManager.stopScan()  // stop scanning to save power
            peripheralArray.append(peripheral) // add found device to device array to keep a strong reverence to it.
            myCentralManager.connectPeripheral(peripheralArray[0], options: nil)  // connect to this found device
            printToMyTextView("Attempting to Connect to \(peripheral.name)")
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

        labelConnectedDevice.text = peripheral.name
        
      //  peripheralArray.append(peripheral)

        }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        labelConnectedDevice.text = ""
    }
    
// Mark   CBPeriperhalManager

    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        printToMyTextView("\r\r Discovered Servies for \(peripheral.name) \r\r")
        
        for service in peripheral.services as [CBService]{
            println("Service: \(service)  Service.UUID \(service.UUID)  Service.UUID.UUIDString \(service.UUID.UUIDString) \r\r"  )
            printToMyTextView("\r Services: \(service.UUID.UUIDString) ")
            
            if service.UUID.UUIDString == "180F"{
                printToMyTextView("------ FOUND BATT with service.UUID.UUIDString \r\r")
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
  
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        println("didDiscoverCharacteristicsForService")
        printToMyTextView("DidDiscoverCharacteristicsForService:  Service.UUID \(service.UUID)  Service.UUID.UUIDString \(service.UUID.UUIDString) \r\r"  )
        
        for characteristic in service.characteristics as [CBCharacteristic]{
            println("Reading Characteristic: \(characteristic)\r")
            printToMyTextView("Reading Characteristic Value: \(characteristic.value)\r")
            
            peripheral.readValueForCharacteristic(characteristic)
            peripheral.readRSSI()
        }
    }
  
    
    
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
    
        println("readRSSI")
            }

    func peripheralDidUpdateRSSI(peripheral: CBPeripheral!, error: NSError!) {
        println("didUpdateRSSI")
    }
    
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        let convertedReading = "\u{2B}"
        println("converted reading:\(convertedReading)")
        println("2  Reading Characteristic: \(characteristic)\r")

        printToMyTextView("2  Reading Characteristic Value: \(characteristic.value)\r")
        println("2  Reading Characteristic Property: \(characteristic.properties)\r")

        
        var myData = NSData()
        myData = characteristic.value
        println("MyData: \(myData)\r")
        printToMyTextView("MyData: \(myData)\r")


    }
    
    
//  Mark UI Stuff
    
    @IBOutlet weak var myTextView: UITextView!
    
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
        myTextView.text = passedString + "\r" + myTextView.text
    }
    
}












