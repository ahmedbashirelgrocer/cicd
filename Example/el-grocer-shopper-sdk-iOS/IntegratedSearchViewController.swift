//
//  IntegratedSearchViewController.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by Sarmad Abbas on 25/11/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS
import RxSwift
import RxCocoa

class IntegratedSearchViewController: UIViewController {
    
    @IBOutlet weak var txtSearch: UITextField! {
        didSet {
            txtSearch.delegate = self
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    @IBAction func btnCloseSearchPressed(_ sender: Any) {
        self.searchResults = []
        self.txtSearch.text = ""
    }
    
    // let searchClient = makeElgrocerSearchClient()
    // var searchClient: IntegratedSearchClient!
    
    var launchOptions: LaunchOptions!
    // var selectedRetailer: [String: Any] = [:]
    var searchResults: [SearchResult] = [] {
        didSet {
            btnClose.tintColor = searchResults.isEmpty ? .lightGray : .black
            tableView.reloadData()
        }
    }
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.rx.text
            .compactMap { $0 }
            .filter{ ($0.count % 2 == 0 ) }
            // .distinctUntilChanged()
            .subscribe(
                onNext: { [weak self] text in
                    self?.searchProductStore(text) //, lat: lat, long: long)
                }
            ).disposed(by: disposeBag)
    }
}

// MARK: - Search List Table View Setup
extension IntegratedSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.setData(searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSearchResult: SearchResult = searchResults[indexPath.row]
        let deepLinkPayload = selectedSearchResult.deepLink
        self.launchOptions?.setDeepLinkPayload(deepLinkPayload)
        ElGrocer.start(with: launchOptions)
    }
}

extension IntegratedSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtSearch, let text = textField.text, text.isNotEmpty {
            self.searchProductStore(text)
        }
        return false
    }
}

extension IntegratedSearchViewController {
    func searchProductStore(_ text: String) { //, lat: Double, long: Double) {
        
        ElGrocer.searchProduct(text) { (_ searchResults: [SearchResult]) in
            self.searchResults = searchResults
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


