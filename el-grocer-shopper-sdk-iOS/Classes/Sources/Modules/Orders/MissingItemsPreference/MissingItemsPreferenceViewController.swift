//
//  MissingItemsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 15/11/2023.
//

import UIKit

class MissingItemsPreferenceViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setH4SemiBoldStyle()
        }
    }
    
    private var questions: [Reasons] = []
    private var selectedQuestion: Reasons?
    var selectionHandler: ((Reasons)->())?
    
    static func make(questions: [Reasons], selectedQuestion: Reasons?) -> MissingItemsPreferenceViewController {
        let vc = MissingItemsPreferenceViewController(nibName: "MissingItemsPreferenceViewController", bundle: .resource)
        vc.questions = questions
        vc.selectedQuestion = selectedQuestion
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Table View setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.register(UINib(nibName: "MissingItemsPreferenceCell", bundle: .resource), forCellReuseIdentifier: "MissingItemsPreferenceCell")
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension MissingItemsPreferenceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissingItemsPreferenceCell", for: indexPath) as! MissingItemsPreferenceCell
        
        cell.configure(reason: self.questions[indexPath.row], isSelected: self.selectedQuestion?.reasonKey == self.questions[indexPath.row].reasonKey)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectionHandler = self.selectionHandler {
            selectionHandler(self.questions[indexPath.row])
            self.dismiss(animated: true)
        }
    }
}
