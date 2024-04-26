//
//  SmilesPointsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 04/12/2023.
//

import UIKit
import RxSwift
import RxCocoa

class SmilesPointsViewController: UIViewController {
    /// Views
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblMinAED: UILabel!
    @IBOutlet weak var lblMinPoints: UILabel!
    @IBOutlet weak var lblAvailableAED: UILabel!
    @IBOutlet weak var lblAvailablePoints: UILabel!
    @IBOutlet weak var confirmButton: AWButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var lblAmountDue: UILabel!
    @IBOutlet weak var lblRemaningAmount: UILabel!
    @IBOutlet weak var lblAmountDueText: UILabel!
    @IBOutlet weak var lblAmountRemaningText: UILabel!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var tfRedeemAmount: PaddedLeftRightViewTextField!
    @IBOutlet weak var lblLowerLimitAEDs: UILabel!
    @IBOutlet weak var lblLowerLimitPts: UILabel!
    
    /// Properties
    fileprivate var viewModel: SmilesPointsViewModelType!
    fileprivate var disposeBag = DisposeBag()
    fileprivate let DEFAULT_HEIGHT = 380.0
    
    var confirmButtonTapHandler: ((Int)->())?
    
    /// Initliazations
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(viewModel: SmilesPointsViewModelType) {
        self.init(nibName: "SmilesPointsViewController", bundle: .resource)
        
        self.viewModel = viewModel
        self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: DEFAULT_HEIGHT)
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
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.viewModel.inputs.sliderValueObserver.onNext(sender.value)
    }
}

fileprivate extension SmilesPointsViewController {
    func setupViews() {
        slider.setThumbImage(UIImage(name: "smileLogo"), for: .normal)
        slider.minimumValue = 0
        tfRedeemAmount.keyboardType = .numberPad
        tfRedeemAmount.textAlignment = .right
        tfRedeemAmount.leftView = {
            let label = UILabel()
            label.text = localizedString("redeem_funds_text", comment: "")
            label.setCaptionOneRegDarkStyle()
            return label
        }()
        
        tfRedeemAmount.rightView = {
            let label = UILabel()
            label.text = localizedString("smile_point_unit", comment: "")
            label.setBody1RegPlaceholderStyle()
            return label
        }()
        tfRedeemAmount.leftViewMode = .always
        tfRedeemAmount.rightViewMode = .always
        tfRedeemAmount.delegate = self
    }
    
    func setupTheme() {
        lblTitle.setH4SemiBoldSmilesStyle()
        lblDescription.setCaptionTwoRegDarkStyle()
        tfRedeemAmount.setBody1RegStyle()
        lblMinAED.setCaptionOneRegSmilesStyle()
        lblAvailableAED.setCaptionOneRegSmilesStyle()
        lblMinPoints.setCaptionOneSemiBoldSmilesStyle()
        lblAvailablePoints.setCaptionOneSemiBoldSmilesStyle()
        lblLowerLimitPts.setCaptionOneSemiBoldSmilesStyle()
        lblLowerLimitAEDs.setCaptionOneSemiBoldSmilesStyle()
        confirmButton.setBody3BoldWhiteStyle()
        
        lblAmountDue.setCaptionOneRegDarkStyle()
        lblRemaningAmount.setCaptionOneRegDarkStyle()
        lblAmountDueText.setCaptionOneRegDarkStyle()
        lblAmountRemaningText.setCaptionOneRegDarkStyle()
        lblError.setCaptionOneRegErrorStyle()
        
        confirmButton.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        slider.minimumTrackTintColor = UIColor.smileBaseColor()
    }
    
    func setupBindings() {
        viewModel.outputs.localizedText.subscribe(onNext: { [weak self] strings in
            guard let self = self else { return }
            
            self.lblTitle.text = strings.title
            self.lblDescription.text = strings.description
            self.lblAmountDueText.text = strings.amountDue
            self.lblAmountRemaningText.text = strings.amountRemaining
            self.confirmButton.setTitle(strings.confirmButtonTitle, for: .normal)
            
        }).disposed(by: disposeBag)
        
        viewModel.outputs.smilesPointsRedeemed
            .bind(to: tfRedeemAmount.rx.text)
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
        
        viewModel.outputs.sliderCurrentValue
            .delay(.milliseconds(1), scheduler: MainScheduler.instance)
            .bind(to: slider.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.outputs.sliderLimit
            .subscribe(onNext: { [weak self] (lower, upper)in
                guard let self = self else { return }
                
                self.slider.minimumValue = Float(lower)
                self.slider.maximumValue = Float(upper)
                self.lblLowerLimitPts.text = "(\(lower) pts)"
                self.lblLowerLimitAEDs.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: Double(lower))
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.availablePointsConvertedToAED
            .bind(to: lblAvailableAED.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.availableSmilesPoints
            .bind(to: lblAvailablePoints.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.amountDueInAED
            .bind(to: lblAmountDue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.amountRemaningInAED
            .bind(to: lblRemaningAmount.rx.text)
            .disposed(by: disposeBag)

        /// Actions
        confirmButton.rx.tap
            .bind(to: viewModel.inputs.confirmButtonTapObserver)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.outputs.result
            .subscribe { [weak self] sliderValue in
                guard let self = self else { return }
                
                if let confirmButtonTapHandler = self.confirmButtonTapHandler {
                    confirmButtonTapHandler(sliderValue)
                    self.dismiss(animated: true)
                }
            }.disposed(by: disposeBag)
    }
}
extension SmilesPointsViewController: UITextFieldDelegate {
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
