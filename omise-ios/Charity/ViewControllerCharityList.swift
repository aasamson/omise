//
//  ViewControllerCharityList.swift
//  omise-ios
//
//  Created by Ai on 1/7/20.
//  Copyright © 2020 Ai. All rights reserved.
//

import UIKit

import Alamofire

import MBProgressHUD

import Kingfisher

class ViewControllerCharityList: UIViewController {
    

    var charityList: [NSDictionary] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        getCharities()
    }
    

}

extension ViewControllerCharityList : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return charityList.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "charityCell", for: indexPath) as! CharityTableViewCell
        
        cell.charityName.text = self.charityList[indexPath.row].object(forKey: "name") as? String
        
        cell.charityImage.kf.setImage(with: URL(string:  self.charityList[indexPath.row].object(forKey: "logo_url") as! String))
        
        return cell
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("tapped")
        
        let storyboard = UIStoryboard(name: "DonateForm", bundle: nil)
        
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerDonationForm") as! ViewControllerDonationForm
            
            vc.charityObject = self.charityList[indexPath.row]
            
            self.present(vc, animated: true)
        
    }
    
}

extension ViewControllerCharityList : MBProgressHUDDelegate {
    
    func getCharities() {
        
      MBProgressHUD.showAdded(to: self.view, animated: true)
    
      let endpoint: String = "https://virtserver.swaggerhub.com/chakritw/tamboon-api/1.0.0/charities"
        AF.request(endpoint)
         .validate(statusCode:200..<600)
         .responseJSON() { (response) in
          
            MBProgressHUD.hide(for: self.view, animated: true)
            switch ((response.response?.statusCode)!){
                
            case 200:
                
                if let result = response.value {
                    
                    self.charityList = ((result as! NSDictionary).object(forKey: "data")) as! [NSDictionary]
                    
                    print(self.charityList)
                    
                    self.tableView.reloadData()
                }
                
                break
            case 400:
                if let result = response.value {
                                   
                    self.showError(msg: ((result as! NSDictionary).object(forKey: "error_message") as! String))
                    
                    print("\(result) 400")
                }
                
                break
            
                
            default:
                    
               if let result = response.value {
                                       
                    self.showError(msg: "It seems like we've encountered a problem.")
                        
                    print("\(result) default")
                }
            }
          
        }

    }
    
}

