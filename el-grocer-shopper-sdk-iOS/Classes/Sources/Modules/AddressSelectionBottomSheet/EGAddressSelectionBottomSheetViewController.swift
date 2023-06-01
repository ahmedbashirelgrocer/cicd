//
//  EGAddressSelectionBottomSheetViewController.swift
//  el-grocer-shopper-sdk-iOS-el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 01/06/2023.
//

import UIKit

class EGAddressSelectionBottomSheetViewController: UIViewController {
    
    
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var lblChooseDeliveryLocation: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgDifferentLocation: UIImageView!
    @IBOutlet weak var lblDifferentLocation: UILabel!
    @IBOutlet weak var btnChooseLocation: UIButton!
    
    
    var addressList: [DeliveryAddress] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height:  ScreenSize.SCREEN_HEIGHT/2)
        landscapeContentSizeInPopup = CGSize(width: ScreenSize.SCREEN_HEIGHT , height: 500)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableViewCell()
        // Do any additional setup after loading the view.
    }
    
    
    private func registerTableViewCell() {
        
        let cellNib = UINib(nibName: "EGNewAddressTableViewCell", bundle: .resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: EGNewAddressTableViewCell.identifier)
    }
    
    private func setContentHeight(_ address: [DeliveryAddress]) {
        
        let height = address.count * 100
       // contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height:  height)
        
        
        
    }
    
    func configure(_ address: [DeliveryAddress]) {
        self.addressList = address
       // self.tableView.reloadDataOnMain()
    }
    

    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func chooseLocationAction(_ sender: Any) {
    }
    
}


extension EGAddressSelectionBottomSheetViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EGNewAddressTableViewCell.identifier, for: indexPath) as! EGNewAddressTableViewCell
        return cell
    }
    
    
    
    
}
