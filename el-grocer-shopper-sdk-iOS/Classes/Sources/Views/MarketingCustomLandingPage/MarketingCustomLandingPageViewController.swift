//
//  MarketingCustomLandingPageViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//

import UIKit
import RxSwift
class MarketingCustomLandingPageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
        private let disposeBag = DisposeBag()
        var viewModel: MarketingCustomLandingPageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        bindViews()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func bindViews() {
        
        viewModel?.componentsSubject
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { [weak self] components in
                       self?.updateUI(with: components)
                   })
                   .disposed(by: disposeBag)
        
    }
    
    private func updateUI(with components: DynamicComponentContainer) {
            // Update your UI based on the new components
        tableView.reloadData()

               // Or, if you want to insert specific rows, assuming components is an array of sections:
               // (Modify this based on your specific data structure)
               var indexPathsToInsert: [IndexPath] = []

               for (sectionIndex, componentSection) in components.enumerated() {
                   for (rowIndex, _) in componentSection.enumerated() {
                       let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                       indexPathsToInsert.append(indexPath)
                   }
               }
               // Insert specific rows
               tableView.insertRows(at: indexPathsToInsert, with: .automatic)
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

