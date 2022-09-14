//
//  AccountDeletionSuccessVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 28/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class AccountDeletionSuccessVC: UIViewController, NoStoreViewDelegate {

    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureAccountDeletedSuccess()
        noStoreView?.backgroundColor = .navigationBarWhiteColor()
        return noStoreView!
    }()
    func noDataButtonDelegateClick(_ state: actionState) {
       elDebugPrint("go to entry view controller")
        let vc = ElGrocerViewControllers.entryViewController()
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setInitialAppearence()
        showDeletionSuccessView()
    }
    override func viewDidAppear(_ animated: Bool) {
        sdkManager.logout()
    }
    func setInitialAppearence(){
        
        self.view.backgroundColor = .navigationBarWhiteColor()
        self.navigationController?.removeBackButton()
        self.navigationItem.setHidesBackButton(true, animated: false)
        if self.navigationController is ElGrocerNavigationController{
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("delete_account", comment: "")
            self.title = localizedString("delete_account", comment: "")
        }
    }

    func showDeletionSuccessView() {

        NoDataView.frame = self.view.frame
        self.view.addSubview(NoDataView)
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
