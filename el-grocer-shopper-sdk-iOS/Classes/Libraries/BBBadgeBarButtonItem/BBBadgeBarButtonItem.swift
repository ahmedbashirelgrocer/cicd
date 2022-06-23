//
//  BBBadgeBarButtonItem.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 22/06/2022.
//

import UIKit

class BBBadgeBarButtonItem: UIBarButtonItem {
    // Each time you change one of the properties, the badge will refresh with your changes
    // Badge value to be display
    // var badgeValue: String!
    // Badge background color
    var badgeBGColor: UIColor?
    // Badge text color
    var badgeTextColor: UIColor?
    // Badge font
    var badgeFont: UIFont?
    // Padding value for the badge
    var badgePadding: CGFloat = 0.0
    // Minimum size badge to small
    var badgeMinSize: CGFloat = 0.0
    // Values for offseting the badge over the BarButtonItem you picked
    var badgeOriginX: CGFloat = 0.0
    var badgeOriginY: CGFloat = 0.0
    // In case of numbers, remove the badge when reaching zero
    var shouldHideBadgeAtZero = false
    // Badge has a bounce animation when value changes
    var shouldAnimateBadge = false
    var badge: UILabel!

    convenience init?(customUIButton customButton: UIButton) {
        self.init(customView: customButton)
        initializer()
    }
    
    func initializer() {
        // Default design initialization
        badgeBGColor = UIColor.red
        badgeTextColor = UIColor.white
        badgeFont = UIFont.systemFont(ofSize: 12.0)
        badgePadding = 6
        badgeMinSize = 8
        badgeOriginX = 7
        badgeOriginY = -9
        shouldHideBadgeAtZero = true
        shouldAnimateBadge = true
        // Avoids badge to be clipped when animating its scale
        customView?.clipsToBounds = false
    }
    
    //MARK: - Utility methods
    
    // Handle badge display when its properties have been changed (color, font, ...)
    func refreshBadge() {
        // Change new attributes
        badge?.textColor = badgeTextColor
        badge?.backgroundColor = badgeBGColor
        badge?.font = badgeFont
    }
    
    // When the value changes the badge could need to get bigger
    // Calculate expected size to fit new value
    // Use an intermediate label to get expected size thanks to sizeToFit
    // We don't call sizeToFit on the true label to avoid bad display
    func updateBadgeFrame() {
        let frameLabel = duplicate(badge)
        frameLabel?.sizeToFit()
        let expectedLabelSize = frameLabel?.frame.size
        var minHeight = expectedLabelSize?.height ?? 0.0
        minHeight = ((minHeight < badgeMinSize) ? badgeMinSize : expectedLabelSize?.height) ?? 0.0
        var minWidth = expectedLabelSize?.width ?? 0.0
        let padding = badgePadding
        minWidth = minWidth < minHeight ? minHeight : (expectedLabelSize?.width ?? 0)
        badge?.frame = CGRect(x: badgeOriginX, y: badgeOriginY, width: minWidth + padding, height: minHeight + padding)
        badge?.layer.cornerRadius = (minHeight + padding) / 2
        badge?.layer.masksToBounds = true
    }
    
    // Handle the badge changing value
    func updateBadgeValue(animated: Bool) {
        if animated && shouldAnimateBadge && (badge?.text != badgeValue) {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = NSNumber(value: 1.5)
            animation.toValue = NSNumber(value: 1)
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, _: 1.3, _: 1, _: 1)
            badge?.layer.add(animation, forKey: "bounceAnimation")
            // Set the new value
            badge?.text = badgeValue
            // Animate the size modification if needed
            updateBadgeFrame()
        }
    }
    
    func duplicate(_ labelToCopy: UILabel?) -> UILabel? {
        let duplicateLabel = UILabel(frame: labelToCopy?.frame ?? CGRect.zero)
        duplicateLabel.text = labelToCopy?.text
        duplicateLabel.font = labelToCopy?.font

        return duplicateLabel
    }
    
    func removeBadge() {
        // Animate badge removal
        UIView.animate(withDuration: 0.2, animations: { [self] in
            badge?.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { [self] finished in
            badge?.removeFromSuperview()
            badge = nil
        }
    }
    
    //MARK: - Setters
    
    var badgeValue: String? {
        get {
            return badgeValue
        }
        set {
            self.badgeValue = newValue
            if newValue == nil || (newValue == "") || ((newValue == "0") && shouldHideBadgeAtZero) {
                removeBadge()
            } else if badge == nil {
                badge = UILabel(frame: CGRect(x: badgeOriginX, y: badgeOriginY, width: 20, height: 20))
                badge?.textColor = badgeTextColor
                badge?.backgroundColor = badgeBGColor
                badge?.font = badgeFont
                badge?.textAlignment = .center
                customView?.addSubview(badge!)
                updateBadgeValue(animated: false)
            } else {
                updateBadgeValue(animated: true)
            }
        }
    }
    
    func setBadgeBGColor(_ badgeBGColor: UIColor?) {
        self.badgeBGColor = badgeBGColor
        if badge != nil { refreshBadge() }
    }
    
    func setBadgeTextColor(_ badgeTextColor: UIColor?) {
        self.badgeTextColor = badgeTextColor
        if badge != nil { refreshBadge() }
    }

    func setBadgeFont(_ badgeFont: UIFont?) {
        self.badgeFont = badgeFont
        if badge != nil { refreshBadge() }
    }
    
    func setBadgePadding(_ badgePadding: CGFloat) {
        self.badgePadding = badgePadding
        if badge != nil { updateBadgeFrame() }
    }

    func setBadgeMinSize(_ badgeMinSize: CGFloat) {
        self.badgeMinSize = badgeMinSize
        if badge != nil { updateBadgeFrame() }
    }
    
    func setBadgeOriginX(_ badgeOriginX: CGFloat) {
        self.badgeOriginX = badgeOriginX
        if badge != nil { updateBadgeFrame() }
    }

    func setBadgeOriginY(_ badgeOriginY: CGFloat) {
        self.badgeOriginY = badgeOriginY
        if badge != nil { updateBadgeFrame() }
    }
}
