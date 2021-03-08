//
//  Utils.swift
//  
//
//  Created by 叶永平 on 2021/3/8.
//

import Foundation

func commonPrefixCount<T: Indexable>(
    old: T,
    oldRange: Range<Int>,
    new: T,
    newRange: Range<Int>
) -> Int {
    guard !oldRange.isEmpty, !newRange.isEmpty
    else { return 0 }
    return zip(oldRange, newRange)
        .filter{
            return new[$0.0] == old[$0.1]
        }
        .count
}

func commonSuffixCount<T: Indexable>(
    old: T,
    oldRnage: Range<Int>,
    new: T,
    newRange: Range<Int>
) -> Int {
    guard !oldRnage.isEmpty, !newRange.isEmpty
    else { return 0 }
    return zip(oldRnage.reversed(), newRange.reversed())
        .filter{ new[$0.0] == old[$0.1] }
        .count
}
