//
//  ViewAllCollectionCell.swift
//  
//
//  Created by Rashid Khan on 28/05/2024.
//

import UIKit
import RxSwift

class ViewAllCollectionCell: RxUICollectionViewCell {
    @IBOutlet weak var viewAllStackView: UIStackView!
    
    @IBOutlet weak var icForward: UIImageView!
    @IBOutlet weak var lblViewAll: UILabel!
    private var viewModel: ViewAllCollectionCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewAllStackView.isUserInteractionEnabled = true
        viewAllStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (viewAllTapped)))
    }

    override func configure(viewModel: Any) {
        self.viewModel = viewModel as? ViewAllCollectionCellViewModelType
        
        self.viewModel.outputs.viewAllText
            .bind(to: lblViewAll.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.isArabic
            .subscribe(onNext: { [weak self] isArabic in
                if isArabic {
                    self?.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    self?.icForward.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            }).disposed(by: disposeBag)
        
    }
    
    @objc func viewAllTapped(_ sender: UITapGestureRecognizer) {
        viewModel.inputs.viewAllTapObserver.onNext(())
    }
}

protocol ViewAllCollectionCellViewModelInput { 
    var viewAllTapObserver: AnyObserver<Void> { get }
}

protocol ViewAllCollectionCellViewModelOutput { 
    var viewAllTap: Observable<Void> { get }
    var viewAllText: Observable<String> { get }
    var isArabic: Observable<Bool> { get }
}

protocol ViewAllCollectionCellViewModelType {
    var inputs: ViewAllCollectionCellViewModelInput { get }
    var outputs: ViewAllCollectionCellViewModelOutput { get }
}

class ViewAllCollectionCellViewModel: ViewAllCollectionCellViewModelType, ViewAllCollectionCellViewModelInput, ViewAllCollectionCellViewModelOutput {
    var inputs: ViewAllCollectionCellViewModelInput { self }
    var outputs: ViewAllCollectionCellViewModelOutput { self }
    
    var viewAllTapObserver: AnyObserver<Void> { viewAllTapSubject.asObserver() }
    var viewAllTap: Observable<Void> { viewAllTapSubject.asObservable() }
    var viewAllText: Observable<String> { viewAllTextSubject.asObservable() }
    var isArabic: Observable<Bool> { isArabicSubject.asObservable() }
    
    
    private let viewAllTapSubject: PublishSubject<Void> = .init()
    private let viewAllTextSubject: BehaviorSubject<String> = .init(value: localizedString("lbl_View_All_Cap", comment: ""))
    private let isArabicSubject: BehaviorSubject<Bool> = .init(value: ElGrocerUtility.sharedInstance.isArabicSelected())
    
    init() { }
}

extension ViewAllCollectionCellViewModel: ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { ViewAllCollectionCell.defaultIdentifier }
}
