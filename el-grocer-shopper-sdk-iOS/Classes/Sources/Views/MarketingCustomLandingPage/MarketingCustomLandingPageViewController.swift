//
//  MarketingCustomLandingPageViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class MarketingCustomLandingPageViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    private lazy var emptyView : NoStoreView = {
        let emptyView = NoStoreView.loadFromNib()
        emptyView?.delegate = self; emptyView?.configureNoDefaultSelectedStoreCart()
        return emptyView!
    }()
    lazy var locationHeader : ElgrocerlocationView = {
    let locationHeader = ElgrocerlocationView.loadFromNib()
    locationHeader?.translatesAutoresizingMaskIntoConstraints = false
    return locationHeader!
}()
    lazy var locationHeaderShopper : ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    lazy var locationHeaderFlavor : ElgrocerStoreHeader = {
    let locationHeader = ElgrocerStoreHeader.loadFromNib()
        locationHeader?.setDismisType(.dismisVC)
    locationHeader?.translatesAutoresizingMaskIntoConstraints = false
    return locationHeader!
}()
         var superSectionHeader: SubCateSegmentTableViewHeader!
    
    // MARK: - Properties
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionHeaderModel<Int,String, ReusableTableViewCellViewModelType>>!
    private var sections: [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
    private let tableViewScrollSubject = PublishSubject<(contentOffset: CGPoint, didScrollEvent: Void)>()
    private var collectionViewBottomConstraint: NSLayoutConstraint?
        var viewModel: MarketingCustomLandingPageViewModel!
    private let disposeBag = DisposeBag()
    
    var effectiveOffset: CGFloat = 0
    var offset: CGFloat = 0 {
        didSet {
            let diff = offset - oldValue
            if diff > 0 { effectiveOffset = min(60, effectiveOffset + diff) }
            else { effectiveOffset = max(0, effectiveOffset + diff) }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppSetting.theme.tableViewBGGreyColor;
        addLocationHeader(); registerCells(); bindViews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        adjustHeaderDisplay()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.viewDidAppearCalled() // we need to call this method to sync active grocery in utilty
        self.viewModel.basketUpdatedSubject.onNext(())
        
    }
    
    @objc func backButtonPressed() {
        self.backButtonClick()
    }
    
    private func registerCells() {
        
        tableView.register(UINib(nibName: RxBannersTableViewCell.defaultIdentifier, bundle: .resource), forCellReuseIdentifier: RxBannersTableViewCell.defaultIdentifier)
        tableView.register(UINib(nibName: RxCollectionViewOnlyTableViewCell.defaultIdentifier, bundle: .resource), forCellReuseIdentifier: RxCollectionViewOnlyTableViewCell.defaultIdentifier)
        tableView.register(UINib(nibName: "HomeCell", bundle: .resource), forCellReuseIdentifier: kHomeCellIdentifier)
        tableView.separatorColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.bounces = true
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = AppSetting.theme.tableViewBGGreyColor
       
        tableView.rx.didScroll
                    .subscribe(onNext: { [weak self] in
                        // Notify the subject with both content offset and did scroll event
                        guard let contentOffset = self?.tableView.contentOffset else { return }
                        self?.tableViewScrollSubject.onNext((contentOffset, ()))
                    })
                    .disposed(by: disposeBag)
        
    }
    
   
    private func bindViews() {
        
        self.superSectionHeader   = (Bundle.resource.loadNibNamed("SubCateSegmentTableViewHeader", owner: self, options: nil)![0] as? SubCateSegmentTableViewHeader)!
        self.superSectionHeader.frame = CGRect.init(origin: .zero, size: CGSize.init(width: ScreenSize.SCREEN_WIDTH , height: KSubCateSegmentTableViewHeaderWithOutMessageHeight))
        self.superSectionHeader.refreshWithSubCategoryText("")
        self.superSectionHeader.segmenntCollectionView.segmentDelegate = self
        self.superSectionHeader.viewLayoutCliced = { () in }
        
        
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            debugPrint("IndexPath is: \(indexPath)")
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            cell.selectionStyle = .none
            cell.configure(viewModel: viewModel)
            cell.bind(to: self.tableViewScrollSubject)
            return cell
        },titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        })
//        
//        self.tableView.rx.willDisplayCell
//            .subscribe(onNext: { (cell, indexPath) in
//                let cell = tableView.cellForRow(at:indexPath)
//                cell.hi
//            })
//           
        
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
        
        viewModel.outputs.selectedgrocery.subscribe(onNext: { [weak self] grocery in
            guard let self = self, let grocery = grocery else { return }
            setHeaderData(grocery)
            ElGrocerUtility.sharedInstance.delay(1.5) { [weak self] in
                self?.setCollectionViewBottomConstraint()
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.outputs.loading.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            loading
                ? _ = SpinnerView.showSpinnerViewInView(self.view)
                : SpinnerView.hideSpinnerView()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.showEmptyView.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.emptyView.configureNoActiveCampaign()
            self.tableView.backgroundView = self.emptyView
            self.locationHeaderFlavor.isHidden = true
            self.locationHeader.isHidden = true
            self.locationHeaderShopper.isHidden = true
        }).disposed(by: disposeBag)
        
        
        viewModel.outputs.filterArrayData.subscribe(onNext: { [weak self] filter in
            guard let self = self, filter.count > 0 else { return }
            self.newTitleArrayUpdate(data: filter, selectedIndexPath: NSIndexPath.init(row: 0, section: 0))
        }).disposed(by: disposeBag)
        
        
        viewModel.basketUpdated
            .filter({ self.basketIconOverlay != nil })
            .subscribe { _ in
            guard let cartView = self.basketIconOverlay else { return }
                cartView.grocery = self.viewModel.getGrocery()
            self.refreshBasketIconStatus()
            let itemCount =  ElGrocerUtility.sharedInstance.lastItemsCount
            self.collectionViewBottomConstraint?.isActive = itemCount > 0
            self.refreshBasketIconStatus()
        }.disposed(by: disposeBag)

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
        tableView.contentOffset = CGPoint(x: 0, y: -imageHeight)
    }
    
    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setCollectionViewBottomConstraint() {
        
       // var itemCount =  0
        if (collectionViewBottomConstraint == nil) && (self.basketIconOverlay != nil) {
            collectionViewBottomConstraint = NSLayoutConstraint(item:
                                        self.basketIconOverlay!,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.tableView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
            self.basketIconOverlay?.grocery = self.viewModel.getGrocery()
            self.refreshBasketIconStatus()
//            itemCount = Int(self.basketIconOverlay?.itemsCount.text ?? "0") ?? 0
        }
        
        collectionViewBottomConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
       
    }
    
}

extension MarketingCustomLandingPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
////      
//        do {
//            let lastValue = try self.viewModel.tableviewVmsSubject.value()
//            let isCategorySection = lastValue[indexPath.section].items.count > 0
//            if isCategorySection {
//                let categoryOrProductSection = lastValue[indexPath.section].items[0]
//                if ((categoryOrProductSection as? RxCollectionViewOnlyTableViewCellViewModel) != nil) {
//                    let categoryOrProductSectionVmCount = (categoryOrProductSection as? RxCollectionViewOnlyTableViewCellViewModel)?.productCountValue ?? 0
//                    debugPrint("collection view cell height changes ;;; \(categoryOrProductSectionVmCount)")
//                    return CGFloat(ceil(Double(categoryOrProductSectionVmCount) / 2.0)) * (kProductCellHeight) + 32
//                }
//            }
//        } catch {  print("Error: \(error.localizedDescription)")  }

        return UITableView.automaticDimension
       }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var isSubcategorySection : Bool = false
        do {
            let lastValue = try self.viewModel.tableviewVmsSubject.value()
            if  section < lastValue.count { isSubcategorySection = lastValue[section].items.count > 1 }
        } catch {  print("Error: \(error.localizedDescription)")  }
        
        let isTextAvailable = dataSource.sectionModels[section].header.count > 0 && dataSource.sectionModels[section].items.count > 0
        if isSubcategorySection {
            self.superSectionHeader.refreshWithCategoryName(dataSource.sectionModels[section].header)
            return self.superSectionHeader
        }
        guard isTextAvailable else {
            let view = UIView()
            view.backgroundColor = section == 0 ? .clear : .white
            return view }
        let height =   isTextAvailable ? 30.0 : 1.0
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: height + 20))
        headerView.backgroundColor = .white //isTextAvailable ? .white : .clear
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 30.0, height: height))
        label.text = dataSource.sectionModels[section].header
        label.setH4SemiBoldStyle()
        headerView.addSubview(label)
        headerView.clipsToBounds = true
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var isSubcategorySection : Bool = false
        do {
            let lastValue = try self.viewModel.tableviewVmsSubject.value()
            if  section < lastValue.count { isSubcategorySection = lastValue[section].items.count > 1 }
            
        } catch {  print("Error: \(error.localizedDescription)")  }
        
        let isTextAvailable = dataSource.sectionModels[section].header.count > 0
        if isSubcategorySection{
            return KSubCateSegmentTableViewHeaderWithOutMessageHeight
        }
        return isTextAvailable ? 30.0 : 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
}

extension MarketingCustomLandingPageViewController: AWSegmentViewProtocol {
    
    func newTitleArrayUpdate(data: [Filter] ,  selectedIndexPath: NSIndexPath) {
            self.superSectionHeader.configureView(data.map({ ElGrocerUtility.sharedInstance.isArabicSelected() ? $0.nameAR : $0.name }), index: selectedIndexPath)
    }
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex: Int) {
        self.viewModel.inputs.filterUpdateIndexObserver.onNext(selectedSegmentIndex)
    }
}

extension MarketingCustomLandingPageViewController: NoStoreViewDelegate, BasketIconOverlayViewProtocol {
    func noDataButtonDelegateClick(_ state: actionState) {
        self.dismiss(animated: true)
    }
    func basketIconOverlayViewDidTouchBasket(_ basketIconOverlayView: BasketIconOverlayView) {
        
    }
}


