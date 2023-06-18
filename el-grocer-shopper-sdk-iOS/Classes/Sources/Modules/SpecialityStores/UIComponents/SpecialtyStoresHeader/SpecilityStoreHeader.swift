//
//  SpecilityStoreHeader.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 20/10/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

//extension SpecilityStoreHeader {
//    func refreshWith(dataA: [String]) {
//        self.segmentView.refreshWith(dataA: dataA)
//    }
//    var segmentDelegate: AWSegmentViewProtocol? {
//        set { segmentView.segmentDelegate = newValue }
//        get { segmentView.segmentDelegate }
//    }
//}

class SpecilityStoreHeader: UIView {
    
    lazy var searchBarHeader : GenericHyperMarketHeader = {
        let searchHeader = GenericHyperMarketHeader.loadFromNib()!
        searchHeader.translatesAutoresizingMaskIntoConstraints = false
        searchHeader.headerType = .specialityStore
        searchHeader.backgroundColor = .textfieldBackgroundColor()
        return searchHeader
    }()
    
    lazy var segmentView: AWSegmentView = {
        let view = AWSegmentView.initSegmentView(.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .textfieldBackgroundColor()
        return view
    }()
    
//    var searchBarHeaderTopAnchor: NSLayoutConstraint!
//    private var oldOffsety: CGFloat = 0
//    private var newOffsety: CGFloat = 0 { didSet { oldOffsety = oldValue } }
//    private var travaled: CGFloat = 0
//    func viewDidScroll(_ scrollView: UIScrollView) {
//        let height: CGFloat = 75 + 45
//
//        newOffsety = scrollView.contentOffset.y
//
//        let diff = newOffsety - oldOffsety
//        let diffTravaled = travaled - diff
//
//        if diff < 0 {
//            travaled = min(height, diffTravaled)
//        } else {
//            travaled = max(0, diffTravaled)
//        }
//
//        scrollView.layoutIfNeeded()
//
//        var headerFrame = self.frame
//        headerFrame.origin.y += newOffsety - min(height - travaled, newOffsety)
//        searchBarHeaderTopAnchor.constant = min(height - travaled, newOffsety)
//
//        self.frame = headerFrame
//    }
    
    func initialization(){
        setupView()
        setupSubviews()
        setupLayoutConstraints()
    }
    
    func setupView() {
        // translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    func setupSubviews() {
        addSubview(searchBarHeader)
        addSubview(segmentView)
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            searchBarHeader.leftAnchor.constraint(equalTo: leftAnchor),
            searchBarHeader.rightAnchor.constraint(equalTo: rightAnchor),
            searchBarHeader.topAnchor.constraint(equalTo: topAnchor)
            //searchBarHeader.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            segmentView.topAnchor.constraint(equalTo: searchBarHeader.bottomAnchor),
            segmentView.leftAnchor.constraint(equalTo: leftAnchor),
            segmentView.rightAnchor.constraint(equalTo: rightAnchor),
            segmentView.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        // segmentViewBottomAnchor = segmentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        // searchBarHeaderTopAnchor =  searchBarHeader.topAnchor.constraint(equalTo: topAnchor)
        // searchBarHeaderTopAnchor.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialization()
    }
    
}
