//
//  IntegratedSearchViewController.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by Sarmad Abbas on 25/11/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS

class IntegratedSearchViewController: UIViewController {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    @IBAction func btnCloseSearchPressed(_ sender: Any) {
        self.searchResult = []
        self.txtSearch.text = ""
    }
    
    var launchOptions: LaunchOptions!
    var selectedRetailer = 0
    var searchResult: [[String: Any]] = [] {
        didSet {
            btnClose.tintColor = searchResult.isEmpty ? .lightGray : .black
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    @objc func startSDK() {
//        let launchOptions = getLaunchOptions()
//        ElGrocer.startEngine(with: launchOptions)
//    }

}

// MARK: - Search List Table View Setup
extension IntegratedSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.setData(searchResult[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRetailer = searchResult[indexPath.row]["retailer_id"] as? Int ?? 0
        self.searchResult = []
    }
}

extension IntegratedSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtSearch, let text = textField.text, text.isNotEmpty {
            let lat = launchOptions.latitude ?? 0
            let long = launchOptions?.longitude ?? 0
            self.searchProductStore(text, lat: lat, long: long)
        }
        return false
    }
}

extension IntegratedSearchViewController {
    func searchProductStore(_ text: String, lat: Double, long: Double) {
        ElgrocerSearchClient
            .shared
            .searchProduct(text, location: .init(latitude: lat, longitude: long)) { response, error in
            self.searchResult = response
        }
    }
}


// Elgrocer.swift
//public static func configure(with launchOptions: LaunchOptions? = nil) {
//    defer {
//        ElGrocer.isSDKLoaded = true
//    }
//    
//    SDKManager.shared.launchOptions = launchOptions
//    DataLoader.startLoading()
//}


