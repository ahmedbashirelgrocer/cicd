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
    
    
    private var addressList: [DeliveryAddress] = []
    private var isCoverd: [String: Bool] = [:]
    private var activeGrocery: Grocery? = nil
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isScrollEnabled = self.addressList.count > 2
    }
    
    private func registerTableViewCell() {
        
        let cellNib = UINib(nibName: "EGNewAddressTableViewCell", bundle: .resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: EGNewAddressTableViewCell.identifier)
    }
        
    func configure(_ address: [DeliveryAddress], _ activeGrocery: Grocery? = nil) {
        self.addressList = address
        self.activeGrocery = activeGrocery
        
        for address in self.addressList {
            isCoverd[address.dbID] = true
        }
    }
    

    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func chooseLocationAction(_ sender: Any) {
        
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        //locationMapController.delegate = self
        locationMapController.isConfirmAddress = false
        locationMapController.isForNewAddress = true
        if let location = LocationManager.sharedInstance.currentLocation.value {
            locationMapController.locationCurrentCoordinates = location.coordinate
        }
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [locationMapController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true) {  }
        
        
    }
    
}


extension EGAddressSelectionBottomSheetViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EGNewAddressTableViewCell.identifier, for: indexPath) as! EGNewAddressTableViewCell
        let address = addressList[indexPath.row]
        let isCoverdValue = isCoverd[address.dbID] ?? true
        cell.configure(address: address, isCovered: isCoverdValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard addressList.count > indexPath.row else { return  }
        let address = addressList[indexPath.row]
        if self.activeGrocery != nil {
            self.checkCoverage(address)
        }
       
    }
    
    
    
    
}


extension EGAddressSelectionBottomSheetViewController {
    
    func checkCoverage(_ address : DeliveryAddress) {
        
        
        let _ = SpinnerView.showSpinnerView()
        ElGrocerApi.sharedInstance.getcAndcRetailerDetail(address.latitude, lng: address.longitude, dbID: "16" , parentID: "") { (result) in
            switch result {
                case.success(let data):
                    let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                self.isCoverd[address.dbID] = (responseData.count > 0);            self.tableView.reloadDataOnMain()
                case.failure(let _):
                self.tableView.reloadDataOnMain()
            }
            
            SpinnerView.hideSpinnerView()
        }
        
    }
    
}
