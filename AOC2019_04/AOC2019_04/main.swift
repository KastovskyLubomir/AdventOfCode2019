//
//  main.swift
//  AOC2019_04
//
//  Created by Lubomír Kaštovský on 07/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

let minValue = [2,0,6,9,3,8] // 206938
let maxValue = [6,7,9,1,2,8] // 679128
let maxValInt = 679128

func findInitialValue(value: [Int]) -> [Int] {
    var result = [Int].init(repeating: 0, count: value.count)
    result[0] = value[0]
    for i in 1..<value.count {
        if value[i] >= result[i-1] {
            result[i] = value[i]
        } else {
            for j in i..<value.count {
                result[j] = result[i-1]
            }
            return result
        }
    }
    return result
}

func sameOrHigher(value: Int) -> [Int] {
    var result: [Int] = []
    for i in value..<10 {
        result.append(i)
    }
    return result
}

func increment(value: inout [Int]) {
    let last = value.count - 1
    for i in 0...last {
        if value[last - i] < 9 {
            value[last - i] += 1
            if (last - i) < last {
                for j in (last - i)..<last {
                    value[j+1] = value[j]
                }
            }
            return
        }
    }
}

func isLower(value: [Int], max: Int) -> Bool {
    var val = 0
    for i in 0..<value.count {
        val = val*10
        val += value[i]
    }
    return val < max
}

func hasTwoAdjacentSame(value: [Int]) -> Bool {
    for i in 0..<value.count - 1 {
        if value[i] == value[i+1] {
            return true
        }
    }
    return false
}

func hasExactlyTwoAdjacentSame(value: [Int]) -> Bool {
    var cmp = value[0]
    var i = 1
    var len = 0
    while i < value.count {
        if cmp == value[i] {
            len += 1
        } else {
            if len == 1 {
                //print(value)
                return true
            }
            len = 0
        }
        cmp = value[i]
        i += 1
        if i == value.count && len == 1 {
            //print(value)
            return true
        }
    }
    //print("xx ", value)
    return false
}

func generatedCodesNum(startValue: [Int]) -> Int {
    var count = 0
    var generated = findInitialValue(value: startValue)
    while isLower(value: generated, max: maxValInt) {
        if hasTwoAdjacentSame(value: generated) {
            //print(generated)
            count += 1
        }
        increment(value: &generated)
    }

    return count
}

func generatedCodesNum2(startValue: [Int]) -> Int {
    var count = 0
    var countAllGenerated = 0
    var generated = findInitialValue(value: startValue)
    while isLower(value: generated, max: maxValInt) {
        countAllGenerated += 1
        if hasExactlyTwoAdjacentSame(value: generated) {
            //print(generated)
            count += 1
        }
        increment(value: &generated)
    }
    print(countAllGenerated)
    return count
}

let initValue = findInitialValue(value: minValue)
print("1. ", generatedCodesNum(startValue: initValue))
print("2. ", generatedCodesNum2(startValue: initValue))
