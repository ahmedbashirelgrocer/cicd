//
//  LocationChangedViewController.swift
//  ElGrocerShopper
//
//  Created by Salman on 16/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import CoreLocation

class LocationChangedViewController: UIViewController {
    
    @IBOutlet weak var mainDescriptionLabel: UILabel!
    @IBOutlet weak var subDescriptionLabel: UILabel!
    @IBOutlet weak var changeLocationButton: AWButton!
    @IBOutlet weak var dontChangeButton: AWButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    var currentLocation: CLLocation?
    var currentSavedLocation: CLLocation?
    private var subViewHeight = 520.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Thread.OnMainThread {
            self.containerView.layer.cornerRadius = 25
            self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            UIView.animate(withDuration: 0.85, delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.3,
                           options: .curveEaseOut, animations: {
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    private func setupUI() {
        
        let calculatedHeight = (view.bounds.height)*0.60
        subViewHeight = calculatedHeight > subViewHeight ? calculatedHeight : subViewHeight
        bottomConstraint.constant = -subViewHeight
        containerViewHeightConstraint.constant = subViewHeight
        
        self.mainDescriptionLabel.text = localizedString("location_changed_view_main_Description_label_text", comment: "")
        self.subDescriptionLabel.text = localizedString("location_changed_view_sub_Description_label_text", comment: "")
        self.changeLocationButton.setTitle(localizedString("location_changed_view_change_location_button_title", comment: ""), for: UIControl.State())
        self.dontChangeButton.setTitle(localizedString("location_changed_view_dont_change_location_button_title", comment: ""), for: UIControl.State())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //to give an affect that it moved down and disappeared
        UIView.animate(withDuration: 0.65, delay: 0,
                       options: .curveEaseIn, animations: {
            self.bottomConstraint.constant = -self.subViewHeight
            self.view.layoutIfNeeded()
        })
    }
    

    @IBAction func changeLocationTapped(_ sender: AWButton) {
        
        if let cl = currentLocation, let csl = currentSavedLocation {
            FireBaseEventsLogger.trackChangeToCurrentLocationClicked( cl.coordinate.latitude, cl.coordinate.longitude, csl.coordinate.latitude, csl.coordinate.longitude )
        }
        self.presentingViewController!.dismiss(animated: true) {
            self.changeLocation()
        }
    }
    
    @IBAction func dontChangeTapped(_ sender: AWButton) {
        
        if let cl = currentLocation, let csl = currentSavedLocation {
            FireBaseEventsLogger.trackDontChangeLocationClicked( cl.coordinate.latitude, cl.coordinate.longitude, csl.coordinate.latitude, csl.coordinate.longitude )
        }
        
        self.presentingViewController!.dismiss(animated: true, completion: nil)

    }
    
    func changeLocation() {
        
        let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
        dashboardLocationVC.isFromNewHome = true
        dashboardLocationVC.isRootController = true
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [dashboardLocationVC]
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setLogoHidden(true)
        DispatchQueue.main.async {
            if let top = UIApplication.topViewController() {
                top.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    class func getViewController() -> LocationChangedViewController {
        
        return LocationChangedViewController(nibName: "LocationChangedViewController", bundle: nil) as LocationChangedViewController
    }
    
}
