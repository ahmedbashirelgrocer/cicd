//
//  RequestsViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 11/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var requestDescriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var requestTextField: UITextField!
    @IBOutlet weak var tagsView: ASJTagsView!
    @IBOutlet weak var requestButton: UIButton!
    
    //MARK: Variables
    var isNavigateToRequest = false
    var requestButtonView: RequestButtonView!
    var productsRequestArray:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if isNavigateToRequest == true {
            addBackButton()
            self.title = NSLocalizedString("requests_title", comment: "")
        }else{
           self.navigationController!.navigationBar.topItem!.title = NSLocalizedString("requests_title", comment: "")
        }
        
        self.requestButtonView = RequestButtonView.getRequestButtonView()
        self.requestButtonView.delegate = self
        
        self.setTagsViewAppearance()
        self.setRequestLabelsAppearance()
        self.setUpRequestButtonAppearance()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        
        self.setRequestTextFieldAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard(){
        self.requestTextField.resignFirstResponder()
    }
    
    // MARK: Appearance
    
    fileprivate func setRequestTextFieldAppearance() {
        
        self.requestTextField.becomeFirstResponder()
        
        self.requestTextField.placeholder = NSLocalizedString("type_your_products_placeholder", comment: "")
        
        self.requestTextField.layer.cornerRadius = 5.0
        self.requestTextField.layer.masksToBounds = true
        self.requestTextField.layer.borderColor = UIColor( red: 216/255, green: 216/255, blue:216/255, alpha: 1.0 ).cgColor
        self.requestTextField.layer.borderWidth = 1.0
        
        self.requestTextField.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        
        self.requestTextField.leftViewMode = UITextField.ViewMode.always
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.requestTextField.frame.height))
        paddingView.backgroundColor = UIColor.clear
        self.requestTextField.leftView = paddingView
        
        self.requestTextField.inputAccessoryView = self.requestButtonView
        self.refreshButtons()
    }
    
    fileprivate func setRequestLabelsAppearance() {
        
        self.requestTitleLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.requestTitleLabel.textColor = UIColor.black
        self.requestTitleLabel.text = NSLocalizedString("not_finding_your_favorite_products_title", comment: "")
        
        self.requestDescriptionLabel.font = UIFont.SFProDisplaySemiBoldFont(11.0)
        self.requestDescriptionLabel.textColor = UIColor.lightTextGrayColor()
        self.requestDescriptionLabel.text = NSLocalizedString("not_finding_your_favorite_products_description", comment: "")
    }
    
    fileprivate func setUpRequestButtonAppearance(){
        
        self.requestButton.setTitle(NSLocalizedString("request_button_title", comment: ""), for: UIControl.State())
        self.requestButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
        self.refreshButtons()
    }
    
    fileprivate func setTagsViewAppearance() {
        
        self.tagsView.tagColor = UIColor( red: 66/255, green: 157/255, blue:57/255, alpha: 1.0)
        self.tagsView.tagFont = UIFont.SFProDisplayBoldFont(14.0)
        self.tagsView.tagTextColor = UIColor.white
        self.tagsView.crossImage = UIImage(name:"icCloseWhite")
        
        self.handleTagBlocks()
    }
    
    fileprivate func handleTagBlocks(){
        
        self.tagsView.deleteBlock = {(tagText:String, idx:Int) -> Void in
            self.tagsView.deleteTag(at: idx)
            self.productsRequestArray.remove(at: idx)
            self.refreshButtons()
        }
        
        self.tagsView.tapBlock = {(tagText:String, idx:Int) -> Void in
            print("Tapped Tag:%@",tagText)
        }
    }
    
    func clearTags() {
        DispatchQueue.main.async { 
            self.tagsView.deleteAllTags()
            self.productsRequestArray.removeAll()
            self.refreshButtons()
        }
    }
    
    fileprivate func refreshButtons(){
        
        if self.productsRequestArray.count > 0 {
            self.setButtonsEnabled(true)
        }else{
           self.setButtonsEnabled(false)
        }
    }
    
    fileprivate func setButtonsEnabled(_ enabled:Bool) {
        
        self.requestButtonView.requestButton.isEnabled = enabled
        self.requestButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.requestButtonView.requestButton.alpha = enabled ? 1 : 0.3
            self.requestButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    // MARK: Buttons Handler
    
    @IBAction func clearAllHandler(_ sender: AnyObject) {
        self.clearTags()
    }
    
    @IBAction func requestHandler(_ sender: AnyObject) {
        self.sendProductRequest()
    }
    
    // MARK: API Calling
    
    fileprivate func sendProductRequest(){
        
        self.setButtonsEnabled(false)
        self.requestTextField.resignFirstResponder()
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.sendProductRequestToServer(self.productsRequestArray, completionHandler: { (result)
            -> Void in
            
            SpinnerView.hideSpinnerView()
            
            switch result {
            case .success(_):
                print("Request Product Successfully")
                self.showRequestSuccessAlert()
                
            case .failure(let error):
                error.showErrorAlert()
                self.setButtonsEnabled(true)
            }
        })
    }
    
    // MARK: Data
    
    fileprivate func showRequestSuccessAlert(){
        
        self.clearTags()
        
        ElGrocerAlertView.createAlert(NSLocalizedString("request_alert_title", comment: ""),
                                      description: NSLocalizedString("request_alert_description", comment: ""),
                                      positiveButton: NSLocalizedString("ok_button_title", comment: ""),
                                      negativeButton: nil,
                                      buttonClickCallback:nil).show()
    
    }
}

// MARK: UITextFieldDelegate Extension

extension RequestsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == false){
            self.tagsView.addTag(textField.text!)
            self.productsRequestArray.append(textField.text!)
            self.refreshButtons()
            textField.text = ""
        }else{
          textField.resignFirstResponder()
        }
        
        return true
    }
}


// MARK: RequestButtonViewProtocol

extension RequestsViewController: RequestButtonViewProtocol {
    
    func requestButtonHandler(){
        self.sendProductRequest()
    }
}
