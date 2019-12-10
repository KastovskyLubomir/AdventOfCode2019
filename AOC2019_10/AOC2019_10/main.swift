//
//  main.swift
//  AOC2019_10
//
//  Created by Lubomír Kaštovský on 10/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

struct Point {
    var isAsteroid: Bool
    var x: Double
    var y: Double
}

let input = readLinesRemoveEmpty(str: inputString)

func createMap(input: [String]) -> [[Point]] {
    var result: [[Point]] = []
    var y = 0
    for line in input {
        var x = 0
        var row: [Point] = []
        for c in line {
            if c == Character(".") {
                row.append(Point(isAsteroid: false, x: Double(x), y: Double(y)))
            } else {
                row.append(Point(isAsteroid: true, x: Double(x), y: Double(y)))
            }
            x += 1
        }
        result.append(row)
        y += 1
    }
    return result
}

func linePoint(a: Double, b: Double, t: Double) -> Double {
    return a + (b * t)
}

// start is the asteroid from which I look
// end is where I look
func pointsInLine(map: [[Point]], start: Point, end: Point) -> [Point] {
    var resultPoints: [Point] = []

    // create line equation
    let vectorx = end.x - start.x
    let vectory = end.y - start.y

    let x = linePoint(a: start.x, b: vectorx, t: )
    let y = linePoint(a: start.y, b: vectory, t: )

    

    return resultPoints
}
