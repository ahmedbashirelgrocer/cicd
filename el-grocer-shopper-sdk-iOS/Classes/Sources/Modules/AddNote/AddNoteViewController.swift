//
//  AddNoteViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 03/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

protocol AddNoteViewControllerDelegate: class {
    
    func addNoteViewControllerDidTouchOverlay(_ controller: AddNoteViewController)
    func addNoteViewController(_ controller: AddNoteViewController, finishedAddingNoteWithText text: String)
    
}

class AddNoteViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addNoteLabel: UILabel!
    
    // MARK: Properties
    
    weak var delegate: AddNoteViewControllerDelegate?
    var note: String = ""
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setInitialControllerAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noteTextView.text = note
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.noteTextView.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    @IBAction func overlayTouched(_ sender: UITapGestureRecognizer) {
        
        noteTextView.resignFirstResponder()
        self.delegate?.addNoteViewControllerDidTouchOverlay(self)
        
    }
    
    @IBAction func doneButtonTouched(_ sender: UIButton) {
        
        let noteText = noteTextView.text ?? ""
        noteTextView.resignFirstResponder()
        self.delegate?.addNoteViewController(self, finishedAddingNoteWithText: noteText)
        
    }
    
    // MARK: Appearance
    
    func setInitialControllerAppearance() {
        self.styleButtons()
        self.styleViews()
    }
    
    func styleButtons() {
        doneButton.setTitle(localizedString("delivery_note_done_button_title", comment: ""), for: UIControl.State())
        doneButton.layer.cornerRadius = 5
        doneButton.clipsToBounds = true
    }
    
    func styleViews() {
        addNoteLabel.text = localizedString("order_add_edit_note_button_title", comment: "")
        noteView.layer.cornerRadius = 5
    }
}

extension AddNoteViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let maxCommentLength = 140
        
        if textView == noteTextView {
            return textView.text.count + (text.count - range.length) <= maxCommentLength
        }
        return true
    }
}
