//
//  DeleteCardConfirmationBottomSheet.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class DeleteCardConfirmationBottomSheet: UIViewController {
    
    typealias selectionClosure = (_ shouldRemove : Bool) -> Void
    var selectedClosure: selectionClosure? = nil

    @IBOutlet var bGView: UIView! {
        didSet {
            bGView.backgroundColor = .navigationBarWhiteColor()
            bGView.roundTopWithTopShadow(radius: 8)
        }
    }
    @IBOutlet var lblTitle: UILabel! {
        didSet {
            lblTitle.text = NSLocalizedString("txt_do_you_want_remove_card", comment: "")
            lblTitle.setH4SemiBoldStyle()
        }
    }
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var btnRemove: AWButton! {
        didSet {
            btnRemove.cornarRadius = 28
            btnRemove.backgroundColor = .navigationBarColor()
            btnRemove.setH4SemiBoldWhiteStyle()
            btnRemove.setTitle(NSLocalizedString("btn_remove_title", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var btnKeepUsing: AWButton! {
        didSet {
            btnKeepUsing.cornarRadius = 28
            btnKeepUsing.backgroundColor = .navigationBarWhiteColor()
            btnKeepUsing.borderWidth = 2.0
            btnKeepUsing.borderColor = .navigationBarColor()
            btnKeepUsing.setH4SemiBoldGreenStyle()
            btnKeepUsing.setTitle(NSLocalizedString("btn_keep_using", comment: ""), for: UIControl.State())
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnCrossHandler(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func btnRemoveHandler(_ sender: Any) {
        if let selectedClosure = selectedClosure {
            selectedClosure(true)
        }
        self.dismiss(animated: true)
    }
    @IBAction func btnKeepUsingHandler(_ sender: Any) {
        if let selectedClosure = selectedClosure {
            selectedClosure(false)
        }
        self.dismiss(animated: true)
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
