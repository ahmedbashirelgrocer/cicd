//
//  SmilesLoginVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 03/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
// import KAPinField
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift

class SmilesLoginVC: UIViewController, NavigationBarProtocol {
    
    let numberOfPassChar = 5
    var currentOtp : String = ""
    var smilePoints: Int = 0
    var smileUserDetails: SmileUser?
    var moveBackAfterlogin: Bool = true
    
    lazy var btnBack: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(name: "BackWhite"), for: .normal)
        button.addTarget(self, action: #selector(backButtonClickedHandler), for: .touchUpInside)
        return button
    }()
    
    lazy var backgroundGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.5254901961, green: 0.2666666667, blue: 0.6117647059, alpha: 1).cgColor, #colorLiteral(red: 0.3019607843, green: 0.3254901961, blue: 0.662745098, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(name: "smiles_logo_white")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        return label
    }()
    
    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        return label
    }()
    
    private lazy var pinField: CodeVerificationTextField = {
        let textField = CodeVerificationTextField(cellSpacing: 10)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.numberOfTextFields = numberOfPassChar
        textField.backgroundColor = #colorLiteral(red: 0.9559774995, green: 0.9609488845, blue: 0.9608611465, alpha: 0.98)
        textField.becomeFirstResponder()
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = #colorLiteral(red: 0.9482966065, green: 0.7244116664, blue: 0.2139227092, alpha: 1)
        return label
    }()
    
    private lazy var resendOTPLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setBody2RegSecondaryBlackStyle()
        label.textColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        return label
    }()
    
    private lazy var resendOtpButton: UIButton = {
        let titleResend: NSAttributedString = {
            var attributes: [NSAttributedString.Key : Any] = [:]
            attributes[.font] = UIFont.SFProDisplayNormalFont(16)
            attributes[.foregroundColor] = #colorLiteral(red: 0.9559774995, green: 0.9609488845, blue: 0.9608611465, alpha: 1)
            attributes[.underlineStyle] = 1
            let string = localizedString("resend_otp", comment: "")
            return NSAttributedString(string: string, attributes: attributes)
        }()
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(resendOtpBtnTapped), for: .touchUpInside)
        button.setAttributedTitle(titleResend, for: .normal)
        return button
    }()
    
    private lazy var btnBottom: UIButton = {
        let button = UIButton()
        let title = localizedString("lbl_ReturnHome", comment: "")
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBody3BoldGreenStyle()
        let textColor: UIColor = #colorLiteral(red: 0.9559774995, green: 0.9609488845, blue: 0.9608611465, alpha: 1)
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = textColor.cgColor
        button.isHidden = true
        button.addTarget(self, action: #selector(backButtonClickedHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var spacers: [UIView] = [makeSpacer(), makeSpacer(), makeSpacer(), makeSpacer()]
    private var disposeBag = DisposeBag()
    
    private var isResendButtonHidden = false
    private let ACCOUNT_BLOCKED_ERROR_CODE = 4203
    private let OTP_ATTEMP_ERROR_CODE = 4201
    private let SMILES_DOWN_ERROR_CODE = 4261
    private let viewModel = SmilesLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setInitialAppearence()
        bindData()
        generateSmilesOtp()
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        for i in 0..<spacers.count {
            view.addSubview(spacers[i])
        }
        view.addSubview(logoView)
        view.addSubview(titleLabel)
        view.addSubview(detailsLabel)
        view.addSubview(pinField)
        view.addSubview(errorLabel)
        view.addSubview(resendOTPLabel)
        view.addSubview(resendOtpButton)
        view.addSubview(btnBottom)
        view.addSubview(btnBack)
    }
    
    func setupLayouts() {
        NSLayoutConstraint.activate([
            btnBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            btnBack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            btnBack.heightAnchor.constraint(equalToConstant: 40),
            btnBack.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            spacers[0].topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            spacers[0].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[0].rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: spacers[0].bottomAnchor),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            logoView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
        ])
        
        NSLayoutConstraint.activate([
            spacers[1].topAnchor.constraint(equalTo: logoView.bottomAnchor),
            spacers[1].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[1].rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: spacers[1].bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            detailsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            detailsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            pinField.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 16),
            pinField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            pinField.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: pinField.bottomAnchor, constant: 16),
            errorLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            errorLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            resendOTPLabel.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            resendOTPLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            resendOTPLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            resendOtpButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            resendOtpButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            resendOtpButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            spacers[2].topAnchor.constraint(equalTo: resendOtpButton.bottomAnchor, constant: 5),
            spacers[2].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[2].rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            btnBottom.topAnchor.constraint(equalTo: spacers[2].bottomAnchor),
            btnBottom.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            btnBottom.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            btnBottom.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            spacers[3].topAnchor.constraint(equalTo: btnBottom.bottomAnchor),
            spacers[3].leftAnchor.constraint(equalTo: view.leftAnchor),
            spacers[3].rightAnchor.constraint(equalTo: view.rightAnchor),
            spacers[3].bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            spacers[1].heightAnchor.constraint(equalTo: spacers[0].heightAnchor, multiplier: 0.8),
            spacers[2].heightAnchor.constraint(equalTo: spacers[0].heightAnchor, multiplier: 4),
            spacers[3].heightAnchor.constraint(equalTo: spacers[0].heightAnchor, multiplier: 2)
        ])
    }

    private func makeSpacer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
    
// @IBOutlet weak var nextButton: AWButton! {
// didSet {
// nextButton.setTitle(localizedString("intro_next_button", comment: ""), for: UIControl.State())
// }
// }
// @IBOutlet weak var privacyPolicyLabel: UILabel!
    
    func generateSmilesOtp() {
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        viewModel.generateSmilesOtp() { [weak self] code, message in
            guard let self = self else { return }
            SpinnerView.hideSpinnerView()
            
            if code != nil {
                self.handlerError(code: code, message: message)
                return
            }
            
            self.viewModel.startTimer()
        }
    }
    
    private func bindData() {
        
        viewModel.userOtp.bind { [weak self] userOtp in
            self?.currentOtp = userOtp
            print("currentOtp",userOtp)
        }
        
        viewModel.smilePoints.bind { [weak self] points in
            self?.smilePoints = Int(points ?? 0)
        }
        
        viewModel.user.bind {[weak self] userData in
            self?.smileUserDetails = userData
        }
        
        viewModel.timeLeft.bind { [weak self] timeleft in
            guard let self = self else { return }
            
            let formattedTimeLeft = self.getFormattedTimeLeft(seconds: timeleft)
            
            let resendTxt = localizedString("resend_otp_in", comment: "") + " \(formattedTimeLeft)"
            self.resendOTPLabel.text = timeleft <= 0 ? "" : resendTxt
        }
        
        viewModel.isTimerRunning.bind { [weak self] isRunning in
            guard let self = self else { return }
            
            self.resendOTPLabel.isHidden = !isRunning
            self.resendOtpButton.isHidden = isRunning || self.isResendButtonHidden
        }
        
        viewModel.showAlertClosure = { errMessage in
            ElGrocerAlertView.createAlert( localizedString("no_groceries_title", comment: ""),
                                           description: errMessage ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
        }
        
        pinField.rx.text
            .distinctUntilChanged()
            .do( onNext: { [weak self] _ in self?.errorLabel.text = "" })
            .filter{ $0 != nil }
            .filter{ [weak self] text in text!.count == self?.numberOfPassChar }
            .subscribe(onNext: { [weak self] text in
                self?.pinField.resignFirstResponder()
                self?.pinField(didFinishWith: text ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        let text = localizedString("smile_otp_instructions", comment: "")
        if let userProfile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            self.detailsLabel.text = String(format: text, "\(userProfile.phone ?? "+971*********")")
        }else {
            self.detailsLabel.text = String(format: text, "+971*********")
        }
        self.title = localizedString("txt_smile_point", comment: "")
        self.titleLabel.text = localizedString("smile_login", comment: "")
       
        
        // self.setPolicyLabel()
        // nextButton.isUserInteractionEnabled = false
        
        setupPinField()
    }
    
    override func backButtonClick() {
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func backButtonClickedHandler() {
        backButtonClick()
    }
    
    func setupNavigationAppearence() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = localizedString("txt_smile_point", comment: "")
        
        resendOTPLabel.isHidden = true
        // resendOtpButton.setTitle(localizedString("resend_otp", comment: ""), for: UIControl.State())
    }

    func setupPinField() {
        
        // pinField.properties.delegate = self
        pinField.becomeFirstResponder()
        // pinField.properties.animateFocus = true // Animate the currently focused token
    }

    @objc func resendOtpBtnTapped() {
        print("resendOtpBtnTapped tapped")
        //viewModel.retryOtp()
        pinField.isUserInteractionEnabled = true
        errorLabel.text = ""
        generateSmilesOtp()
    }
    
    @IBAction func nextBtnTapped(_ sender: AWButton) {
        print("next tapped")
//            viewModel.otpAuthenticate {
//                //check this
//                self.showSmilePoints()
//                //if let userData = self.smileUserDetails {
//                //}
//            }
        self.showSmilePoints()
    }
    
    fileprivate func showSmilePoints() {
        
        let smileVC = ElGrocerViewControllers.getSmilePointsVC()
        //smileVC.smilePoints = self.smilePoints
        smileVC.shouldDismiss = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        //self.navigationController?.present(navigationController, animated: true, completion: { });
        self.navigationController?.pushViewController(smileVC, animated: true)
    }
    
    func getFormattedTimeLeft(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = String(format: "%02d", seconds % 60)
        return "\(minutes):\(remainingSeconds)"
    }
}

extension SmilesLoginVC { //: KAPinFieldDelegate {
    func pinField(didFinishWith code: String) {
        print("didFinishWith : \(code)")
        
        let stringNumber : String  = code
        let englishNumber = self.convertToEnglish(stringNumber)
        //self.codeVerifcation(code: englishNumber , token: self.token)
        self.codeVerifcation(code: englishNumber)

    }
    
    private func codeVerifcation(code: String) {

        let _ = SpinnerView.showSpinnerViewInView(self.view)
        self.viewModel.smilesLoginWithOtp(code: code) { isSuccess, errMessage, errCode in
            SpinnerView.hideSpinnerView()
            if isSuccess {
                if self.moveBackAfterlogin {
                    self.backButtonClick()
                }
            } else {
                
                self.pinField.isError = true
                self.handlerError(code: errCode, message: errMessage)
            }
        }
    }
    
    func convertToEnglish(_ str : String) ->  String {
        let stringNumber : String  = str
        var finalString = ""
        for c in stringNumber {
            let Formatter = NumberFormatter()
            Formatter.locale = NSLocale(localeIdentifier: "EN") as Locale?
            if let final = Formatter.number(from: "\(c)") {
                finalString = finalString + final.stringValue
            }
        }
        return finalString
    }
    
    private func handlerError(code: Int?, message: String?) {
        switch code {
            
        case ACCOUNT_BLOCKED_ERROR_CODE:
            self.btnBottom.isHidden = false
            self.errorLabel.text = message
            self.pinField.isUserInteractionEnabled = false
            self.isResendButtonHidden = true
            
            self.viewModel.isTimerRunning.value = false
            self.viewModel.timeLeft.value = 0
            self.viewModel.countDownTimer?.invalidate()
            
        case OTP_ATTEMP_ERROR_CODE:
            self.errorLabel.text = message
            
        case SMILES_DOWN_ERROR_CODE:
            let smilesErrorVC = SmilesErrorVC()
            smilesErrorVC.errorMessage = message
            
            self.navigationController?.pushViewController(smilesErrorVC, animated: true)
            
        default:
            ElGrocerUtility.sharedInstance.showTopMessageView(message ?? "", image: nil, -1, false, backButtonClicked: { _, _, _ in
                //
            })
        }
    }
    
}
