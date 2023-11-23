//
//  MarketingCustomLandingPageViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//

import UIKit
import RxSwift
import RxDataSources
class MarketingCustomLandingPageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private lazy var emptyView : NoStoreView = {
        let emptyView = NoStoreView.loadFromNib()
        emptyView?.delegate = self
        emptyView?.configureNoDefaultSelectedStoreCart()
        return emptyView!
    }()
    
    // MARK: - Properties
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
        var viewModel: MarketingCustomLandingPageViewModel!
    private let disposeBag = DisposeBag()
    
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
        
       
        
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            cell.selectionStyle = .none
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.viewModel.outputs.cellViewModels
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(Component.self)
            .bind(to: self.viewModel.inputs.cellSelectedObserver)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.tableViewBackGround
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { [weak self] components in
                       self?.addTableViewBackgroundComponent(components)
                   })
                   .disposed(by: disposeBag)
        
        self.viewModel.outputs.loading.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            loading
                ? _ = SpinnerView.showSpinnerViewInView(self.view)
                : SpinnerView.hideSpinnerView()
        }).disposed(by: disposeBag)
        
        
        self.viewModel.outputs.showEmptyView.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            self.emptyView.configureNoActiveCampaign()
            self.tableView.backgroundView = self.emptyView
           
        }).disposed(by: disposeBag)
        
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
extension MarketingCustomLandingPageViewController {
    
    private func addTableViewBackgroundComponent(_ uiObj: Component?) {
        guard let uiObj = uiObj, let imageURL = URL(string: uiObj.image ?? "") else {
                  return
        }
        let backgroundImageView = UIImageView()
        backgroundImageView.sd_setImage(with: imageURL, completed: { (_, _, _, _) in })
        backgroundImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = backgroundImageView
    }
}
extension MarketingCustomLandingPageViewController: NoStoreViewDelegate {
    func noDataButtonDelegateClick(_ state: actionState) {
        self.dismiss(animated: true)
    }
}
