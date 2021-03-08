//
//  Types.swift
//
//
//  Created by 叶永平 on 2021/3/8.
//

import Foundation

protocol Indexable { 
    associatedtype T: Equatable
    subscript(index: Int) -> T { get set }
}

extension String: Indexable {
    typealias T = Character
    subscript(index: Int) -> Character {
        get {
            let idx = self.index(startIndex, offsetBy: index)
            return self[idx]
        }
        set {
            let start  = self.index(startIndex, offsetBy: index)
            let end = self.index(after: start)
            self.replaceSubrange(start..<end, with: [newValue])
        }
    }
}

public struct V {
    var offset: Int
    var v: Array<Int>
    
    public init(_ maxDapth: Int) {
        self.offset = maxDapth
        self.v = Array(repeating: 0, count: 2 * maxDapth)
    }
    
    public var count: Int {
        return v.count
    }
}

extension V: Indexable {
    subscript(index: Int) -> Int {
        set { v[index] = newValue }
        get { return v[index] }
    }
}

public func maxD(_ length1: Int, _ length2: Int) -> Int {
    (length1 + length2 + 1)/2 + 1
}

extension Range where Bound == Int {
    func split(at index: Int) -> (Range<Bound>, Range<Bound>) {
        assert(index >= startIndex && index <= endIndex )
        let position = startIndex.advanced(by: index)
        return (startIndex..<position, position..<endIndex)
    }
}

func findMiddleSnake<T: Indexable>(
    old: T,
    oldRange: Range<Int>,
    new: T,
    newRange: Range<Int>,
    vf: inout V,
    vb: inout V,
    deadline: TimeInterval?
) -> (Int, Int)? {
    let n = oldRange.count
    let m = newRange.count
    let delta = n - m
    let odd = delta & 1 == 1
    vf[1] = 0
    vb[1] = 0
    let dMax = maxD(n, m)
    for d in 0..<dMax {
        if let deadline = deadline, Date().timeIntervalSince1970 < deadline {
            break
        }
        
        for k in stride(from: d, to: -d, by: -2) {
            var x: Int
            if k == -d || (k != d && vf[k-1] < vf[k+1]){
                x = vf[k+1]
            } else {
                x = vf[k-1] + 1
            }
            let y = x - k
            let (x0, y0) = (x, y)
            if x < oldRange.count && y < newRange.count {
                let advance = commonPrefixCount(
                    old: old,
                    oldRange: oldRange.index(oldRange.startIndex, offsetBy: x)..<oldRange.endIndex,
                    new: new,
                    newRange: newRange.index(newRange.startIndex, offsetBy: y)..<newRange.endIndex
                )
                x += advance
            }
            vf[k] = x;
            
            if odd && abs(k - delta) <= (d-1) {
                if vf[k] + vb[-(k-delta)] >= n {
                    return (x0 + oldRange.startIndex, y0 + newRange.startIndex)
                }
            }
        }
        
        for k in stride(from: d, to: -d, by: -2) {
            var x: Int
            if k == -d || (k != d &&  vb[k-1] < vb[k+1]) {
                x = vb[k+1]
            } else {
                x = vb[k-1] + 1
            }
            var y = x - k
            
            if x < n && y < m {
                let advance = commonSuffixCount(
                    old: old,
                    oldRnage: oldRange.startIndex..<oldRange.startIndex.advanced(by: n-x),
                    new: new,
                    newRange: newRange.startIndex..<newRange.startIndex.advanced(by: m-y)
                )
                x += advance
                y += advance
            }
            vb[k] = x
            
            if !odd && abs(k - delta) <= d {
                if vb[k] + vf[-(k-delta)]  >= n {
                    return (n - x + oldRange.startIndex, m - y + newRange.startIndex)
                }
            }
        }
    }
    return .none
}

//public struct Myers<E: Equatable> {
//    public static func calculateShortestEditDistance(from fromArray: Array<E>, to toArray: Array<E>) -> Array<Int> {
//        let fromCount = fromArray.count
//        let toCount = toArray.count
//        let totalCount = toCount + fromCount
//        var furthestReaching = Array(repeating: 0, count: 2 * totalCount + 1)
//
//        let isReachedAtSink: (Int, Int) -> Bool = { x, y in
//            return x == fromCount && y == toCount
//        }
//
//        let snake: (Int, Int, Int) -> Int = { x, D, k in
//            var _x = x
//            while _x < fromCount && _x - k < toCount && fromArray[_x] == toArray[_x - k] {
//                _x += 1
//            }
//            return _x
//        }
//
//        for D in 0...totalCount {
//            for k in stride(from: -D, through: D, by: 2) {
//                let index = k + totalCount
//            
//                // (x, D, k) => the x position on the k_line where the number of scripts is D
//                // scripts means insertion or deletion
//                var x = 0
//                if D == 0 { }
//                    // k == -D, D will be the boundary k_line
//                    // when k == -D, moving right on the Edit Graph(is delete script) from k - 1_line where D - 1 is unavailable.
//                    // when k == D, moving bottom on the Edit Graph(is insert script) from k + 1_line where D - 1 is unavailable.
//                    // furthestReaching x position has higher calculating priority. (x, D - 1, k - 1), (x, D - 1, k + 1)
//                else if k == -D || k != D && furthestReaching[index - 1] < furthestReaching[index + 1] {
//                    // Getting initial x position
//                    // ,using the furthestReaching X position on the k + 1_line where D - 1
//                    // ,meaning get (x, D, k) by (x, D - 1, k + 1) + moving bottom + snake
//                    // this moving bottom on the edit graph is compatible with insert script
//                    x = furthestReaching[index + 1]
//                } else {
//                    // Getting initial x position
//                    // ,using the futrhest X position on the k - 1_line where D - 1
//                    // ,meaning get (x, D, k) by (x, D - 1, k - 1) + moving right + snake
//                    // this moving right on the edit graph is compatible with delete script
//                    x = furthestReaching[index - 1] + 1
//                }
//                
//                // snake
//                // diagonal moving can be performed with 0 cost.
//                // `same` script is needed ?
//                let _x = snake(x, D, k)
//                
//                if isReachedAtSink(_x, _x - k) { return furthestReaching }
//                furthestReaching[index] = _x
//            }
//        }
//
//        fatalError("Never comes here")
//    }
//}
