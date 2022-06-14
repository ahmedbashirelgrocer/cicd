//
//  GroceryLoaderViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 22/05/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

protocol GroceryLoaderDelegate: class {
    func refreshCategoryViewWithGrocery(_ currentGrocery:Grocery)
}

class GroceryLoaderViewController: UIViewController {
    
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var progressView: UIView!

    var currentGrocery:Grocery!
    weak var delegate:GroceryLoaderDelegate?

    var homeFeeds:[Home] = [Home]()
    
    var placeholderImage = UIImage(named: "product_placeholder")!
    
    
    private var shapeLayer = CAShapeLayer()
    
    // Use this to set the speed of progressView
    var duration: CGFloat = 2.0
    
    // Pass your color here which will be used as layer color
    var firstColor: UIColor? = UIColor.borderGrayColor()
    var secondColor: UIColor? = UIColor.borderGrayColor()
    var thirdColor: UIColor? = UIColor.borderGrayColor()
    
    
    
    var isLoadData = true
    var isNeedToDissmiss = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = self.currentGrocery.name
        
        self.setProgressViewAppearence()
        self.startAnimating()
        
        if isNeedToDissmiss {
             self.perform(#selector(self.dismissView), with: nil, afterDelay: 2.0)
        }else{
            self.perform(#selector(self.dismissView), with: nil, afterDelay: 0.7)
        }
        
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
       
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
     
    }
    
    // MARK: Custom Loader
    
    private func setProgressViewAppearence(){
    
        self.progressView.layer.cornerRadius = self.logoImgView.frame.size.height/2
        self.progressView.layer.masksToBounds = true
        
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = UIColor.borderGrayColor().cgColor
        self.shapeLayer.strokeStart = 0
        self.shapeLayer.strokeEnd = 1
        self.shapeLayer.lineWidth = 5.0
        
        let center = CGPoint(x: self.progressView.bounds.size.width / 2.0, y: self.progressView.bounds.size.height / 2.0)
        let radius = min(self.progressView.bounds.size.width, self.progressView.bounds.size.height)/2.0 - self.shapeLayer.lineWidth / 2.0
        let bezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        shapeLayer.path = bezierPath.cgPath
        
        shapeLayer.frame = self.progressView.bounds
        self.progressView.layer.addSublayer(shapeLayer)
        self.logoImgView.image = self.placeholderImage
          if self.currentGrocery.smallImageUrl != nil && self.currentGrocery.smallImageUrl?.range(of: "http") != nil {
            
            self.logoImgView.sd_setImage(with: URL(string: self.currentGrocery.smallImageUrl!), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.logoImgView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        self.logoImgView.image = image
                    }, completion: nil)
                }
            })
        }else if self.currentGrocery.imageUrl != nil && self.currentGrocery.imageUrl?.range(of: "http") != nil {
            
            self.logoImgView.sd_setImage(with: URL(string: self.currentGrocery.imageUrl!), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.logoImgView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        self.logoImgView.image = image
                    }, completion: nil)
                }
            })
        }
    }
    
    private func animateStrokeEnd() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = 0
        animation.duration = CFTimeInterval(duration / 2.0)
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return animation
    }
    
    private func animateStrokeStart() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.beginTime = CFTimeInterval(duration / 2.0)
        animation.duration = CFTimeInterval(duration / 2.0)
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return animation
    }
    
    private func animateRotation() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = Float.infinity
        
        return animation
    }
    
    private func animateColors() -> CAKeyframeAnimation {
        
        let colors = configureColors()
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.duration = CFTimeInterval(duration)
        animation.keyTimes = configureKeyTimes(colors: colors)
        animation.values = colors
        animation.repeatCount = Float.infinity
        return animation
    }
    
    private func animateGroup() {
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animateStrokeEnd(), animateStrokeStart(), animateRotation(), animateColors()]
        animationGroup.duration = CFTimeInterval(duration)
        animationGroup.fillMode = CAMediaTimingFillMode.both
        animationGroup.isRemovedOnCompletion = false
        animationGroup.repeatCount = Float.infinity
        shapeLayer.add(animationGroup, forKey: "loading")
    }
    
    private func configureColors() -> [CGColor] {
        var colors = [CGColor]()
        colors.append((firstColor?.cgColor)!)
        if secondColor != nil { colors.append((secondColor?.cgColor)!) }
        if thirdColor != nil { colors.append((thirdColor?.cgColor)!) }
        
        return colors
    }
    
    private func configureKeyTimes(colors: [CGColor]) -> [NSNumber] {
        switch colors.count {
        case 1:
            return [0]
        case 2:
            return [0, 1]
        default:
            return [0, 0.5, 1]
        }
    }
    
    private func startAnimating() {
        animateGroup()
    }
    
    private func stopAnimating() {
        shapeLayer.removeAllAnimations()
    }
    
    @objc func dismissView() {
        
        Thread.OnMainThread {
            self.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            self.delegate?.refreshCategoryViewWithGrocery(self.currentGrocery)
        }

    }
}

extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
