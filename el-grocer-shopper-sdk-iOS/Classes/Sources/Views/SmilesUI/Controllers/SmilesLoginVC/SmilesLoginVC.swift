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
        gradient.colors = [#colorLiteral(red: 0.875736475, green: 0.2409847379, blue: 0.1460545063, alpha: 1).cgColor, #colorLiteral(red: 0.5716853142, green: 0.3168505132, blue: 0.5579631925, alpha: 1).cgColor]
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
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        return label
    }()
    
    private lazy var resendOtpButton: UIButton = {
        let titleResend: NSAttributedString = {
            var attributes: [NSAttributedString.Key : Any] = [:]
            attributes[.font] = UIFont.systemFont(ofSize: 16, weight: .semibold)
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
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        let textColor: UIColor = #colorLiteral(red: 0.9559774995, green: 0.9609488845, blue: 0.9608611465, alpha: 1)
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = textColor.cgColor
        button.isHidden = true
        button.addTarget(self, action: #selector(backButtonClickedHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var spacers: [UIView] = [makeSpacer(), makeSpacer(), makeSpacer(), makeSpacer()]
    private var disposeBag = DisposeBag()
    
    private let viewModel = SmilesLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        setInitialAppearence()
        bindData()
        generateSmilesOtp()
        viewModel.startTimer()
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
            resendOTPLabel.topAnchor.constraint(equalTo: errorLabel.bottomAnchor),
            resendOTPLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            resendOTPLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            resendOtpButton.topAnchor.constraint(equalTo: resendOTPLabel.bottomAnchor),
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
        viewModel.generateSmilesOtp() { code, message in
            if code != nil {
                switch code {
                case 4073:
                    self.errorLabel.text = message
                    self.btnBottom.isHidden = false
                default:
                    self.navigationController?.pushViewController(SmilesErrorVC(), animated: true)
                }
            }
            SpinnerView.hideSpinnerView()
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
            
            let resendTxt = localizedString("resend_otp_in", comment: "") + "\(timeleft)" + localizedString("sec", comment: "")
            self?.resendOTPLabel.text = timeleft <= 0 ? "" : resendTxt
        }
        
        viewModel.isTimerRunning.bind { [weak self] isRunning in
            self?.resendOTPLabel.isHidden = !isRunning
            self?.resendOtpButton.isHidden = isRunning
        }
        
        viewModel.showAlertClosure = { errMessage in
            ElGrocerAlertView.createAlert( localizedString("no_groceries_title", comment: ""),
                                           description: errMessage ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
        }
        
        viewModel.isBlockOtp = { [weak self] isBlocked in
            self?.resendOtpButton.isHidden = isBlocked
            self?.resendOTPLabel.text = ""
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
            
            self.detailsLabel.text =  String.localizedStringWithFormat(text, (userProfile.phone ?? "+971*********"))
        }else {
            self.detailsLabel.text =  String.localizedStringWithFormat(text, "+971*********")
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
        viewModel.startTimer()
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
            // self.pinField.isUserInteractionEnabled = false
            if isSuccess {
                // self.nextButton.isUserInteractionEnabled = true
                // self.resendOtpButton.isHidden = true
//                self.pinField.animateSuccess(with: "👍") {
                    if self.moveBackAfterlogin {
                        self.backButtonClick()
                    }
//                }
            } else {
                // self.pinField.isUserInteractionEnabled = true
                // self.resendOtpButton.isHidden = false
                
                self.pinField.isError = true
                switch errCode {
                case 4096, 4092:
                    self.errorLabel.text = errMessage
                case 4073:
                    self.btnBottom.isHidden = false
                    self.errorLabel.text = errMessage
                    self.pinField.isUserInteractionEnabled = false
                default:
                    self.navigationController?.pushViewController(SmilesErrorVC(), animated: true)
                }
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
    
}
// testing something...
