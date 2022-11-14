//
//  ActiveCartListingViewController.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit

class ActiveCartListingViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: ActiveCartListingViewModel!
    
    static func make(viewModel: ActiveCartListingViewModel) -> ActiveCartListingViewController {
        let vc = ActiveCartListingViewController(nibName: "ActiveCartListingViewController", bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
