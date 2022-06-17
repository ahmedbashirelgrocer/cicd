//
//  TimelineTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 26/03/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

let kTimelineCellIdentifier = "TimelineTableViewCell"

open class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak open var titleLabel: UILabel!
    @IBOutlet weak open var descriptionLabel: UILabel!
    @IBOutlet weak open var reviewButton: UIButton!
    
    open var timelinePoint = TimelinePoint() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    open var timeline = Timeline() {
        didSet {
            self.setNeedsDisplay()
        }
    }

    open var bubbleRadius: CGFloat = 2.0 {
        didSet {
            if (bubbleRadius < 0.0) {
                bubbleRadius = 0.0
            } else if (bubbleRadius > 6.0) {
                bubbleRadius = 6.0
            }
            
            self.setNeedsDisplay()
        }
    }
    
    open var bubbleColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(17.0)
        self.descriptionLabel.font = UIFont.SFProDisplayNormalFont(15.0)
        
        self.reviewButton.layer.cornerRadius = 5.0
        self.reviewButton.clipsToBounds = true
        self.reviewButton.setTitle(localizedString("choose_substitutions_title", comment: ""), for: UIControl.State())
        self.reviewButton.setBackgroundColor(UIColor.white, forState: UIControl.State())
        self.reviewButton.setTitleColor(UIColor.navigationBarColor(), for: UIControl.State())
        self.reviewButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(15.0)
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override open func draw(_ rect: CGRect) {
        for layer in self.contentView.layer.sublayers! {
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        titleLabel.sizeToFit()
        descriptionLabel.sizeToFit()
        
       // timelinePoint.position = CGPoint(x: timeline.leftMargin + timeline.width / 2, y: titleLabel.frame.origin.y + titleLabel.intrinsicContentSize.height / 2 - timelinePoint.diameter / 2)

        timelinePoint.position = CGPoint(x: timeline.leftMargin, y: titleLabel.frame.origin.y + titleLabel.intrinsicContentSize.height / 2 - timelinePoint.diameter / 2)
        timeline.start = CGPoint(x: timelinePoint.position.x + timelinePoint.diameter / 2, y: 0)
        timeline.middle = CGPoint(x: timeline.start.x, y: timelinePoint.position.y)
        timeline.end = CGPoint(x: timeline.start.x, y: self.bounds.size.height)
        timeline.draw(view: self.contentView)
        
        timelinePoint.draw(view: self.contentView)
    }
}
