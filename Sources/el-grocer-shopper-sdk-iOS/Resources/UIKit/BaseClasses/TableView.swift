//
//  TableView.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

public class TableView: UITableView {

    init () {
        super.init(frame: CGRect(), style: .plain)
        makeUI()
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    private func makeUI() {
        rowHeight = UITableView.automaticDimension
        backgroundColor = .clear
        keyboardDismissMode = .onDrag
        cellLayoutMarginsFollowReadableWidth = false
        translatesAutoresizingMaskIntoConstraints = false
        estimatedRowHeight = 50
        sectionHeaderHeight = 0
        sectionFooterHeight = 0
        contentInset = UIEdgeInsets.zero
        separatorStyle = .none
    }
}
