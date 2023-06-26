//
//  TabbyTermsAndConditionsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 26/06/2023.
//

import UIKit

private struct PrivacyPolicyParagraph {
    let title: String
    let description: String
}

class TabbyTermsAndConditionsViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setBody2SemiboldDarkStyle()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private let privacyPolicyArray: [PrivacyPolicyParagraph] = [
        PrivacyPolicyParagraph(
            title: NSLocalizedString("tabby_tc_paraghraph_one_title", comment: ""),
            description: NSLocalizedString("tabby_tc_paraghraph_one_description", comment: "")
        ),
        PrivacyPolicyParagraph(
            title: NSLocalizedString("tabby_tc_paraghraph_second_title", comment: ""),
            description: NSLocalizedString("tabby_tc_paraghraph_second_description", comment: "")
        ),
        PrivacyPolicyParagraph(
            title: NSLocalizedString("tabby_tc_paraghraph_third_title", comment: ""),
            description: NSLocalizedString("tabby_tc_paraghraph_third_description", comment: "")
        ),
        PrivacyPolicyParagraph(
            title: NSLocalizedString("tabby_tc_paraghraph_forth_title", comment: ""),
            description: NSLocalizedString("tabby_tc_paraghraph_forth_description", comment: "")
        ),
    ]
    private let cellIdentifier = "TermsAndConditionsTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = NSLocalizedString("tabby_terms_and_conditions_title", comment: "")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: cellIdentifier, bundle: .main), forCellReuseIdentifier: cellIdentifier)
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension TabbyTermsAndConditionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.privacyPolicyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TermsAndConditionsTableViewCell
        
        cell.configure(title: self.privacyPolicyArray[indexPath.row].title, description: self.privacyPolicyArray[indexPath.row].description)
        return cell
    }
}
