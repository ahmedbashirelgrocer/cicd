
//
//  PhoneNumberViewController.swift
//  PhoneNumberPicker
//
//  Created by Hugh Bellamy on 06/09/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

import UIKit

public protocol PhoneNumberViewControllerDelegate {
    func phoneNumberViewController(phoneNumberViewController: PhoneNumberViewController, didEnterPhoneNumber phoneNumber: String)
    func phoneNumberViewControllerDidCancel(phoneNumberViewController: PhoneNumberViewController)
}

public final class PhoneNumberViewController: UIViewController, CountriesViewControllerDelegate {
    public class func standardController() -> PhoneNumberViewController {
        return UIStoryboard(name: "PhoneNumberPicker", bundle: nil).instantiateViewController(withIdentifier: "PhoneNumber") as! PhoneNumberViewController
    }
    
    @IBOutlet weak public var countryButton: UIButton!
    @IBOutlet weak public var countryTextField: UITextField!
    @IBOutlet weak public var phoneNumberTextField: UITextField!
    
    @IBOutlet public var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet public var doneBarButtonItem: UIBarButtonItem!
    
    public var cancelBarButtonItemHidden = false { didSet { setupCancelButton() } }
    public var doneBarButtonItemHidden = false { didSet { setupDoneButton() } }
    
    private func setupCancelButton() {
        if let cancelBarButtonItem = cancelBarButtonItem {
            navigationItem.leftBarButtonItem = cancelBarButtonItemHidden ? nil: cancelBarButtonItem
        }
    }
    
    private func setupDoneButton() {
        if let doneBarButtonItem = doneBarButtonItem {
            navigationItem.rightBarButtonItem = doneBarButtonItemHidden ? nil: doneBarButtonItem
        }
    }
    
    @IBOutlet weak public var backgroundTapGestureRecognizer: UITapGestureRecognizer!
    
    public var delegate: PhoneNumberViewControllerDelegate?
    
    public var phoneNumber: String? {
        if let countryText = countryTextField.text, let phoneNumberText = phoneNumberTextField.text, !countryText.isEmpty && !phoneNumberText.isEmpty {
            return countryText + phoneNumberText
        }
        return nil
    }
    
    public var country = Country.currentCountry
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
       // setupCancelButton()
        setupDoneButton()
        
        updateCountry()
        
        phoneNumberTextField.becomeFirstResponder()
    }
    
    @IBAction private func changeCountry(sender: UIButton) {
        
        phoneNumberTextField.resignFirstResponder()
        
        let countriesViewController = CountriesViewController.standardController()
        countriesViewController.delegate = self
        countriesViewController.cancelBarButtonItemHidden = true

        countriesViewController.selectedCountry = country
        countriesViewController.majorCountryLocaleIdentifiers = ["GB", "US", "IT", "DE", "RU", "BR", "IN"]
        
        navigationController?.pushViewController(countriesViewController, animated: true)
    }
    
    public func countriesViewControllerDidCancel(countriesViewController: CountriesViewController) { }
    
    public func countriesViewController(countriesViewController: CountriesViewController, didSelectCountry country: Country) {
        navigationController?.popViewController(animated: true)
        self.country = country
        updateCountry()
         phoneNumberTextField.becomeFirstResponder()
    }
    
    @IBAction private func textFieldDidChangeText(sender: UITextField) {
        if let countryText = sender.text, sender == countryTextField {
            country = Countries.countryFromPhoneExtension(phoneExtension: countryText)
        }
        updateTitle()
    }
    
    private func updateCountry() {
        countryTextField.text = country.phoneExtension
        updateCountryTextField()
        updateTitle()
    }
    
    private func updateTitle() {
        updateCountryTextField()
        if countryTextField.text == "+" {
            countryButton.setTitle("Select From List", for: [])
        } else {
            countryButton.setTitle(country.name, for: [])
        }
        
        var title = "Your Phone Number"
        if let newTitle = phoneNumber  {
            title = newTitle
        }
        navigationItem.title = title
        
        validate()
    }
    
    private func updateCountryTextField() {
        if countryTextField.text == "+" {
            countryTextField.text = ""
        }
        else if let countryText = countryTextField.text, !countryText.hasPrefix("+") && !countryText.isEmpty {
            countryTextField.text = "+" + countryText
        }
    }
    
    @IBAction private func done(sender: UIBarButtonItem) {
        if !countryIsValid || !phoneNumberIsValid {
            return
        }
        if let phoneNumber = phoneNumber {
            delegate?.phoneNumberViewController(phoneNumberViewController: self, didEnterPhoneNumber: phoneNumber)
        }
    }
    
    @IBAction private func cancel(sender: UIBarButtonItem) {
        delegate?.phoneNumberViewControllerDidCancel(phoneNumberViewController: self)
    }
    
    @IBAction private func tappedBackground(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: Validation
    public var countryIsValid: Bool {
        if let countryCodeLength = countryTextField.text?.length {
            return country != Country.emptyCountry && countryCodeLength > 1 && countryCodeLength < 5
        }
        return false
    }
    
    public var phoneNumberIsValid: Bool {
        if let phoneNumberLength = phoneNumberTextField.text?.length {
            return phoneNumberLength > 5 && phoneNumberLength < 15
        }
        return false
    }
    
    private func validate() {
        let validCountry = countryIsValid
        let validPhoneNumber = phoneNumberIsValid
        
        doneBarButtonItem.isEnabled = validCountry && validPhoneNumber
    }
}

private extension String {
    var length: Int {
        return utf16.count
    }
}
