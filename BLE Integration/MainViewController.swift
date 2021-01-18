//
//  MainViewController.swift
//  BLE Integration
//
//  Created by Ali Hewiagh on 18/01/2021.
//

import UIKit
import CoreBluetooth

import SnapKit

let Readings = CBUUID(string: "FEC9")
let Digital = CBUUID(string: "FFE1")


let EnvironmentalSensing = CBUUID(string: "0x181A")
let AutomationIO = CBUUID(string: "0x1815")

fileprivate var ledMask: UInt8    = 0
fileprivate let digitalBits = 2 // TODO: each digital uses two bits


class MainViewController: UIViewController  {
  
    let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))


    //MARK:- CBluetooth
        var cbCentralManager : CBCentralManager!
        var peripheral : CBPeripheral?
    
    

    
    
    // MARK: - UI
    // App Name
    var appName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = "BLE Integration"
        label.textColor = .black
        label.font = UIFont(name: "ArialMT", size: 27.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // message label
    var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = ""
        label.textColor = .red
        label.font = UIFont(name: "ArialMT", size: 17.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // email text feild
    var emailTextFeild: UITextField = {
        let email =  UITextField()
        email.placeholder = "Write"
        email.font = UIFont.systemFont(ofSize: 15)
        email.borderStyle = UITextField.BorderStyle.roundedRect
        email.autocorrectionType = UITextAutocorrectionType.no
        email.keyboardType = UIKeyboardType.default
        email.returnKeyType = UIReturnKeyType.done
        email.clearButtonMode = UITextField.ViewMode.whileEditing
        email.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return email
    }()
    
    // password text feild
    var passwordTextFeild: UITextField = {
        let password =  UITextField()
        password.placeholder = "Password"
        password.font = UIFont.systemFont(ofSize: 15)
        password.borderStyle = UITextField.BorderStyle.roundedRect
        password.autocorrectionType = UITextAutocorrectionType.no
        password.keyboardType = UIKeyboardType.default
        password.returnKeyType = UIReturnKeyType.done
        password.clearButtonMode = UITextField.ViewMode.whileEditing
        password.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        password.isSecureTextEntry = true
        return password
    }()
    
    // login button
    let loginButton: UIButton = {
        let loginBtn = UIButton()
        loginBtn.backgroundColor = .gray
        loginBtn.tintColor = .white
        loginBtn.setTitle("Submit", for: .normal)
        loginBtn.layer.cornerRadius = 5
        return loginBtn
    }()
    
    
    // signup button
    let signupButton: UIButton = {
        let signupBtn = UIButton(frame: CGRect(x: 20, y: 330, width: 300, height: 40))
        signupBtn.backgroundColor = .gray
        signupBtn.tintColor = .white
        signupBtn.setTitle("Disconnet", for: .normal)
        signupBtn.layer.cornerRadius = 5
        return signupBtn
    }()
    
  
    
    
    
    @objc func disConnect() {
        print("get order to disconnect")
        cbCentralManager.cancelPeripheralConnection(self.peripheral!)
    }
   

    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
//        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
        cbCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

        
        view.addSubview(appName)
        appName.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(100)
        }
    

        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(appName.snp.top).offset(60)
        }
        
        view.addSubview(emailTextFeild)
        emailTextFeild.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(messageLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(60)
            make.trailing.equalTo(view.snp.trailing).offset(-60)
            make.height.equalTo(40)
        }
        
//        view.addSubview(passwordTextFeild)
//        passwordTextFeild.snp.makeConstraints { (make) -> Void in
//            make.centerX.equalTo(view.snp.centerX)
//            make.top.equalTo(emailTextFeild.snp.bottom).offset(10)
//            make.leading.equalTo(view.snp.leading).offset(60)
//            make.trailing.equalTo(view.snp.trailing).offset(-60)
//            make.height.equalTo(40)
//        }
        
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(disConnect), for: .touchUpInside)
        loginButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(emailTextFeild.snp.bottom).offset(60)
            make.leading.equalTo(view.snp.leading).offset(60)
            make.trailing.equalTo(view.snp.trailing).offset(-60)
            make.height.equalTo(40)
        }
        
        
        view.addSubview(signupButton)
        signupButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(60)
            make.trailing.equalTo(view.snp.trailing).offset(-60)
            make.height.equalTo(40)
        }
      

    }
    
    

    
    
}

extension MainViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
          central.scanForPeripherals(withServices: nil, options: nil)
          print("Scanning...")
         }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
               guard peripheral.name != nil else {return}
                if peripheral.name! == "iCYCLE0023" {
                   
                    self.messageLabel.text = peripheral.name
                   //stopScan
                   cbCentralManager.stopScan()
                   //connect
                   cbCentralManager.connect(peripheral, options: nil)
                   self.peripheral = peripheral
                   
                   
               }
           }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
           print("Connected : \(peripheral.name ?? "No Name")")
          
           //it' discover all service
           peripheral.discoverServices(nil)
           
           //discover EnvironmentalSensing,AutomationIO
           peripheral.discoverServices([AutomationIO,EnvironmentalSensing])
        
           peripheral.delegate = self
       }
       
       func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
           print("Disconnected : \(peripheral.name ?? "No Name")")
        self.emailTextFeild.text = ""
           cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
       }
    
    
    
    
}




//MARK:- CBPeripheralDelegate
extension MainViewController : CBPeripheralDelegate {
    

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let services = peripheral.services {
            //discover characteristics of services
           
            for service in services {
              peripheral.discoverCharacteristics(nil, for: service)
          }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let charac = service.characteristics {
            for characteristic in charac {
//                print("characteristic: \(characteristic)")
                
                print("VVVVVVV: \(characteristic.uuid)")
                //MARK:- Light Value
                if characteristic.uuid == Digital {
                      //write value
                    setDigitalOutput(1, on: true, characteristic: characteristic)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.setDigitalOutput(1, on: false, characteristic: characteristic)
                    })
                    
                }
                    
                //MARK:- Temperature Read Value
              
                else if characteristic.uuid == Digital {
                    //read value
//
                    peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
               
            }
        }
        
      
        
    }
    

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
          
        print("Recieved : \(characteristic)")
//        if characteristic.uuid == Temperature {
//                           print("Temp : \(characteristic)")
//                let temp = characteristic.tb_uint16Value()
//
//                print(Double(temp!) / 100)
//            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
      
        if let error = error {
            print(error)
        } else {
            print("Value writen sucessfully.")
        }
    }
    
    
    fileprivate func setDigitalOutput(_ index: Int, on: Bool, characteristic  :CBCharacteristic) {
    
        let stringValue = "[S]"
        let arrayValue = Array(stringValue.utf8)
        let length = arrayValue.count
        let stringDataValue = Data(Array(arrayValue[0..<length]))
        self.peripheral?.writeValue(stringDataValue, for: characteristic, type: .withoutResponse)
//           self.bleDevice.writeValueForCharacteristic(CBUUID.Digital, value: data)
           
       }
}

extension CBCharacteristic  {
   func tb_int16Value() -> Int16? {
        if let data = self.value {
            var value: Int16 = 0
            (data as NSData).getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
    func tb_uint16Value() -> UInt16? {
        if let data = self.value {
            var value: UInt16 = 0
            (data as NSData).getBytes(&value, length: 2)
            
            return value
        }
        
        return nil
    }
}







