//
//  Types.swift
//  
//
//  Created by 叶永平 on 2021/3/8.
//

import Foundation

public enum SingleDiffOp {
    case insert(index: Int)
    case delete(index: Int)
}

public enum DiffOp {
    case equal(oldIndex: Int, newIndex: Int, length: Int)
    case delete(oldIndex: Int, newIndex: Int, length: Int)
    case insert(oldIndex: Int, newIndex: Int, length: Int)
    case replace(oldIndex: Int, oldLength: Int, newIndex: Int, newLength: Int)
}

public enum DiffTag {
    case equal, delete, insert, replace
}

typealias DiffTagTuple = (tag: DiffTag, oldRange: Range<Int>, newRange: Range<Int>)

extension DiffOp {
    func asTagTuple() -> DiffTagTuple {
        switch self {
        case .equal(let oldIndex, let newIndex, let length  ):
            return (tag: .equal, oldRange: oldIndex..<oldIndex+length, newRange: newIndex..<newIndex+length)
        case .delete(let oldIndex, let newIndex, let length):
            return (tag: .equal, oldRange: oldIndex..<oldIndex+length, newRange: newIndex..<newIndex+length)
        case .insert(let oldIndex, let newIndex, let length):
            return (tag: .equal, oldRange: oldIndex..<oldIndex+length, newRange: newIndex..<newIndex+length)
        case .replace(let oldIndex, let oldLength, let newIndex, let newLength):
            return (tag: .equal, oldRange: oldIndex..<oldIndex+oldLength, newRange: newIndex..<newIndex+newLength)
        }
    }
    
    public var tag: DiffTag {
        return asTagTuple().tag
    }
    
    public var oldRange: Range<Int> {
        return asTagTuple().oldRange
    }
    
    public var newRange: Range<Int> {
        return asTagTuple().newRange
    }
    
    public func isEmpty() -> Bool {
        let (_, old, new) = asTagTuple()
        return old.isEmpty && new.isEmpty
    }
    
    public mutating func shiftLeft(adjust: Int)  {
        self.adjust(with: (adjust, true), adjustLength: (0, false))
    }
    
    public mutating func shiftRight(adjust: Int) {
        self.adjust(with: (adjust, false), adjustLength: (0, false))
    }
    
    public mutating func growLeft(adjust: Int) {
        self.adjust(with: (adjust, true), adjustLength: (adjust, false))
    }
    
    public mutating func growRight(adjust: Int) {
        self.adjust(with: (0, false), adjustLength: (adjust, false))
    }
    
    public mutating func shrinkLeft(adjust: Int) {
        self.adjust(with: (0, false), adjustLength: (adjust, true))
    }
    
    public mutating func shrinkRight(adjust: Int) {
        self.adjust(with: (adjust, false), adjustLength: (adjust, true))
    }
    
    private mutating func adjust(with adjustOffset: (Int, Bool), adjustLength: (Int, Bool)) {
        func modify(val: inout Int, adjust: (Int, Bool)) {
            if adjust.1 { val -= adjust.0 }
            else { val += adjust.0 }
        }
        
        switch self {
        case .equal(var oldIndex, var newIndex, var length  ):
            modify(val: &oldIndex, adjust: adjustOffset)
            modify(val: &newIndex, adjust: adjustOffset)
            modify(val: &length, adjust: adjustLength)
            self = .equal(oldIndex: oldIndex, newIndex: newIndex, length: length)
        case .delete(var oldIndex, var newIndex, var length):
            modify(val: &oldIndex, adjust: adjustOffset)
            modify(val: &length, adjust: adjustLength)
            modify(val: &newIndex, adjust: adjustOffset)
            self = .delete(oldIndex: oldIndex, newIndex: newIndex, length: length)
        case .insert(var oldIndex, var newIndex, var length):
            modify(val: &oldIndex, adjust: adjustOffset)
            modify(val: &newIndex, adjust: adjustOffset)
            modify(val: &length, adjust: adjustLength)
            self = .insert(oldIndex: oldIndex, newIndex: newIndex, length: length)
        case .replace(var oldIndex, var oldLength, var newIndex, var newLength):
            modify(val: &oldIndex, adjust: adjustOffset)
            modify(val: &oldLength, adjust: adjustLength)
            modify(val: &newIndex, adjust: adjustOffset)
            modify(val: &newLength, adjust: adjustLength)
            self = .replace(oldIndex: oldIndex, oldLength: oldLength, newIndex: newIndex, newLength: newLength)
        }
    }
}
