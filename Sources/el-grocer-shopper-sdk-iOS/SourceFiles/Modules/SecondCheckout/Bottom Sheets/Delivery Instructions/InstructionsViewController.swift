//
//  InstructionsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2023.
//

import UIKit
import GrowingTextView

class InstructionsViewController: UIViewController {
    /// Views
    @IBOutlet weak var tvInstructions: GrowingTextView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    fileprivate let DEFAULT_HEIGHT = 160.0
    fileprivate let DEFAULT_HEIGHT_TEXT_VIEW = 28.0
    var doneButtonTapHandler: ((String?)->())?

    /// Initializations
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "InstructionsViewController", bundle: .resource)
        
        let instructionsString = UserDefaults.getAdditionalInstructionsNote()
        
        if instructionsString == nil || instructionsString == "" {
            self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: DEFAULT_HEIGHT)
        } else {
            // 96 is the horizotal padding around the instructions text field
            //
            let stringHeight = instructionsString?.heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 96, font: UIFont.SFProDisplayNormalFont(14))
            self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: (DEFAULT_HEIGHT - DEFAULT_HEIGHT_TEXT_VIEW) + (stringHeight ?? 0.0))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.setH4SemiBoldStyle()
        lblTitle.text = localizedString("text_delivery_instructions", comment: "")
        tvInstructions.delegate = self
        tvInstructions.text = UserDefaults.getAdditionalInstructionsNote()
        buttonClear.isHidden = UserDefaults.getAdditionalInstructionsNote()?.count == 0
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func clearButtonTap(_ sender: Any) {
        tvInstructions.becomeFirstResponder()
        tvInstructions.text = ""
    }
}

extension InstructionsViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.view.layoutIfNeeded()
        self.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: (DEFAULT_HEIGHT - DEFAULT_HEIGHT_TEXT_VIEW) + height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let currentString = textView.text as! NSString
        let updatedString = currentString.replacingCharacters(in: range, with: text)
        
        buttonClear.isHidden = updatedString.count == 0
        
        return updatedString.count <= 100
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let doneButtonTapHandler = self.doneButtonTapHandler {
            doneButtonTapHandler(self.tvInstructions.text)
            self.dismiss(animated: true)
            
            UserDefaults.setAdditionalInstructionsNote(textView.text ?? "")
        }
    }
}
