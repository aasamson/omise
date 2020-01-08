//
//  ViewControllerDonationForm.swift
//  omise-ios
//
//  Created by Ai on 1/8/20.
//  Copyright © 2020 Ai. All rights reserved.
//

import UIKit

import MBProgressHUD

import Alamofire

class ViewControllerDonationForm: UIViewController {
    
    var charityData : Dictionary = [String: Any]()
    
    var charityObject : NSDictionary = [:]

    @IBOutlet weak var charityImage: UIImageView!
    
    @IBOutlet weak var charityName: UILabel!
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    
    @IBOutlet weak var cardNumberErrorMessage: UILabel!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var amountErrorMessage: UILabel!
    
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func didTapDonate(_ sender: Any) {
    
        if self.validate(){
            
            self.cardNumberErrorMessage.isHidden = true
            self.amountErrorMessage.isHidden = true
            self.donateMoney()
        
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.loadCharityData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cardNumberTextField.delegate = self
        amountTextField.delegate = self
        
        self.cardNumberTextField.addTarget(self, action: #selector(ViewControllerDonationForm.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.amountTextField.addTarget(self, action: #selector(ViewControllerDonationForm.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

    }
    
    
    func loadCharityData() {
        
        self.charityName.text = self.charityObject.object(forKey: "name") as? String
               
        self.charityImage.kf.setImage(with: URL(string:  self.charityObject.object(forKey: "logo_url") as! String))
        
    }
    

    func appendValueToInfoData(key:String!, value:Any!){
        
        self.charityData[key] = value
        
    }
    
    func validate() -> Bool{
        
        if self.charityData["cardNumber"] == nil {
            self.cardNumberErrorMessage.text = "Please input your card number."
            self.cardNumberErrorMessage.isHidden = false
            return false
        }
        
        if self.charityData["amount"] == nil {
            self.amountErrorMessage.text = "Please input your donation amount."
            self.amountErrorMessage.isHidden = false
            return false
        }
        
        return true
    }
    
}

extension ViewControllerDonationForm : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        switch textField {
        
            case cardNumberTextField:
        
                amountTextField.becomeFirstResponder()
            
            default:
            
                textField.resignFirstResponder()
    
        }
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        switch textField {
            
            case cardNumberTextField:
            
                if textField.text?.count == 0 {
                    self.cardNumberErrorMessage.text = "Card Number is required."
                    self.cardNumberErrorMessage.isHidden = false
                    
                } else {
                    
                    self.cardNumberErrorMessage.text = ""
                    self.cardNumberErrorMessage.isHidden = true
                    self.appendValueToInfoData(key: "cardNumber", value: textField.text)
                    
                }
            
                break
            
            case amountTextField:
                       
                if textField.text?.count == 0 {
                    
                    self.amountErrorMessage.text = "Amount is required."
                    self.amountErrorMessage.isHidden = false
                               
                } else {
                               
                    self.amountErrorMessage.text = ""
                    self.amountErrorMessage.isHidden = true
                    self.appendValueToInfoData(key: "amount", value: textField.text)
                               
                }
                       
                break
        
            default:
            
                break
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
    if textField == amountTextField {
        guard let text = textField.text else {return true}

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        let oldDigits = numberFormatter.number(from: text) ?? 0
        var digits = oldDigits.decimalValue

            if let digit = Decimal(string: string) {
                let newDigits: Decimal = digit / 100

                digits *= 10
                digits += newDigits
            }
            if range.length == 1 {
                digits /= 10
                var result = Decimal(integerLiteral: 0)
                NSDecimalRound(&result, &digits, 2, Decimal.RoundingMode.down)
                digits = result
            }

            textField.text = NumberFormatter.localizedString(from: digits as NSDecimalNumber, number: .currency)
        
            self.appendValueToInfoData(key: "amount", value: textField.text)
            
            return false
        
        } else {
            return true
        }
        
    }

}

extension ViewControllerDonationForm : MBProgressHUDDelegate {
    
    
    func donateMoney() {
        
      MBProgressHUD.showAdded(to: self.view, animated: true)
    
      let endpoint: String = "https://virtserver.swaggerhub.com/chakritw/tamboon-api/1.0.0/donations"
        
        let params = [
            "name": self.charityObject.object(forKey: "name") as! String,
            "token": self.charityData["cardNumber"] as! String,
            "amount": self.charityData["amount"] as! String
            ] as [String : Any]
        print(params)
        
        AF.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default)
         .validate(statusCode:200..<600)
         .responseJSON() { (response) in
          
            MBProgressHUD.hide(for: self.view, animated: true)
            switch ((response.response?.statusCode)!){
                
            case 200:
                
                if let result = response.value {
                    
                    self.showErrorDismiss(msg: ((result as! NSDictionary).object(forKey: "error_message") as! String))
                    print("\(result) 200")
                
                }
                
                break
            case 400:
                if let result = response.value {
                                   
                    self.showErrorDismiss(msg: ((result as! NSDictionary).object(forKey: "error_message") as! String))
                    
                    print("\(result) 400")
                }
                
                break
            
                
            default:
                    
               if let result = response.value {
                                       
                
                    self.showErrorDismiss(msg: ((result as! NSDictionary).object(forKey: "error_message") as! String))
                    
                    print("\(result) default")
                }
            }
          
        }

    }
    
    
}
