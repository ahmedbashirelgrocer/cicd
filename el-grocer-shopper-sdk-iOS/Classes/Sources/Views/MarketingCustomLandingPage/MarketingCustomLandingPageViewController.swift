//
//  MarketingCustomLandingPageViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//
import UIKit
import RxSwift
import RxDataSources
class MarketingCustomLandingPageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private lazy var emptyView : NoStoreView = {
        let emptyView = NoStoreView.loadFromNib()
        emptyView?.delegate = self; emptyView?.configureNoDefaultSelectedStoreCart()
        return emptyView!
    }()
    // MARK: - Properties
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionHeaderModel<Int,String, ReusableTableViewCellViewModelType>>!
        var viewModel: MarketingCustomLandingPageViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white; registerCells(); bindViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func registerCells() {
        
        tableView.register(UINib(nibName: RxBannersTableViewCell.defaultIdentifier, bundle: .resource), forCellReuseIdentifier: RxBannersTableViewCell.defaultIdentifier)
        tableView.register(UINib(nibName: "HomeCell", bundle: .resource), forCellReuseIdentifier: kHomeCellIdentifier)

        tableView.separatorColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    private func bindViews() {
        
        
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            debugPrint("IndexPath is: \(indexPath)")
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            cell.selectionStyle = .none
            cell.configure(viewModel: viewModel)
            return cell
        },titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        })
        
        viewModel.outputs.cellViewModels
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(DynamicComponentContainerCellViewModel.self)
            .bind(to: self.viewModel.inputs.cellSelectedObserver)
            .disposed(by: disposeBag)
        
        viewModel.outputs.tableViewBackGround
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { [weak self] components in
                       self?.addTableViewBackgroundComponent(components)
                   })
                   .disposed(by: disposeBag)
        viewModel.outputs.loading.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            loading
                ? _ = SpinnerView.showSpinnerViewInView(self.view)
                : SpinnerView.hideSpinnerView()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.showEmptyView.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            self.emptyView.configureNoActiveCampaign()
            self.tableView.backgroundView = self.emptyView
           
        }).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.itemSelected
                    .subscribe(onNext: { indexPath in })
                    .disposed(by: disposeBag)
    }
}
extension MarketingCustomLandingPageViewController {
    private func addTableViewBackgroundComponent(_ uiObj: CampaignSection?) {
        
        guard let uiObj = uiObj, let image = uiObj.image, image.count > 0, let imageURL = URL(string: image) else {
                  return
        }
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.width))
        let backgroundImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.width))
        backgroundImageView.sd_setImage(with: imageURL, completed: { (_, _, _, _) in })
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.clipsToBounds = true
        backgroundImageView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        containerView.addSubview(backgroundImageView)
        tableView.backgroundView = containerView
        let imageHeight = UIScreen.main.bounds.width * 0.80
        tableView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
       // tableView.contentOffset = CGPoint(x: 0, y: 0)
    }
}

extension MarketingCustomLandingPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
       }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let height =   dataSource.sectionModels[section].header.count == 0 ? 5.0 : 30.0
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: height))
//        headerView.backgroundColor = .tableViewBackgroundColor()
//        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 30.0, height: height))
//        label.text = dataSource.sectionModels[section].header
//        label.setH4SemiBoldStyle()
//        headerView.addSubview(label)
//        return headerView
//    }
}

extension MarketingCustomLandingPageViewController: NoStoreViewDelegate {
    func noDataButtonDelegateClick(_ state: actionState) {
        self.dismiss(animated: true)
    }
}
