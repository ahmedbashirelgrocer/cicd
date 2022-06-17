//
//  SmilesHomeVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 03/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class SmilesHomeVC: UIViewController, NavigationBarProtocol {

    var smilePoints: Int = 0
    var shouldDismiss: Bool = false
    private let viewModel = SmileUserViewModel()

    @IBOutlet weak var smileBalanceLabel: UILabel!{
        didSet{
            smileBalanceLabel.setBody3RegDarkStyle()
        }
    }
    
    @IBOutlet weak var smilePointsLabel: UILabel!{
        didSet{
            smilePointsLabel.setH2SemiBoldDarkStyle()
        }
    }
    
    @IBOutlet var btnStartShopping: AWButton! {
        didSet{
            btnStartShopping.setTitle(localizedString("lbl_StartShopping", comment: ""), for: UIControl.State())
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setInitialAppearence()

        self.bindData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        viewModel.getUserInfo()
    }

    private func bindData() {
        
        viewModel.smilePoints.bind { [weak self] smilePoints in
            self?.smilePoints = Int(smilePoints ?? 0)
            self?.smilePointsLabel.text = "\(Int(smilePoints ?? 0)) " + localizedString("txt_smile_point", comment: "")
            SpinnerView.hideSpinnerView()
        }
    }
    
    func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        self.title = localizedString("txt_smile_point", comment: "")
        smileBalanceLabel.text = localizedString("Your_balance", comment: "")
        smilePointsLabel.text = "\(smilePoints)" + " " + localizedString("txt_smile_point", comment: "")
    }
    
    override func backButtonClick() {
        
        if shouldDismiss {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    func setupNavigationAppearence(){
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()

    }

    @IBAction func startShoppingAction(_ sender: Any) {
        
        if shouldDismiss {
            self.navigationController?.dismiss(animated: false, completion: nil)
        }else {
            self.navigationController?.dismiss(animated: true) {
                UIApplication.topViewController()?.navigationController?.popToRootViewController(animated: true)
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

}
