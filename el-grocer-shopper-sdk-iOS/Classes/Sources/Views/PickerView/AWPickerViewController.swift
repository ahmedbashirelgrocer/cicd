//
//  AWPickerViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 02/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.

import SwiftDate
import UIKit
import RxSwift
import RxDataSources
import RxCocoa

class AWPickerViewController : UIViewController {
    /// Views
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var slotsTableView: UITableView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var activityIndication: UIActivityIndicatorView!
    @IBOutlet var lblNoSlot: UILabel!
//    {
//        didSet {
//            lblNoSlot.text = localizedString("no_slot_available_message", comment: "")
//            lblNoSlot.isHidden = true
//        }
//    }
    
    /// Properties
    private var viewModel: AWPickerViewModelType!
    private var sliderDataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    private var slotsDataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    fileprivate var disposeBag = DisposeBag()
    var slotSelectedHandler: ((DeliverySlotDTO)->())?
    
    /// Initiazations
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: ScreenSize.SCREEN_HEIGHT / 2)
    }
    
    convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, viewModel: AWPickerViewModelType) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTheme()
        setupBindings()
        
        self.viewModel.inputs.fetchDeliveryObserver.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /// Actions
    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit >> slots bottom sheet")
    }
}

fileprivate extension AWPickerViewController {
    func setupViews() {
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        
        lblTitle.setH4SemiBoldStyle()
        lblNoSlot.setCaptionOneRegLightStyle()
        
        sliderCollectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 60)
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            return layout
        }()
        
        let sliderCellNib = UINib(nibName: DateSliderCollectionViewCell.defaultIdentifier, bundle: .resource)
        sliderCollectionView.register(sliderCellNib, forCellWithReuseIdentifier: DateSliderCollectionViewCell.defaultIdentifier)
        
        let slotsCellNib = UINib(nibName: SlotsTableViewCell.defaultIdentifier, bundle: .resource)
        slotsTableView.register(slotsCellNib, forCellReuseIdentifier: SlotsTableViewCell.defaultIdentifier)
    }
    
    func setupTheme() {
        activityIndication.color = ApplicationTheme.currentTheme.themeBasePrimaryColor
    }
    
    func setupBindings() {
        sliderDataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        slotsDataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.sliderDataSource
            .bind(to: sliderCollectionView.rx.items(dataSource: sliderDataSource))
            .disposed(by: disposeBag)
        
        sliderCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                self.viewModel.inputs.sliderSelectObserver.onNext(indexPath)
                self.sliderCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.slotsDataSource
            .bind(to: slotsTableView.rx.items(dataSource: self.slotsDataSource))
            .disposed(by: disposeBag)
                
        slotsTableView.rx.itemSelected
            .bind(to: viewModel.inputs.slotSelectedObserver)
            .disposed(by: disposeBag)
        
        viewModel.outputs.defaultSelection
            .subscribe(onNext: { [weak self] defaultSelectedIP in
                if let defaultSelectedIP = defaultSelectedIP {
                    self?.sliderCollectionView.selectItem(at: defaultSelectedIP.date, animated: true, scrollPosition: .centeredVertically)
                    self?.sliderCollectionView.scrollToItem(at: defaultSelectedIP.date, at: .centeredHorizontally, animated: true)
                    
                    self?.slotsTableView.selectRow(at: defaultSelectedIP.slot, animated: true, scrollPosition: .middle)
                }
            }).disposed(by: disposeBag)
                
        viewModel.outputs.error
            .map { !($0.1) }
            .bind(to: self.lblNoSlot.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .map { $0.0 }
            .bind(to: self.lblNoSlot.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.loading
            .bind(to: activityIndication.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.outputs.slotSelected
            .subscribe { [weak self] selectedSlot in
                if let slotSelectedHandler = self?.slotSelectedHandler {
                    slotSelectedHandler(selectedSlot)
                }
                
                self?.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
}
