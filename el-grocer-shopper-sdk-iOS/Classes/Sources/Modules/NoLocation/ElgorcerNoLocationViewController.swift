//
//  ElgorcerNoLocationViewController.swift
//  Adyen
//
//  Created by M Abubaker Majeed on 19/01/2023.
//

import UIKit

class ElgorcerNoLocationViewController: UIViewController {
    
    @IBOutlet weak var lblSorrytitle: UILabel! {
        didSet {
            lblSorrytitle.text = localizedString("", comment: "")
        }
    }
    @IBOutlet weak var lblSorryDetailMsg: UILabel! {
        didSet {
            lblSorryDetailMsg.text = localizedString("", comment: "")
        }
    }
    @IBOutlet weak var btnChangeLocation: UIButton! {
        didSet {
            btnChangeLocation.titleLabel?.text = localizedString("", comment: "")
        }
    }
    
    
    
    
    class func loadViewXib() -> ElgorcerNoLocationViewController {
       return ElgorcerNoLocationViewController(nibName: "ElgorcerNoLocationViewController", bundle: Bundle.resource)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func changeLocationClicked(_ sender: Any) {
        if let vcA = (self.presentationController?.presentingViewController as? ElGrocerNavigationController)?.viewControllers, vcA.count > 0, vcA[0] is DashboardLocationViewController {
            self.backButtonClicked("")
            return
        }
        self.dismiss(animated: true) {
            FlavorNavigation.shared.changeLocationNavigation(nil)
        }
        
        
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
