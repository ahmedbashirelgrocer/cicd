//
//  GenericHomePageSearchHeader.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class GenericHomePageSearchHeader: UIView {
    @IBOutlet var bGView: UIView!{
        didSet{
            bGView.backgroundColor = .navigationBarWhiteColor()
        }
    }
    @IBOutlet var topHalfBGView: UIView!{
        didSet{
            topHalfBGView.backgroundColor = .navigationBarColor()
            topHalfBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 0, withShadow: false)
        }
    }
    @IBOutlet var searchBarBGView: UIView!{
        didSet{
            searchBarBGView.backgroundColor = .navigationBarWhiteColor()
            searchBarBGView.layer.borderWidth = 1.0
            searchBarBGView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
            searchBarBGView.roundWithShadow(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 22, withShadow: false)
        }
    }
    @IBOutlet var imgSearch: UIImageView!{
        didSet{
            imgSearch.image = UIImage(name: "search-SearchBar")
        }
    }
    @IBOutlet var txtSearch: UITextField!{
        didSet{
            txtSearch.placeholder = NSLocalizedString("search_placeholder_home", comment: "")
            txtSearch.setPlaceHolder(text: NSLocalizedString("search_placeholder_home", comment: ""))
            
          //  txtSearch.textAlignment = .natural
            
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                txtSearch.textAlignment = .right
            }else{
                txtSearch.textAlignment = .left
            }
        }
    }
    
    @IBOutlet weak var locationContainerView: UIView!
    
    @IBOutlet weak var locationContainerHeightConstraint: NSLayoutConstraint!
    var locationView: NavigationBarLocationView!
    let KGenericHomePageSearchHeaderHeight: CGFloat = 60
    
    class func loadFromNib() -> GenericHomePageSearchHeader? {
        return self.loadFromNib(withName: "GenericHomePageSearchHeader")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setIninitialAppearance()
        addLocationBar()
        setLocationHidden(false)
    }
    
    func setIninitialAppearance(){
        self.txtSearch.delegate = self
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        super.layoutSubviews()

        self.locationView.translatesAutoresizingMaskIntoConstraints = false
        
        locationView.topAnchor.constraint(equalTo: locationContainerView.topAnchor, constant: 0).isActive = true
        locationView.leftAnchor.constraint(equalTo: locationContainerView.leftAnchor, constant: 10).isActive = true
        locationView.rightAnchor.constraint(equalTo: locationContainerView.rightAnchor, constant: -16).isActive = true
        locationView.bottomAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: 0).isActive = true

//        let centerHorizontally = NSLayoutConstraint(item: self.locationView!,
//                                                    attribute: .centerY,
//                                                    relatedBy: .equal,
//                                                    toItem: self.locationContainerView,
//                                                    attribute: .centerY,
//                                                    multiplier: 1.0,
//                                                    constant: 0.0)
//        let heightConstraint =  NSLayoutConstraint(item: self.locationView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 36)
//        NSLayoutConstraint.activate([ centerHorizontally , heightConstraint])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    fileprivate func addLocationBar() {
        self.locationView = NavigationBarLocationView.loadFromNib()
        self.locationView.backgroundColor = UIColor.navigationBarColor()
        self.locationContainerView.backgroundColor = UIColor.navigationBarColor()
        locationContainerView.addSubview(self.locationView)
    }
    func setLocationText(_ text : String = "") {
        if let location = self.locationView {
            location.lblLocation.text = text
        }
    }
    
    func setLocationHidden(_ hidden:Bool = true) {
        if let location = self.locationView {
            if hidden{
                location.visibility = .goneY
            }else{
                location.visibility = .visible
            }
            
        }
    }
    func viewDidScroll(_ scrollView: UIScrollView) {
        
        let calculatedOffset = KGenericHomePageSearchHeaderHeight - 30
        if scrollView.contentOffset.y > calculatedOffset
        {
            scrollView.layoutIfNeeded()
            var headerFrame = self.frame
            headerFrame.origin.y = scrollView.contentOffset.y - calculatedOffset
            self.frame = headerFrame
        }
        /*
        // // was working but was hiding tableviewcell
        scrollView.layoutIfNeeded()
        var headerFrame = self.frame
        headerFrame.origin.y = max(0,scrollView.contentOffset.y)
        locationContainerHeightConstraint.constant =  min(max(0, 30-(scrollView.contentOffset.y*0.5)), 30)
        let maxHeight = KGenericHomePageSearchHeaderHeight + 30
        headerFrame.size.height = min(max(maxHeight-scrollView.contentOffset.y*0.5, KGenericHomePageSearchHeaderHeight), maxHeight)
        //print("height",min(max(maxHeight-scrollView.contentOffset.y*0.5, KGenericHomePageSearchHeaderHeight), maxHeight))
        self.frame = headerFrame
         */
    }
    
    func navigationBarSearchTapped() {
        print("Implement in controller")
        guard let vc = UIApplication.topViewController() else {return}
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        searchController.navigationFromControllerName = FireBaseScreenName.GenericHome.rawValue
        searchController.searchFor = .isForUniversalSearch
        searchController.presentingVC = vc
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [searchController]
        
        navigationController.modalPresentationStyle = .overCurrentContext
            // self.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = false
        
        vc.present(navigationController, animated: true, completion: nil)
        
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "1" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        
        ElGrocerUtility.sharedInstance.delay(1.0) {
            if searchController.txtSearch != nil {
                searchController.txtSearch.becomeFirstResponder()
            }
        }
        
        
    }
   
    
}
extension GenericHomePageSearchHeader: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSearch {
          navigationBarSearchTapped()
         return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtSearch{
            navigationBarSearchTapped()
        }
    }
}
