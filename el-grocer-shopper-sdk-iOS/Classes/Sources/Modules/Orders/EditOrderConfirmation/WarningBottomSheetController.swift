//
//  EditOrderConfirmationViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/02/2024.
//

import UIKit
import RxSwift
import RxCocoa

class WarningBottomSheetController: UIViewController {

    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var btnPositive: UIButton!
    @IBOutlet weak var btnNegative: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    private var viewModel: WarningBottomSheetViewModelType!
    private var disposeBag = DisposeBag()
    
    var positiveButtonTapHandler: (()->())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(viewModel: WarningBottomSheetViewModelType) {
        self.init(nibName: "WarningBottomSheetController", bundle: .resource)
        
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupBindings()
    }
}

fileprivate extension WarningBottomSheetController {
    func setupViews() {
        btnPositive.layer.cornerRadius = 28.0
    }
    
    func setupTheme() {
        ivIcon.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        lblMsg.setBody2RegDarkStyle()
        
        btnPositive.setH4SemiBoldAppBaseColorStyle()
        btnPositive.setTitleColor(.white, for: .normal)
        btnPositive.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        btnNegative.setH4SemiBoldAppBaseColorStyle()
        btnNegative.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
    }
    
    func setupBindings() {
        viewModel.outputs.icon
            .map { UIImage(name: $0 ?? "")?.withRenderingMode(.alwaysTemplate) }
            .bind(to: ivIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.localizedStrings
            .subscribe(onNext: { [weak self] strings in
                guard let self = self else { return }
                
                self.lblMsg.text = strings.message
                self.btnPositive.setTitle(strings.positiveButtonTitle, for: .normal)
                self.btnNegative.setTitle(strings.negativeButtonTitle, for: .normal)
            }).disposed(by: disposeBag)
        
        btnPositive.rx.tap.subscribe(onNext: { [weak self] in
            if let positiveButtonTapHandler = self?.positiveButtonTapHandler {
                positiveButtonTapHandler()
            }
            
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        btnNegative.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        btnClose.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}
