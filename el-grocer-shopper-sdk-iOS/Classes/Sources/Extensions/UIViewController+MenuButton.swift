//
//  UIViewController+MenuButton.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kRedDotImageViewTag = 123

extension UIViewController {
    
    func addRightCrossButton(_ isWhite: Bool = false) {
        
        var image: UIImage! = UIImage(name: "cross")
        if isWhite{
           image = UIImage(name: "crossWhite")
        }
        let menuButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        
        let size = self.navigationController?.navigationBar.frame.size.height
        if let height = size {
            let width = image.size.width + 25
            menuButton.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        menuButton.setImage(image, for: UIControl.State())
        menuButton.setImage(image, for: UIControl.State.highlighted)
        menuButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        menuButton.addTarget(self, action: #selector(UIViewController.rightBackButtonClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    func addMenuButton() {
        
        let image:UIImage! = UIImage(name: "menu")
        let menuButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        
        let size = self.navigationController?.navigationBar.frame.size.height
        if let height = size {
            menuButton.frame = CGRect(x: 0, y: 0, width: image.size.width, height: height)
        }
        
        menuButton.setImage(image, for: UIControl.State())
        menuButton.setImage(image, for: UIControl.State.highlighted)
        menuButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        
        menuButton.addTarget(self, action: #selector(UIViewController.menuButtonClick), for: .touchUpInside)
        
        //red notification dot
        addRedDotToButton(menuButton)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    @objc func menuButtonClick() {
        
        self.view.endEditing(true)
        self.navigationController?.slideMenuViewController!.showSlidingMenu()
    }
    
    @objc func rightBackButtonClicked() {
        
       
    }
    
    // MARK: Red dot
    
    func updateMenuButtonRedDotState(_ notification: Notification?) {
        
        let menuButtonView = self.navigationItem.rightBarButtonItem?.customView as? UIButton
        if let menuButton = menuButtonView {
            
            let dotShouldBeHidden = !UserDefaults.isHelpShiftChatResponseUnread()
            
            for subview in menuButton.subviews {
                
                if subview.tag == kRedDotImageViewTag {
                    
                    subview.isHidden = dotShouldBeHidden
                    break
                }
            }
        }
    }
    
    fileprivate func addRedDotToButton(_ button:UIButton) {
        
        let dotImage = UIImage(name: "red_dot")
        let dotImageView = UIImageView(image: dotImage)
        dotImageView.translatesAutoresizingMaskIntoConstraints = false
        dotImageView.tag = kRedDotImageViewTag
        button.addSubview(dotImageView)
        //layout
        let views:[String : AnyObject] = ["redDot" : dotImageView]
        button.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-4)-[redDot]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views))
        button.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(12)-[redDot]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views))
    }
    
}
extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */

    @discardableResult func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
extension UITableView {
    
    func hasRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func reloadDataOnMain() {
         Thread.OnMainThread {
            self.reloadData()
        }
    }
    
    
    
}

extension UIImageView{
    func changePngColorTo(color: UIColor){
        guard let image =  self.image else {return}
        self.image = image.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

extension UIViewController {
    
    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var isDarkMode : Bool {
        if #available(iOS 12.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        } else {
            return false
            // Fallback on earlier versions
        }
    }
    
    
    func getAppDelegate () -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    
}

//class AppDelegate: UIResponder, UIApplicationDelegate {
//    static var shared = AppDelegate()
//}
