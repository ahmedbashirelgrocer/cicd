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
    
    private var viewModel: ActiveCartListingViewModelType!
    
    static func make(viewModel: ActiveCartListingViewModelType) -> ActiveCartListingViewController {
        let vc = ActiveCartListingViewController(nibName: "ActiveCartListingViewController", bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViews()
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


private extension ActiveCartListingViewController {
    func bindViews() { }
}
