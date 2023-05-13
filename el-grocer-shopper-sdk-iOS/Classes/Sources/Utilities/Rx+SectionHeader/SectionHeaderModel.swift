//
//  SectionHeaderModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 13/05/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

public struct SectionHeaderModel<Section, Header, ItemType> {
    public var header: Header
    public var model: Section
    public var items: [Item]
    
    public init(model: Section, header: Header , items: [Item]) {
        self.header = header
        self.model = model
        self.items = items
    }
}

extension SectionHeaderModel
: SectionModelType {
    
    public typealias Identity = Section
    public typealias Item = ItemType
    public typealias header = Header
    
    public var identity: Section {
        return model
    }
}

extension SectionHeaderModel
    : CustomStringConvertible {

    public var description: String {
        return "\(self.model) > \(self.header) > \(items)"
    }
}

extension SectionHeaderModel {
    
    public init(original: SectionHeaderModel<Section, Header, ItemType>, items: [ItemType]) {
        self.model = original.model
        self.header = original.header
        self.items = items
    }
  
}

extension SectionHeaderModel
: Equatable where Section: Equatable, ItemType: Equatable, header: Equatable {
    
    public static func == (lhs: SectionHeaderModel, rhs: SectionHeaderModel) -> Bool {
        return lhs.model == rhs.model
        && lhs.items == rhs.items && lhs.header == rhs.header
    }
}
