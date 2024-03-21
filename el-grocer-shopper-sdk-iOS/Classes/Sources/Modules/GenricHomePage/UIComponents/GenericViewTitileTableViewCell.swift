//
//  GenericViewTitileTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import RxSwift

let KGenericViewTitileTableViewCell = "GenericViewTitileTableViewCell"
let KGenericViewTitileTableViewCellHeight : CGFloat = 27

protocol TableViewTitleCellViewModelInput {
    var viewAllTapObserver: AnyObserver<Void> { get }
}

protocol TableViewTitleCellViewModelOutput {
    var title: Observable<String?> { get }
    var showViewMoreButton: Observable<Bool> { get }
    var viewAll: Observable<Void> { get }
}

protocol TableViewTitleCellViewModelType: TableViewTitleCellViewModelInput, TableViewTitleCellViewModelOutput {
    var inputs: TableViewTitleCellViewModelInput { get }
    var outputs: TableViewTitleCellViewModelOutput { get }
}

extension TableViewTitleCellViewModelType {
    var inputs: TableViewTitleCellViewModelInput { self }
    var outputs: TableViewTitleCellViewModelOutput { self }
}

class TableViewTitleCellViewModel: TableViewTitleCellViewModelType, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { "GenericViewTitileTableViewCell" }
    
    // Inputs
    var viewAllTapObserver: AnyObserver<Void> { viewAllSubject.asObserver() }
    
    // Outputs
    var title: Observable<String?> { titleSubject.asObservable() }
    var showViewMoreButton: Observable<Bool> { showViewMoreButtonSubject.asObservable() }
    var viewAll: Observable<Void> { viewAllSubject.asObservable() }
    
    // Subjects
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let showViewMoreButtonSubject = BehaviorSubject<Bool>(value: false)
    private let viewAllSubject = PublishSubject<Void>()
    
    init(title: String, showViewMore: Bool) {
        titleSubject.onNext(title)
        showViewMoreButtonSubject.onNext(showViewMore)
    }
}

class GenericViewTitileTableViewCell: RxUITableViewCell {
    
    
    var isTitleOnly : Bool = false {
        
        didSet{
            
            guard viewAllWidth != nil else {return}
            
            if isTitleOnly {
                viewAllWidth.constant = 0
            }else{
                viewAllWidth.constant = 80
            }
            
            self.layoutIfNeeded()
            self.setNeedsLayout()
        }
        
    }

    var viewAllAction: (()->Void)?
    @IBOutlet var lblTopHeader: UILabel!  {
        didSet {
            lblTopHeader.setH4SemiBoldStyle()
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    self.lblTopHeader.textAlignment = .right
                }else{
                    self.lblTopHeader.textAlignment = .left
                }
            }
        }
    }
    
    @IBOutlet var viewAllWidth: NSLayoutConstraint!
    @IBOutlet var viewAll: AWView!
    @IBOutlet var rightButtonText: UILabel! {
        didSet {
            rightButtonText.setCaptionOneBoldUpperCaseGreenButtonStyleWithFontScale14()
            rightButtonText.text = localizedString("view_more_title", comment: "")
        }
    }
    @IBOutlet var arrowImage: UIImageView! {
        didSet{
            arrowImage.image =  UIImage(name: sdkManager.isShopperApp ? "arrowRight" : "SettingArrowForward")
        }
    }
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    var viewModel: TableViewTitleCellViewModelType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? TableViewTitleCellViewModelType else { return }
        
        self.viewModel = viewModel
        
        viewModel.outputs.title
            .bind(to: self.lblTopHeader.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.showViewMoreButton
            .subscribe(onNext: { [weak self] showViewMore in
                guard let self = self else { return }
                
                self.viewAll.isHidden = !showViewMore
                self.arrowImage.isHidden = !showViewMore
                self.viewAll.visibility = !showViewMore ? .gone : .visible
                
            }).disposed(by: disposeBag)
        
        if ElGrocerUtility.sharedInstance.isArabicSelected(){
            arrowImage.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        self.backgroundColor = .white
        self.cellHeight.constant = KGenericViewTitileTableViewCellHeight + 23
        self.invalidateIntrinsicContentSize()
    }
    
    func configureCell( title : String , _ isNeedToShowViewMore : Bool = false) {
        lblTopHeader.text = title
        if self.contentView.frame.size.height > 5 {
            lblTopHeader.isHidden = false
             viewAll.isHidden = !isNeedToShowViewMore
             arrowImage.isHidden = !isNeedToShowViewMore
        }else{
             viewAll.isHidden = true
            lblTopHeader.isHidden = true
        }
        viewAll.visibility = viewAll.isHidden ? .goneX : .visible
       
        if ElGrocerUtility.sharedInstance.isArabicSelected(){
            arrowImage.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        
    }
    
    func configureCellWithEditOrder( title : String ) {
        lblTopHeader.text = title
        if self.contentView.frame.size.height > 5 {
            lblTopHeader.isHidden = false
            viewAll.isHidden = false
        }else{
            viewAll.isHidden = true
            lblTopHeader.isHidden = true
        }
        //viewAll.backgroundColor = .white
        viewAll.visibility = viewAll.isHidden ? .goneX : .visible
        arrowImage.isHidden = false
        rightButtonText.setBody1BoldButtonStyle()
        rightButtonText.text = localizedString("btn_txt_edit", comment: "")
    }
    
    
    @IBAction func viewAllAction(_ sender: Any) {
        if let viewModel = self.viewModel {
            viewModel.inputs.viewAllTapObserver.onNext(())
            return
        }
        
        if let click = viewAllAction {
            click()
        }
    }
    
}
