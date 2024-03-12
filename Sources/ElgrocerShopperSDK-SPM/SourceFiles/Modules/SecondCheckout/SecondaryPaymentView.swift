//
//  SecondryPaymentView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

protocol SecondaryPaymentViewDelegate: AnyObject {
    func switchStateChange(type: SourceType, switchState: Bool)
}
enum SecondaryPaymentViewType {
    case elWallet
    case smiles
    case both
    case none
}

class SecondaryPaymentView: UIView {
    private lazy var viewBG: AWView = {
        let view = AWView()
    
        view.backgroundColor = .white
        view.cornarRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var lblTitle: UILabel = {
       let label = UILabel()
        
        label.text = localizedString("use_points_text", comment: "")
        label.setCaptionOneBoldDarkStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private var elWalletView: PaymentSourceView = PaymentSourceView()
    private var smilesView: PaymentSourceView = PaymentSourceView()
    private var secondaryPaymentViewType: SecondaryPaymentViewType = .both
    weak var delegate: SecondaryPaymentViewDelegate?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(smilesBalance: Double, elWalletBalance: Double, smilesRedeem: Double, elWalletRedeem: Double, smilesPoint: Int, paymentTypes: SecondaryPaymentViewType, selectedPrimaryMethod: PaymentOption) {
        self.setUpPaymentViewHidden(type: paymentTypes)
        self.elWalletView.configure(type: .elWallet(balancd: elWalletBalance, redeem: elWalletRedeem), balance: elWalletBalance, redeem: elWalletRedeem, smilesPoints: 0, selectedPrimaryPaymentMethod: selectedPrimaryMethod)
        self.smilesView.configure(type: .smile(balancd: smilesBalance, redeem: smilesRedeem), balance: smilesBalance, redeem: smilesRedeem, smilesPoints: smilesPoint, selectedPrimaryPaymentMethod: selectedPrimaryMethod)
        
        self.elWalletView.switchStateChange = { [weak self] (type, state) in
            self?.delegate?.switchStateChange(type: type, switchState: state)
        }
        self.smilesView.switchStateChange = {[weak self] (type, state) in
            self?.delegate?.switchStateChange(type: type, switchState: state)
        }
    }
    
    func setUpPaymentViewHidden(type: SecondaryPaymentViewType) {
        if type == .smiles {
            self.elWalletView.isHidden = true
            self.smilesView.isHidden = false
        }else if type == .elWallet {
            self.elWalletView.isHidden = false
            self.smilesView.isHidden = true
        }else if type == .both{
            self.elWalletView.isHidden = false
            self.smilesView.isHidden = false
        }else {
            self.elWalletView.isHidden = true
            self.smilesView.isHidden = true
        }
    }
    private func addViews() {
        self.addSubview(viewBG)
//        viewBG.addSubview(lblTitle)
        viewBG.addSubview(stackView)
        self.stackView.addArrangedSubview(lblTitle)
        self.stackView.addArrangedSubview(elWalletView)
        self.stackView.addArrangedSubview(smilesView)
        
//        self.heightAnchor.constraint(equalToConstant: CGFloat(2 * 72) + 46).isActive = true
        self.lblTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        self.viewBG.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        self.viewBG.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        self.viewBG.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.viewBG.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        
        self.lblTitle.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor, constant: 16).isActive = true
        self.lblTitle.topAnchor.constraint(equalTo: viewBG.topAnchor, constant: 16).isActive = true
                
        self.stackView.leftAnchor.constraint(equalTo: viewBG.leftAnchor).isActive = true
        self.stackView.rightAnchor.constraint(equalTo: viewBG.rightAnchor).isActive = true
//        self.stackView.topAnchor.constraint(equalTo: lblTitle.bottomAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: viewBG.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: viewBG.bottomAnchor).isActive = true
        
    }
}


enum SourceType {
    case elWallet(balancd: Double, redeem: Double)
    case smile(balancd: Double, redeem: Double)
    
    var balance: Double {
        switch self {
            case .elWallet(let value, _)    :  return value
            case .smile(let value, _)       :  return value
        }
    }
    
    var redeem: Double {
        switch self {
            case .elWallet(_ , let redeem)  : return redeem
            case .smile(_ , let redeem)     : return redeem
        }
    }
    
    var errorMsg: String {
        switch self {
          case .elWallet( _, _):  return localizedString("secondry_payment_error_msg_elwallet", comment: "")
          case .smile( _, _):    return localizedString("secondry_payment_error_msg_smiles", comment: "")
        }
      }
}

extension SourceType {
    var logo: UIImage? {
        switch self {
            case .elWallet  : return UIImage(name: "elWallet")
            case .smile     : return UIImage(name: "smileLogo")
        }
    }
    
    var text: String? {
        switch self {
            case .elWallet  : return localizedString("use_elwallet_text", comment: "")
            case .smile     : return localizedString("use_smile_text", comment: "")
        }
    }
}

class PaymentSourceView: UIView {
    private lazy var viewBG: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var logo: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private lazy var lblAvailableBalanceText: UILabel = {
        let label = UILabel()

        label.setCaptionOneRegDarkStyle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private lazy var lblAvailableBalance: UILabel = {
        let label = UILabel()
        
        label.setCaptionOneRegDarkStyle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lblSmilesPoints: UILabel = {
        let label = UILabel()
        
        label.setCaptionOneRegDarkStyle()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var availableBalanceStack: UIStackView = {
       let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var lblUseSourceText: UILabel = {
        let label = UILabel()
        
        label.setCaptionOneRegDarkStyle()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var lblUseBalance: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .right
        label.setBody3SemiBoldDarkStyle()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var useBalanceSwitch: UISwitch = {
        let mSwitch = UISwitch()
        
        mSwitch.addTarget(self, action: #selector(switchChanged(_ :)), for: UIControl.Event.valueChanged)

        mSwitch.translatesAutoresizingMaskIntoConstraints = false
        mSwitch.onTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        return mSwitch
    }()
    
    private lazy var errorMsg: UILabel = {
        let label = UILabel()
        
        label.isHidden = true
        label.text = localizedString("secondry_payment_error_msg", comment: "")
        label.setCaptionOneRegErrorStyle()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var switchStateChange: ((SourceType, Bool)->())?

    private var type: SourceType?
    private var balance: Double?
    private var selectedPrimaryPaymentMethod: PaymentOption = .none
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        
        
        self.backgroundColor = .clear
        self.addViews()
        self.setupConstraints()
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.useBalanceSwitch.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configure(type: SourceType, balance: Double, redeem: Double, smilesPoints: Int, selectedPrimaryPaymentMethod: PaymentOption) {
        self.type = type
        self.balance = balance
        self.selectedPrimaryPaymentMethod = selectedPrimaryPaymentMethod
        
        self.logo.image = type.logo
        self.lblUseSourceText.text = type.text
        self.lblAvailableBalanceText.text = localizedString("shopping_basket_available_label", comment: "").capitalized
        self.lblAvailableBalance.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: balance)//CurrencyManager.getCurrentCurrency() + " " + (balance == "" ? "0.00" : balance)
        lblUseBalance.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: redeem)//CurrencyManager.getCurrentCurrency() + " " + (redeem == "" ? "0.00" : redeem)
        self.errorMsg.text = type.errorMsg
        
        
        switch type {
        case .elWallet(_):
            self.lblSmilesPoints.isHidden = true
            self.lblSmilesPoints.text = ""
            break
                
        case .smile(_):
            self.lblSmilesPoints.isHidden = smilesPoints == 0 ? true : false
            self.lblSmilesPoints.text = "(\(smilesPoints) \(localizedString("smile_point_unit", comment: "")))"
            break
        }
        
        if redeem > 0 {
            useBalanceSwitch.isOn = true
        }else {
            useBalanceSwitch.isOn = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        guard let type = self.type else { return }
        
        if self.selectedPrimaryPaymentMethod == .none {
            self.useBalanceSwitch.isOn = false
            
            if let switchStateChange = self.switchStateChange {
                switchStateChange(type, false)
            }
            return
        }
        
        if (Double(type.balance) == nil || (Double(type.balance) ?? 0) < 1) && (Double(type.redeem) == nil || (Double(type.redeem) ?? 0) < 1) {
            self.useBalanceSwitch.isOn = false
            self.errorMsg.isHidden = false
            switch type {
            case .elWallet(let balancd, let redeem):
                MixpanelEventLogger.trackCheckoutElwalletSwitchError(error: localizedString("secondry_payment_error_msg", comment: ""))
            case .smile(let balancd, let redeem):
                MixpanelEventLogger.trackCheckoutSmilesSwitchError(error: localizedString("secondry_payment_error_msg", comment: ""))
            }
            return
        } else {
            self.errorMsg.isHidden = true
        }
        
        if let closure = self.switchStateChange {
            closure(type, sender.isOn)
        }
    }
    
    private func addViews() {
        self.addSubview(viewBG)
        
        viewBG.addSubview(logo)
        
        viewBG.addSubview(availableBalanceStack)
        availableBalanceStack.addArrangedSubview(lblAvailableBalanceText)
        availableBalanceStack.addArrangedSubview(lblAvailableBalance)
        availableBalanceStack.addArrangedSubview(lblSmilesPoints)
        viewBG.addSubview(stackView)
        viewBG.addSubview(useBalanceSwitch)
        viewBG.addSubview(errorMsg)
        
        stackView.addArrangedSubview(lblUseSourceText)
        stackView.addArrangedSubview(lblUseBalance)
    }
    
    private func setupConstraints() {
//        self.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        viewBG.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        viewBG.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 12).isActive = true
        viewBG.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        viewBG.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        logo.topAnchor.constraint(equalTo: viewBG.topAnchor, constant: 8).isActive = true
        logo.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor, constant: 0).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 36).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 36).isActive = true

        availableBalanceStack.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 8).isActive = true
        availableBalanceStack.topAnchor.constraint(equalTo: logo.topAnchor).isActive = true
        
        stackView.trailingAnchor.constraint(equalTo: useBalanceSwitch.leadingAnchor, constant: -8).isActive = true
        stackView.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        
        useBalanceSwitch.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor, constant: -16).isActive = true
        useBalanceSwitch.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        
        errorMsg.leadingAnchor.constraint(equalTo: viewBG.leadingAnchor, constant: 16).isActive = true
        errorMsg.trailingAnchor.constraint(equalTo: viewBG.trailingAnchor, constant: -16).isActive = true
        errorMsg.topAnchor.constraint(equalTo: availableBalanceStack.bottomAnchor, constant: 8).isActive = true
        errorMsg.bottomAnchor.constraint(equalTo: viewBG.bottomAnchor, constant: -16).isActive = true
    }
}
