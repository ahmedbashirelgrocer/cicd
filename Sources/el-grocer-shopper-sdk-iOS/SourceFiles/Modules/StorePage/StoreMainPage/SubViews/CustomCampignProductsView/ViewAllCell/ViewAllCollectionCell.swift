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
    
    private var viewModel: ViewAllCollectionCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewAllStackView.isUserInteractionEnabled = true
        viewAllStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (viewAllTapped)))
    }

    override func configure(viewModel: Any) {
        self.viewModel = viewModel as? ViewAllCollectionCellViewModelType
        
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
    
    
    private let viewAllTapSubject: PublishSubject<Void> = .init()
    
    init() { }
}

extension ViewAllCollectionCellViewModel: ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { ViewAllCollectionCell.defaultIdentifier }
}
