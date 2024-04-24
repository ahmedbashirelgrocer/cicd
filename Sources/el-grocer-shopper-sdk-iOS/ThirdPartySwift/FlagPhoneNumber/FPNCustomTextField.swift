//
//  FPNCustomTextField.swift
//  FlagPhoneNumber
//
//  Created by Sarmad Abbas on 28/09/2022.
//



import UIKit
import ThirdPartyObjC //imported to use libPhoneNumber which is added locally for SPM
@available(iOS 9.0, *)
open class FPNCustomTextField: UITextField, FPNCountryPickerDelegate, FPNDelegate {
    
    private let LEFT_VIEW_SPACE: CGFloat = 10
    
    public weak var customDelegate : FPNCustomTextFieldCustomDelegate?

    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            backgroundLayer.cornerRadius = cornerRadius
            leftWrapperView.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable public var borderColor: CGColor? {
        didSet {
            backgroundLayer.borderColor = borderColor
            leftWrapperView.layer.borderColor = borderColor
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            backgroundLayer.borderWidth = borderWidth
            leftWrapperView.layer.borderWidth = borderWidth
        }
    }
    
    
    public let flagButton: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let phoneCodeTextField: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let arrowDownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "01_MyBasket_SelectPayment_DownArrow", in: Bundle.FlagIcons, compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let leftWrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var leftViewHeightAnker = leftWrapperView.heightAnchor.constraint(equalToConstant: 0)
    
    private let backgroundLayer: CALayer = {
        let layer = CALayer.init()
        layer.cornerRadius = 8
        return layer
    }()
    
    private lazy var countryPicker: FPNCountryPicker = FPNCountryPicker()
    private lazy var phoneUtil: NBPhoneNumberUtil = NBPhoneNumberUtil()
    private var nbPhoneNumber: NBPhoneNumber?
    private var formatter: NBAsYouTypeFormatter?
    
    open override var backgroundColor: UIColor? {
        set {
            self.backgroundLayer.backgroundColor = newValue?.cgColor
            self.leftWrapperView.backgroundColor = newValue
        }
        get {
            return UIColor(cgColor: self.backgroundLayer.backgroundColor ?? UIColor.clear.cgColor)
        }
    }
    
    open override var font: UIFont? {
        didSet {
            phoneCodeTextField.font = font
        }
    }
    open override var textColor: UIColor? {
        didSet {
            phoneCodeTextField.textColor = textColor
        }
    }
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return CGRect(x: rect.origin.x + LEFT_VIEW_SPACE + 12,
                      y: rect.origin.y,
                      width: rect.size.width - (LEFT_VIEW_SPACE + 12 + 5),
                      height: rect.size.height)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return CGRect(x: rect.origin.x + LEFT_VIEW_SPACE + 12,
                      y: rect.origin.y,
                      width: rect.size.width - (LEFT_VIEW_SPACE + 12 + 5),
                      height: rect.size.height)
    }
    /// Present in the placeholder an example of a phone number according to the selected country code.
    /// If false, you can set your own placeholder. Set to true by default.
    @objc public var hasPhoneNumberExample: Bool = true {
        didSet {
            if hasPhoneNumberExample == false {
                placeholder = nil
            }
            updatePlaceholder()
        }
    }
    open var selectedCountry: FPNCountry? {
        didSet {
            updateUI()
        }
    }
    /// If set, a search button appears in the picker inputAccessoryView to present a country search view controller
    @IBOutlet public var parentViewController: UIViewController?
    /// Input Accessory View for the texfield
    @objc public var textFieldInputAccessoryView: UIView?
    init() {
        super.init(frame: .zero)
        setup()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    deinit {
        parentViewController = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.cornerRadius = self.cornerRadius
        leftWrapperView.layer.cornerRadius = self.cornerRadius
        
        leftViewHeightAnker.constant = frame.size.height
        backgroundLayer.frame = backgroundLayerFrame()
        
        func backgroundLayerFrame() -> CGRect {
            let x = leftWrapperView.frame.size.width + LEFT_VIEW_SPACE
            let y: CGFloat = 0
            let width = frame.size.width - x
            let height = frame.size.height
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
    }
    
    private func setup() {
        setupLeftView()
        setupCountryPicker()
        super.backgroundColor = .clear
        layer.insertSublayer(backgroundLayer, at: 0)
        keyboardType = .phonePad
        autocorrectionType = .no
        addTarget(self, action: #selector(didEditText), for: .editingChanged)
        addTarget(self, action: #selector(displayNumberKeyBoard), for: .touchDown)
    }

    private func setupLeftView() {
        leftWrapperView.addSubview(flagButton)
        leftWrapperView.addSubview(phoneCodeTextField)
        leftWrapperView.addSubview(arrowDownImageView)
        
        leftView = leftWrapperView
        leftViewMode = .always

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(displayCountryKeyboard))
        tapGesture.numberOfTapsRequired = 1
        leftWrapperView.addGestureRecognizer(tapGesture)
        
        setupLayoutConstraints()
        
        func setupLayoutConstraints() {
            
            leftViewHeightAnker.isActive = true
            
            NSLayoutConstraint.activate([
                flagButton.centerYAnchor.constraint(equalTo: leftWrapperView.centerYAnchor),
                flagButton.leftAnchor.constraint(equalTo: leftWrapperView.leftAnchor, constant: 14),
                flagButton.heightAnchor.constraint(equalTo: leftWrapperView.heightAnchor, multiplier: 0.5)
            ])
            
            NSLayoutConstraint.activate([
                phoneCodeTextField.leftAnchor.constraint(equalTo: flagButton.rightAnchor, constant: 5),
                phoneCodeTextField.topAnchor.constraint(equalTo: leftWrapperView.topAnchor),
                phoneCodeTextField.bottomAnchor.constraint(equalTo: leftWrapperView.bottomAnchor)
            ])
            
            NSLayoutConstraint.activate([
                arrowDownImageView.centerYAnchor.constraint(equalTo: leftWrapperView.centerYAnchor),
                arrowDownImageView.leftAnchor.constraint(equalTo: phoneCodeTextField.rightAnchor, constant: 5),
                arrowDownImageView.rightAnchor.constraint(equalTo: leftWrapperView.rightAnchor, constant: -12),
                arrowDownImageView.heightAnchor.constraint(equalTo: leftWrapperView.heightAnchor, multiplier: 0.5)
            ])
        }
    }

    private func setupCountryPicker() {
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        countryPicker.backgroundColor = .white
        if let regionCode = Locale.current.regionCode, let countryCode = FPNCountryCode(rawValue: regionCode) {
            countryPicker.setCountry(countryCode)
        } else if let firstCountry = countryPicker.countries.first {
            countryPicker.setCountry(firstCountry.code)
        }
    }
    @objc private func displayNumberKeyBoard() {
        inputView = .none
        inputAccessoryView = textFieldInputAccessoryView
        tintColor = .gray
        reloadInputViews()
        becomeFirstResponder()
    }
    @objc private func displayCountryKeyboard() {
        inputView = countryPicker
        inputAccessoryView = getToolBar(with: getCountryListBarButtonItems())
        tintColor = .clear
        reloadInputViews()
        becomeFirstResponder()
    }
    @objc private func displayAlphabeticKeyBoard() {
        showSearchController()
    }
    @objc private func resetKeyBoard() {
        inputView = nil
        inputAccessoryView = nil
        resignFirstResponder()
    }
    // - Public
    /// Set the country image according to country code. Example "FR"
    public func setFlag(for countryCode: FPNCountryCode) {
        countryPicker.setCountry(countryCode)
    }
    /// Get the current formatted phone number
    public func getFormattedPhoneNumber(format: FPNFormat) -> String? {
        return try? phoneUtil.format(nbPhoneNumber, numberFormat: convert(format: format))
    }
    /// For Objective-C, Get the current formatted phone number
    @objc public func getFormattedPhoneNumber(format: Int) -> String? {
        if let formatCase = FPNFormat(rawValue: format) {
            return try? phoneUtil.format(nbPhoneNumber, numberFormat: convert(format: formatCase))
        }
        return nil
    }
        /// Get the current raw phone number
    @objc public func getRawPhoneNumber() -> String? {
        let phoneNumber = getFormattedPhoneNumber(format: .E164)
        var nationalNumber: NSString?
        phoneUtil.extractCountryCode(phoneNumber, nationalNumber: &nationalNumber)
        return nationalNumber as String?
    }
    /// Set directly the phone number. e.g "+33612345678"
    @objc public func set(phoneNumber: String) {
        let cleanedPhoneNumber: String = clean(string: phoneNumber)
        if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
            if validPhoneNumber.italianLeadingZero {
                text = "0\(validPhoneNumber.nationalNumber.stringValue)"
            } else {
                text = validPhoneNumber.nationalNumber.stringValue
            }
            setFlag(for: FPNCountryCode(rawValue: phoneUtil.getRegionCode(for: validPhoneNumber))!)
        }
    }
    /// Set the country list excluding the provided countries
    public func setCountries(excluding countries: [FPNCountryCode]) {
        countryPicker.setup(without: countries)
    }
    /// Set the country list including the provided countries
    public func setCountries(including countries: [FPNCountryCode]) {
        countryPicker.setup(with: countries)
    }
    /// Set the country image according to country code. Example "FR"
    @objc public func setFlag(for key: FPNOBJCCountryKey) {
        if let code = FPNOBJCCountryCode[key], let countryCode = FPNCountryCode(rawValue: code) {
            countryPicker.setCountry(countryCode)
        }
    }
    /// Set the country list excluding the provided countries
    @objc public func setCountries(excluding countries: [Int]) {
        let countryCodes: [FPNCountryCode] = countries.compactMap({ index in
            if let key = FPNOBJCCountryKey(rawValue: index), let code = FPNOBJCCountryCode[key], let countryCode = FPNCountryCode(rawValue: code) {
                return countryCode
            }
            return nil
        })
        countryPicker.setup(without: countryCodes)
    }
    /// Set the country list including the provided countries
    @objc public func setCountries(including countries: [Int]) {
        let countryCodes: [FPNCountryCode] = countries.compactMap({ index in
            if let key = FPNOBJCCountryKey(rawValue: index), let code = FPNOBJCCountryCode[key], let countryCode = FPNCountryCode(rawValue: code) {
                return countryCode
            }
            return nil
        })
        countryPicker.setup(with: countryCodes)
    }
    // Private
    @objc public func didEditText() {
        if let phoneCode = selectedCountry?.phoneCode, let number = text {
            var cleanedPhoneNumber = clean(string: "\(phoneCode) \(number)")
            if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
                nbPhoneNumber = validPhoneNumber
                cleanedPhoneNumber = "+\(validPhoneNumber.countryCode.stringValue)\(validPhoneNumber.nationalNumber.stringValue)"
                if let inputString = formatter?.inputString(cleanedPhoneNumber) {
                    text = remove(dialCode: phoneCode, in: inputString)
                }
                (delegate as? FPNCustomTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: true)
                (customDelegate as? FPNCustomTextFieldCustomDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: true)
                
            } else {
                nbPhoneNumber = nil
                if let dialCode = selectedCountry?.phoneCode {
                    if let inputString = formatter?.inputString(cleanedPhoneNumber) {
                        text = remove(dialCode: dialCode, in: inputString)
                    }
                }
                (delegate as? FPNCustomTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: false)
                (customDelegate as? FPNCustomTextFieldCustomDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: false)
            }
        }
    }
    private func convert(format: FPNFormat) -> NBEPhoneNumberFormat {
        switch format {
        case .E164:
            return NBEPhoneNumberFormat.E164
        case .International:
            return NBEPhoneNumberFormat.INTERNATIONAL
        case .National:
            return NBEPhoneNumberFormat.NATIONAL
        case .RFC3966:
            return NBEPhoneNumberFormat.RFC3966
        }
    }
    private func updateUI() {
        if let countryCode = selectedCountry?.code {
            formatter = NBAsYouTypeFormatter(regionCode: countryCode.rawValue)
        }
        flagButton.image = selectedCountry?.flag
        if let phoneCode = selectedCountry?.phoneCode {
            phoneCodeTextField.text = phoneCode
            phoneCodeTextField.sizeToFit()
            layoutSubviews()
        }
        if hasPhoneNumberExample == true {
            updatePlaceholder()
        }
        didEditText()
    }
    private func clean(string: String) -> String {
        var allowedCharactersSet = CharacterSet.decimalDigits
        allowedCharactersSet.insert("+")
        return string.components(separatedBy: allowedCharactersSet.inverted).joined(separator: "")
    }
    private func getValidNumber(phoneNumber: String) -> NBPhoneNumber? {
        guard let countryCode = selectedCountry?.code else { return nil }
        do {
            let parsedPhoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneNumber, defaultRegion: countryCode.rawValue)
            let isValid = phoneUtil.isValidNumber(parsedPhoneNumber)
            return isValid ? parsedPhoneNumber : nil
        } catch _ {
            return nil
        }
    }
    private func remove(dialCode: String, in phoneNumber: String) -> String {
        return phoneNumber.replacingOccurrences(of: "\(dialCode) ", with: "").replacingOccurrences(of: "\(dialCode)", with: "")
    }
    public func showSearchController() {
        if let countries = countryPicker.countries {
            let searchCountryViewController = FPNSearchCountryViewController(countries: countries)
            let navigationViewController = UINavigationController(rootViewController: searchCountryViewController)
            searchCountryViewController.delegate = self
            navigationViewController.modalPresentationStyle = .fullScreen
            parentViewController?.present(navigationViewController, animated: true, completion: nil)
        }
    }
    private func getToolBar(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.tintColor = #colorLiteral(red: 0.01960784314, green: 0.737254902, blue: 0.4, alpha: 1)
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()
        return toolbar
    }
    private func getCountryListBarButtonItems() -> [UIBarButtonItem] {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resetKeyBoard))
        doneButton.accessibilityLabel = "doneButton"
        if parentViewController != nil {
            let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(displayAlphabeticKeyBoard))
            searchButton.accessibilityLabel = "searchButton"
            return [searchButton, space, doneButton]
        }
        return [space, doneButton]
    }
    private func updatePlaceholder() {
        if let countryCode = selectedCountry?.code {
            do {
                let example = try phoneUtil.getExampleNumber(countryCode.rawValue)
                let phoneNumber = "+\(example.countryCode.stringValue)\(example.nationalNumber.stringValue)"
                if let inputString = formatter?.inputString(phoneNumber) {
                    placeholder = remove(dialCode: "+\(example.countryCode.stringValue)", in: inputString)
                } else {
                    placeholder = nil
                }
            } catch _ {
                placeholder = nil
            }
        } else {
            placeholder = nil
        }
    }
    // - FPNCountryPickerDelegate
    func countryPhoneCodePicker(_ picker: FPNCountryPicker, didSelectCountry country: FPNCountry) {
        
        (delegate as? FPNCustomTextFieldDelegate)?.fpnDidSelectCountry(name: country.name, dialCode: country.phoneCode, code: country.code.rawValue)
        selectedCountry = country
    }
    // - FPNDelegate
    internal func fpnDidSelect(country: FPNCountry) {
        setFlag(for: country.code)
        DispatchQueue.main.async { [unowned self] in
            self.displayNumberKeyBoard()
            (self.customDelegate as? FPNCustomTextFieldCustomDelegate)?.fpnDidSelectCountry(name: country.name, dialCode: country.phoneCode, code: country.code.rawValue)
        }
    }
}
