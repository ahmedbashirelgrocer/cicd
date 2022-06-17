//
//  SlideMenuViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class SlideMenuViewController : UIViewController, MenuTableProtocol {
    
    //controllers
    var contentController: UINavigationController!
    var menuController: UIViewController!
    
    //pan gesture
    var panGesture:UIPanGestureRecognizer!
    var menuPanGestureEnabled:Bool!
    var menuPanOffset: CGFloat!
    
    //var tapGesture:UITapGestureRecognizer!

    //state
    var isMenuShown:Bool = false
    var isMenuAnimating:Bool = false
    
    //params
    var menuControllerWidth: CGFloat! {
        
        didSet {
            
            var frame = self.menuController.view.frame
            frame.size = CGSize(width: menuControllerWidth , height: self.view.frame.size.height)
            self.menuController.view.frame = frame;
        }
    }
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init(menuController: UIViewController, contentController: UINavigationController) {
        super.init(nibName: nil, bundle: Bundle.resource);
        
        self.menuController = menuController
        self.contentController = contentController
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(SlideMenuViewController.handlePanGesture(_:)))
        self.panGesture.cancelsTouchesInView = false
        
        self.menuPanGestureEnabled = true
        
       /* self.tapGesture  = UITapGestureRecognizer(target: self,action:#selector(SlideMenuViewController.handleTapGesture(_:)))
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.cancelsTouchesInView = false*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationControllerAsChild()
    }
    
    // MARK: SetUp
    
    func addNavigationControllerAsChild() {
        
        self.contentController.view.frame = self.view.bounds
        self.contentController.slideMenuViewController = self
        
        self.addChild(self.contentController)
        self.view.insertSubview(self.contentController.view, at: 0)
        self.contentController.didMove(toParent: self)
        
        self.contentController.view.addGestureRecognizer(self.panGesture)
        
       // self.contentController.view.addGestureRecognizer(self.tapGesture)
    }
    
    func addHiddenMenuToView() {
        
        self.menuController.view.center = CGPoint(x: self.view.frame.size.width + self.menuController.view.frame.size.width / 2, y: self.menuController.view.center.y);
        
        self.addChild(self.menuController)
        self.view.addSubview(self.menuController.view)
    }
    
    // MARK: PanGesture
    
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
        self.hideMenu()
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
            
        case .began:
            
            let location = recognizer.location(in: self.view)
            
            if (!self.isMenuShown && location.x > self.view.frame.size.width - self.menuPanOffset) {
                
                self.addHiddenMenuToView()
                self.isMenuAnimating = true
                
            } else if(self.isMenuShown) {
                
                self.isMenuAnimating = true;
            }
            
        case .changed:
            
            if (self.isMenuAnimating && !self.isMenuShown) {
                
                let translation = recognizer.translation(in: self.view)
                self.slideMenuWithTranslation(translation)
                
            } else if (self.isMenuAnimating) {
                
                var translation = recognizer.translation(in: self.view)
                translation = CGPoint(x: translation.x - self.menuController.view.frame.size.width, y: translation.y);
                self.slideMenuWithTranslation(translation)
            }
            
        case .ended:
            
            if (self.isMenuAnimating) {
                
                if (self.menuController.view.frame.origin.x >= self.view.frame.size.width - self.menuControllerWidth/2) {
                    
                    self.hideMenuFromCurrentState()
                    
                } else {
                    
                    self.showMenuFromCurrentState()
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: Menu actions
    
    func showSlidingMenu() {
        
        if (self.isMenuShown && !self.isMenuAnimating) {
            
            hideMenu()
            
        } else if (!self.isMenuAnimating) {
            
            showMenu()
        }
    }
    
    func showMenu() {
        
        self.menuController.view.center = CGPoint(x: self.view.frame.size.width + self.menuController.view.frame.size.width / 2, y: self.menuController.view.center.y)
        self.addChild(self.menuController)
        self.view.addSubview(self.menuController.view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.isMenuAnimating = true
            self.contentController.view.center = CGPoint(x: self.contentController.view.frame.size.width/2 - self.menuController.view.frame.size.width, y: self.menuController.view.center.y)
            self.menuController.view.center = CGPoint(x: self.view.frame.size.width - self.menuController.view.frame.size.width / 2, y: self.menuController.view.center.y);
            
        }, completion: { (completion:Bool) -> Void in
                
            self.menuController.didMove(toParent: self)
            self.isMenuAnimating = false
            self.isMenuShown = true
                
            if let activeView = self.contentController.viewControllers.last!.view {
                activeView.isUserInteractionEnabled = false
            }
        }) 
    }
    
    func hideMenu() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.isMenuAnimating = true
            self.contentController.view.center = CGPoint(x: self.contentController.view.frame.size.width / 2, y: self.menuController.view.center.y)
            self.menuController.view.center = CGPoint(x: self.view.frame.size.width + self.menuController.view.frame.size.width / 2, y: self.menuController.view.center.y)
            
        }, completion: { (completion:Bool) -> Void in
                
            self.menuController.willMove(toParent: nil)
            self.menuController.view.removeFromSuperview()
            self.menuController.removeFromParent()
                
            self.isMenuAnimating = false
            self.isMenuShown = false
                
            if let activeView = self.contentController.viewControllers.last!.view {
                activeView.isUserInteractionEnabled = true
            }
        }) 
    }
    
    func slideMenuWithTranslation(_ translation:CGPoint) {
        
        var newMenuCenter = self.view.frame.size.width + translation.x + self.menuController.view.frame.size.width / 2.0
        var newContentCenter = self.contentController.view.frame.size.width/2 + translation.x
        let menuMiddleShown = self.view.frame.size.width - self.menuController.view.frame.size.width / 2
        let menuMiddleHidden = self.view.frame.size.width + self.menuController.view.frame.size.width / 2
        
        if (newMenuCenter <= menuMiddleShown) {
            
            newMenuCenter = menuMiddleShown
            newContentCenter = self.contentController.view.frame.size.width / 2 - self.menuController.view.frame.size.width
            
        } else if(newMenuCenter >= menuMiddleHidden) {
            
            newMenuCenter = menuMiddleHidden
            newContentCenter = self.contentController.view.frame.size.width / 2
        }
        
        self.contentController.view.center = CGPoint(x: newContentCenter, y: self.menuController.view.center.y)
        self.menuController.view.center = CGPoint(x: newMenuCenter, y: self.menuController.view.center.y);
    }
    
    func showMenuFromCurrentState() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.isMenuAnimating = true
            self.contentController.view.center = CGPoint(x: self.contentController.view.frame.size.width/2 - self.menuController.view.frame.size.width, y: self.menuController.view.center.y)
            self.menuController.view.center = CGPoint(x: self.view.frame.size.width - self.menuController.view.frame.size.width / 2, y: self.menuController.view.center.y)
            
        }, completion: { (completion:Bool) -> Void in
                
            self.menuController.didMove(toParent: self)
            self.isMenuAnimating = false
            self.isMenuShown = true
                
            if let activeView = self.contentController.viewControllers.last!.view {
                activeView.isUserInteractionEnabled = false
            }
        }) 
    }
    
    func hideMenuFromCurrentState() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.isMenuAnimating = true
            self.contentController.view.center = CGPoint(x: self.contentController.view.frame.size.width / 2, y: self.menuController.view.center.y)
            self.menuController.view.center = CGPoint(x: self.view.frame.size.width + self.menuController.view.frame.size.width / 2, y: self.menuController.view.center.y)
            
        }, completion: { (completion:Bool) -> Void in
                
            self.menuController.willMove(toParent: nil)
            self.menuController.view.removeFromSuperview()
            self.menuController.removeFromParent()
                
            self.isMenuAnimating = false
            self.isMenuShown = false
                
            if let activeView = self.contentController.viewControllers.last!.view {
                activeView.isUserInteractionEnabled = true
            }
        }) 
    }
    
    // MARK: MenuTableProtocol
    
    func menuTableViewDidSelectViewController(_ selectedViewController: UIViewController) {
        
        let currentController: UIViewController = self.contentController.viewControllers[0] 
        if (currentController != selectedViewController || self.contentController.viewControllers.count > 1) {
            
            if let activeView = self.contentController.viewControllers.last!.view {
                activeView.isUserInteractionEnabled = true
            }
            
            self.contentController.viewControllers = [selectedViewController]
        }
        
        self.hideMenu()
    }
    
    func hideSideMeun(){
        self.hideMenu()
    }
}
