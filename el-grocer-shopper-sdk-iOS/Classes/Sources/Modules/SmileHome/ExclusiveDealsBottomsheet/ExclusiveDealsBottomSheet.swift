//
//  ExclusiveDealsBottomSheet.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 26/03/2024.
//

import UIKit

class ExclusiveDealsBottomSheet: UIViewController {

    var delegate: CopyAndShopDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headingLabel: UILabel!{
        didSet{
            headingLabel.text = localizedString("lbl_title_exclusive_deals", comment: "")
            headingLabel.setH3SemiBoldDarkStyle()
        }
    }
    
    @IBAction func crossTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    @objc func copyAndShopTapped(){
        self.dismiss(animated: false){
            self.delegate?.copyAndShopWithGrocery()
        }
    }
}
extension ExclusiveDealsBottomSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ExclusiveDealBottomSheetTableViewCell", for: indexPath) as! ExclusiveDealBottomSheetTableViewCell
        cell.copyAndShopBtn.addTarget(self, action: #selector(copyAndShopTapped), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
