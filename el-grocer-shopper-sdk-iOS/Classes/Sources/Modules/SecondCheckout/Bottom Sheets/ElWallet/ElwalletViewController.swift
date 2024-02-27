//
//  ElwalletViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 05/12/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ElwalletViewController: UIViewController {
    /// Views
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblLowerLimit: UILabel!
    @IBOutlet weak var lblUpperLimit: UILabel!
    @IBOutlet weak var confirmButton: AWButton!
    @IBOutlet weak var lblAmountDue: UILabel!
    @IBOutlet weak var lblRemainingAmount: UILabel!
    @IBOutlet weak var tfRedeemAmount: PaddedLeftRightViewTextField!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAmountDueText: UILabel!
    @IBOutlet weak var lblRemaningAmountText: UILabel!
    @IBOutlet weak var lblError: UILabel!
    /// Properties
    fileprivate let DEFAULT_HEIGHT = 360.0
    fileprivate var viewModel: ElWalletViewModelType!
    fileprivate var disposeBag = DisposeBag()
    
    var confirmButtonTapHandler: ((Double)->())?
    
    /// Initiazations
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(viewModel: ElWalletViewModelType) {
        self.init(nibName: "ElwalletViewController", bundle: .resource)
        
        self.viewModel = viewModel
        self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: DEFAULT_HEIGHT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTheme()
        setupBindings()
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        self.viewModel.inputs.sliderObserver.onNext(sender.value)
    }
}

fileprivate extension ElwalletViewController {
    func setupViews() {
        slider.setThumbImage(UIImage(name: "elWallet"), for: .normal)
        slider.minimumValue = 0
        tfRedeemAmount.leftView = {
            let label = UILabel()
            label.text = localizedString("redeem_funds_text", comment: "")
            label.setCaptionOneRegDarkStyle()
            return label
        }()
        
        tfRedeemAmount.rightView = {
            let label = UILabel()
            label.text = localizedString("aed", comment: "")
            label.setBody1RegPlaceholderStyle()
            return label
        }()
        tfRedeemAmount.leftViewMode = .always
        tfRedeemAmount.rightViewMode = .always
        tfRedeemAmount.delegate = self
    }
    
    func setupTheme() {
        lblTitle.setH4SemiBoldStyle()
        lblDescription.setCaptionTwoRegDarkStyle()
        tfRedeemAmount.setBody1RegStyle()
        lblLowerLimit.setCaptionOneRegDarkStyle()
        lblUpperLimit.setCaptionOneRegDarkStyle()
        confirmButton.setBody3BoldWhiteStyle()
        
        lblAmountDue.setCaptionOneRegDarkStyle()
        lblRemainingAmount.setCaptionOneRegDarkStyle()
        lblAmountDueText.setCaptionOneRegDarkStyle()
        lblRemaningAmountText.setCaptionOneRegDarkStyle()
        lblError.setCaptionOneRegErrorStyle()
        
        confirmButton.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        slider.minimumTrackTintColor = .black
    }
    
    func setupBindings() {
        
        viewModel.outputs.localizedText.subscribe(onNext: { [weak self] strings in
            guard let self = self else { return }
            
            self.lblTitle.text = strings.title
            self.lblDescription.text = strings.description
            self.lblAmountDueText.text = strings.amountDue
            self.lblRemaningAmountText.text = strings.amountRemaining
            self.confirmButton.setTitle(strings.confirmButtonTitle, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.redeemedAmount
            .bind(to: tfRedeemAmount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.sliderLimit
            .subscribe(onNext: { [weak self] (lowerLimit, upperLimit) in
                guard let self = self else { return }
                
                self.slider.minimumValue = lowerLimit
                self.slider.maximumValue = upperLimit
            }).disposed(by: disposeBag)
        
        viewModel.outputs.sliderCurrentValue
            .bind(to: self.slider.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.outputs.sliderLimit
            .map { lower, upper in Double(lower) }
            .map { ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: $0) }
            .bind(to: lblLowerLimit.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.availableBalance
            .bind(to: lblUpperLimit.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.amountDue
            .bind(to: lblAmountDue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.amountRemaining
            .bind(to: lblRemainingAmount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                self.lblError.isHidden = false
                self.lblError.text = error
                
                let errorLabelPadding = 12.0
                let height = error?.heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 32, font: UIFont.SFProDisplayNormalFont(12)) ?? 0.0
                self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: DEFAULT_HEIGHT + height + errorLabelPadding)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.result
            .subscribe(onNext: { [weak self] redeem in
                if let confirmButtonTapHandler = self?.confirmButtonTapHandler {
                    confirmButtonTapHandler(redeem)
                    self?.dismiss(animated: true)
                }
            }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(to: viewModel.inputs.confirButtonTapObserver)
            .disposed(by: disposeBag)
    }
}

extension ElwalletViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lblError.isHidden = true
        self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: DEFAULT_HEIGHT)
        let currentRedeem = Double(textField.text?.removingWhitespaceAndNewlines() ?? "0") ?? 0.00
        textField.text = currentRedeem == 0 ? "" : textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfRedeemAmount {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.viewModel.inputs.textFieldObserver.onNext(updatedText)
                
                return updatedText.count <= 9
            }
        }
        
        return true
    }
}
