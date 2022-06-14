//
//  GTProgressBar.swift
//  Pods
//
//  Created by Grzegorz Tatarzyn on 19/09/2016.

import UIKit

@IBDesignable
open class GTProgressBar: UIView {
    fileprivate let backgroundView = UIView()
    fileprivate let fillView = UIView()
    fileprivate let progressLabel = UILabel()
    fileprivate var _progress: CGFloat = 1
    
    open var font: UIFont = UIFont.systemFont(ofSize: 19) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var progressLabelInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var barMaxHeight: CGFloat? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var barBorderColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var barBackgroundColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var barFillColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var barBorderWidth: CGFloat = 2 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var barFillInset: CGFloat = 2 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var progress: CGFloat {
        get {
            return self._progress
        }
        
        set {
            
            
            self._progress = min(max(newValue,0), 1)
            
            print("Progress:%f",self._progress)
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var labelTextColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var displayLabel: Bool = true {
        didSet {
            self.progressLabel.isHidden = !self.displayLabel
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.masksToBounds = cornerRadius != 0.0
            self.layer.cornerRadius = cornerRadius
            self.setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareSubviews()
    }
    
    fileprivate func prepareSubviews() {
        addSubview(progressLabel)
        addSubview(backgroundView)
        addSubview(fillView)
    }
    
    open override func layoutSubviews() {
        setupProgressLabel()
        setupBackgroundView()
        setupFillView()
    }
    
    fileprivate func setupProgressLabel() {
        progressLabel.text = "\(Int(_progress * 100))%"
        let origin = CGPoint(x: progressLabelInsets.left, y: 0)
        progressLabel.frame = CGRect(origin: origin, size: sizeForLabel())
        progressLabel.font = font
        progressLabel.textAlignment = NSTextAlignment.center
        progressLabel.textColor = labelTextColor
        
        centerVerticallyInView(progressLabel)
    }
    
    fileprivate func setupBackgroundView() {
        let xOffset = backgroundViewXOffset()
        let height = min(barMaxHeight ?? frame.size.height, frame.size.height)
        let size = CGSize(width: frame.size.width - xOffset, height: height)
        let origin = CGPoint(x: xOffset, y: 0)
        
        backgroundView.frame = CGRect(origin: origin, size: size)
        backgroundView.backgroundColor = barBackgroundColor
        backgroundView.layer.borderWidth = barBorderWidth
        backgroundView.layer.borderColor = barBorderColor.cgColor
        backgroundView.layer.cornerRadius = cornerRadiusFor(backgroundView)
        
        if let _ = barMaxHeight {
            centerVerticallyInView(backgroundView)
        }
    }
    
    fileprivate func setupFillView() {
        let offset = barBorderWidth + barFillInset
        let fillFrame = backgroundView.frame.insetBy(dx: offset, dy: offset)
        let fillFrameAdjustedSize = CGSize(width: fillFrame.width * _progress, height: fillFrame.height)
        
        fillView.frame = CGRect(origin: fillFrame.origin, size: fillFrameAdjustedSize)
        fillView.backgroundColor = barFillColor
        fillView.layer.cornerRadius = cornerRadiusFor(fillView)
    }
    
    fileprivate func backgroundViewXOffset() -> CGFloat {
        return displayLabel ? progressLabel.frame.width + progressLabelInsets.left + progressLabelInsets.right : 0.0
    }
    
    fileprivate func cornerRadiusFor(_ view: UIView) -> CGFloat {
        if cornerRadius != 0.0 {
            return cornerRadius
        }
        
        return view.frame.height / 2 * 0.7
    }
    
    fileprivate func sizeForLabel() -> CGSize {
        //let text: NSString = "100%"
        //let textSize = text.size(attributes: [NSFontAttributeName : font])
        
        return CGSize(width: 0, height: 0)
    }
    
    fileprivate func centerVerticallyInView(_ view: UIView) {
        let center = self.convert(self.center, from: self.superview)
        //self.convert(self.center, from: self.superview)
        
        view.center = CGPoint(x: view.center.x, y: center.y)
    }
}
