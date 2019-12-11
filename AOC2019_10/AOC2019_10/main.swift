//
//  main.swift
//  AOC2019_10
//
//  Created by Lubomír Kaštovský on 10/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

struct Point: Hashable {
    var isAsteroid: Bool
    var x: Int
    var y: Int
    var isVisible: Bool
    var checked: Bool

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

func createMap(input: [String]) -> [[Point]] {
    var result: [[Point]] = []
    var y = 0
    for line in input {
        var x = 0
        var row: [Point] = []
        for c in line {
            if c == Character(".") {
                row.append(Point(isAsteroid: false, x: x, y: y, isVisible: true, checked: false))
            } else {
                row.append(Point(isAsteroid: true, x: x, y: y, isVisible: true, checked: false))
            }
            x += 1
        }
        result.append(row)
        y += 1
    }
    return result
}

func printMap(map: [[Point]]) {
    for y in 0 ..< map.count {
        var str = ""
        for x in 0 ..< map[0].count {
            if map[y][x].isAsteroid {
                str += "#"
            } else {
                str += "."
            }
        }
        print(str)
    }
}

// start is the asteroid from which I look
// end is where I look
func asteroidsInLine(map: [[Point]], start: Point, end: Point) -> Set<Point> {
    var resultPoints: Set<Point> = []
    // create line equation
    let vectorx = end.x - start.x
    let vectory = end.y - start.y
    var xstride: StrideTo<Int>!
    var ystride: StrideTo<Int>!
    if vectorx >= 0 {
        xstride = stride(from: Int(start.x + 1), to: map[0].count, by: 1)
    } else {
        xstride = stride(from: Int(start.x - 1), to: -1, by: -1)
    }
    if vectory >= 0 {
        ystride = stride(from: Int(start.y + 1), to: map.count, by: 1)
    } else {
        ystride = stride(from: Int(start.y - 1), to: -1, by: -1)
    }

    if vectorx != 0 {
        for x in xstride {
            let t = Double(x - start.x) / Double(vectorx)
            let y = Double(start.y) + (t * Double(vectory))
            let inty = Int(y)
            if trunc(y) == y, inty < map.count, inty >= 0 { // y is whole number
                let point = map[inty][x]
                if point.isAsteroid {
                    resultPoints.insert(point)
                }
            }
        }
    }

    if vectory != 0 {
        for y in ystride {
            let t = Double(y - start.y) / Double(vectory)
            let x = Double(start.x) + (t * Double(vectorx))
            let intx = Int(x)
            if trunc(x) == x, intx < map[0].count, intx >= 0 { // x is whole number
                let point = map[y][intx]
                if point.isAsteroid {
                    resultPoints.insert(point)
                }
            }
        }
    }

    return resultPoints
}

func findNearestAsteroid(asteroids: Set<Point>, myPosition: Point) -> Point? {
    var minDistance = Int.max
    var result: Point?
    for asteroid in asteroids {
        let distance = Int(abs(myPosition.x - asteroid.x) + abs(myPosition.y - asteroid.y))
        if distance < minDistance {
            result = asteroid
            minDistance = distance
        }
    }
    return result
}

func countVisibleAsteroids(map: [[Point]], asteroid: Point) -> Int {
    var count = 0
    var localMap = map
    for y in 0 ..< localMap.count {
        for x in 0 ..< localMap[0].count {
            if !(asteroid.x == x && asteroid.y == y) {
                let asteroids = asteroidsInLine(map: localMap, start: asteroid, end: localMap[y][x])
                if let nearest = findNearestAsteroid(asteroids: asteroids, myPosition: asteroid) {
                    for ast in asteroids {
                        if !(ast.x == nearest.x && ast.y == nearest.y) {
                            localMap[ast.y][ast.x].isVisible = false
                        }
                    }
                }
            }
        }
    }
    for y in 0 ..< localMap.count {
        for x in 0 ..< localMap[0].count {
            if localMap[y][x].isVisible, localMap[y][x].isAsteroid,
                !(asteroid.x == x && asteroid.y == y) {
                count += 1
            }
        }
    }
    return count
}

func findBestAsteroid(map: [[Point]]) -> (Point?, Int) {
    var bestCount = 0
    var bestAsteroid: Point?
    for y in 0 ..< map.count {
        for x in 0 ..< map[0].count {
            if map[y][x].isAsteroid {
                let count = countVisibleAsteroids(map: map, asteroid: map[y][x])
                if count > bestCount {
                    bestCount = count
                    bestAsteroid = map[y][x]
                }
            }
        }
    }
    return (bestAsteroid, bestCount)
}

func prepareAsteroidsInLine(map: [[Point]], station: Point) -> [Int: Set<Point>] {
    var result: [Int: Set<Point>] = [:]
    for y in 0 ..< map.count {
        for x in 0 ..< map[0].count {
            if map[y][x].isAsteroid {
                let line = asteroidsInLine(map: map, start: station, end: map[y][x])
                if let nearest = findNearestAsteroid(asteroids: line, myPosition: station) {
                    let key = nearest.y * 1000 + nearest.x
                    if result[key] == nil {
                        result[key] = line
                    } else {
                        result[key] = result[key]!.union(line)
                    }
                }
            }
        }
    }
    return result
}

/* my own quadrant numbering
          -y
          |
   IV.    |    I.
 -x ------------- +x
  III.    |   II.
          |
          +y
 */
//
func vectorsQuadrant(vx: Int, vy: Int) -> Int {
    if vx >= 0, vy < 0 {
        return 1
    }
    if vx > 0, vy >= 0 {
        return 2
    }
    if vx <= 0, vy > 0 {
        return 3
    }
    if vx < 0, vy <= 0 {
        return 4
    }
    return -1
}

// 0 equal
// 1 first lower
// 2 second lower
func compare(a: Point, b: Point, start: Point) -> Int {
    let vax = a.x - start.x
    let vay = a.y - start.y
    let vbx = b.x - start.x
    let vby = b.y - start.y
    let aquadrant = vectorsQuadrant(vx: vax, vy: vay)
    let bquadrant = vectorsQuadrant(vx: vbx, vy: vby)
    if aquadrant < bquadrant {
        return 1
    } else if aquadrant > bquadrant {
        return 2
    } else {
        // same quadrant
        var aa = 0.0
        var bb = 0.0
        switch aquadrant {
        case 1:
            aa = Double(vax) / Double(abs(vay))
            bb = Double(vbx) / Double(abs(vby))
        case 2:
            aa = Double(vay) / Double(vax)
            bb = Double(vby) / Double(vbx)
        case 3:
            aa = Double(abs(vax)) / Double(vay)
            bb = Double(abs(vbx)) / Double(vby)
        case 4:
            aa = Double(abs(vay)) / Double(abs(vax))
            bb = Double(abs(vby)) / Double(abs(vbx))
        default: return -1
        }
        if aa < bb {
            return 1
        } else if aa > bb {
            return 2
        } else {
            return 0
        }
    }
}

func order(asteroids: [Int: Set<Point>], station: Point) -> [Set<Point>] {
    var result: [Set<Point>] = []
    for key in asteroids.keys {
        result.append(asteroids[key]!)
    }
    result.sort { first, second in
        if let firstNearest = findNearestAsteroid(asteroids: first, myPosition: station),
            let secondNearest = findNearestAsteroid(asteroids: second, myPosition: station) {
            return compare(a: firstNearest, b: secondNearest, start: station) == 1
        }
        return false
    }
    return result
}

func vaporize(map: [[Point]], station: Point, nthToBeVaporized: Int) -> Point? {
    var limit = 0
    var vaporizeCounter = 0
    let asteroidLines = prepareAsteroidsInLine(map: map, station: station)
    var orderedAsteroidLines = order(asteroids: asteroidLines, station: station)
    var index = 0
    while true {
        if !orderedAsteroidLines[index].isEmpty {
            if let nearest = findNearestAsteroid(asteroids: orderedAsteroidLines[index], myPosition: station) {
                orderedAsteroidLines[index].remove(nearest)
                vaporizeCounter += 1
                if vaporizeCounter == nthToBeVaporized {
                    return nearest
                }
            }
        }
        index += 1
        if index == orderedAsteroidLines.count {
            index = 0
        }
        limit += 1
        if limit > 10000 {
            break
        }
    }
    return nil
}

let input = readLinesRemoveEmpty(str: inputString)
let map = createMap(input: input)
// printMap(map: map)

let start = DispatchTime.now()
let bestAsteroid = findBestAsteroid(map: map)
let end = DispatchTime.now()

let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
let timeInterval = Double(nanoTime) / 1_000_000_000

print("1. ", bestAsteroid.1, " elapsed time: ", timeInterval)
let station = bestAsteroid.0!
// print(station)

let start2 = DispatchTime.now()
if let vaporized = vaporize(map: map, station: station, nthToBeVaporized: 200) {
    let end2 = DispatchTime.now()
    let nanoTime = end2.uptimeNanoseconds - start2.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
    let timeInterval = Double(nanoTime) / 1_000_000_000
    print("2. ", Int(vaporized.x * 100 + vaporized.y), " elapsed time: ", timeInterval)

} else {
    let end2 = DispatchTime.now()
    let nanoTime = end2.uptimeNanoseconds - start2.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
    let timeInterval = Double(nanoTime) / 1_000_000_000
    print("failed,", " elapsed time: ", timeInterval)
}
