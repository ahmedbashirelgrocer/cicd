//
//  SplashViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 15/01/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.Splash.rawValue, screenClass: "SplashViewController")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
