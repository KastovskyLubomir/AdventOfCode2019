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
    var x: Double
    var y: Double
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

let input = readLinesRemoveEmpty(str: inputString)

func createMap(input: [String]) -> [[Point]] {
    var result: [[Point]] = []
    var y = 0
    for line in input {
        var x = 0
        var row: [Point] = []
        for c in line {
            if c == Character(".") {
				row.append(Point(isAsteroid: false, x: Double(x), y: Double(y), isVisible: true, checked: false))
            } else {
                row.append(Point(isAsteroid: true, x: Double(x), y: Double(y), isVisible: true, checked: false))
            }
            x += 1
        }
        result.append(row)
        y += 1
    }
    return result
}

func printMap(map: [[Point]]) {
	for y in 0..<map.count {
		var str = ""
		for x in 0..<map[0].count {
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
/*
	if vectorx >= 0 { // 1. and 4. quadrant
		// go from starting position of x and increase to bounds
		for x in Int(start.x)..<map[0].count {
			let t = (Double(x) - start.x)/vectorx
			let y = start.y + (t * vectory)
			if trunc(y) == y && Int(y) < map.count && Int(y) >= 0 {	// y is whole number
				let point = map[Int(y)][x]
				if point.isAsteroid {
					resultPoints.append(point)
				}
			}
		}
	} else if vectorx < 0 { // 2. and 3. quadrant
		for x in stride(from: Int(start.x-1), to: -1, by: -1) {
			let t = (Double(x) - start.x)/vectorx
			let y = start.y + (t * vectory)
			if trunc(y) == y && Int(y) < map.count && Int(y) >= 0 {	// y is whole number
				let point = map[Int(y)][x]
				if point.isAsteroid {
					resultPoints.append(point)
				}
			}
		}
	}
*/
	var xstride: StrideTo<Int>!
	var ystride: StrideTo<Int>!
	if vectorx >= 0 {
		xstride = stride(from: Int(start.x+1), to: map[0].count, by: 1)
	} else {
		xstride = stride(from: Int(start.x-1), to: -1, by: -1)
	}
	if vectory >= 0 {
		ystride = stride(from: Int(start.y+1), to: map.count, by: 1)
	} else {
		ystride = stride(from: Int(start.y-1), to: -1, by: -1)
	}

	if vectorx != 0 {
		for x in xstride {
			let t = (Double(x) - start.x)/vectorx
			let y = start.y + (t * vectory)
			if trunc(y) == y && Int(y) < map.count && Int(y) >= 0 {	// y is whole number
				let point = map[Int(y)][x]
				if point.isAsteroid {
					resultPoints.insert(point)
				}
			}
		}
	}

	if vectory != 0 {
		for y in ystride {
			let t = (Double(y) - start.y)/vectory
			let x = start.x + (t * vectorx)
			if trunc(x) == x && Int(x) < map[0].count && Int(x) >= 0 {	// x is whole number
				let point = map[y][Int(x)]
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

func countVisibleAsteroids(map:[[Point]], asteroid: Point) -> Int {
	var count = 0
	var localMap = map
	for y in 0..<localMap.count {
		for x in 0..<localMap[0].count {
			if !(Int(asteroid.x) == x && Int(asteroid.y) == y) {
				let asteroids = asteroidsInLine(map: localMap, start: asteroid, end: localMap[y][x])
				//print("to x: ", x, ", y: ", y, ">", asteroids)
				if let nearest = findNearestAsteroid(asteroids: asteroids, myPosition: asteroid) {
					//print(nearest)
					for ast in asteroids {
						if !(ast.x == nearest.x && ast.y == nearest.y) {
							localMap[Int(ast.y)][Int(ast.x)].checked = true
							localMap[Int(ast.y)][Int(ast.x)].isVisible = false
						}
					}
				}
			}
		}
	}

	for y in 0..<localMap.count {
		for x in 0..<localMap[0].count {
			if localMap[y][x].isVisible && localMap[y][x].isAsteroid &&
				!(Int(asteroid.x) == x && Int(asteroid.y) == y) {
				count += 1
			}
		}
	}

	//print(count)
	//print(localMap)
	//print("---------------")
	return count

}

let map = createMap(input: input)

printMap(map: map)
//print(asteroidsInLine(map: map, start: map[0][4], end: map[4][4]))
//let line = asteroidsInLine(map: map, start: map[9][9], end: map[8][8])
//print(findNearestAsteroid(asteroids: line, myPosition: map[0][0]))

func findBestAsteroid(map: [[Point]]) -> (Point?, Int) {
	var bestCount = 0
	var bestAsteroid: Point?
	for y in 0..<map.count {
		for x in 0..<map[0].count {
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

//print(countVisibleAsteroids(map: map, asteroid: map[4][3]))
//let bestAsteroid = findBestAsteroid(map: map)
//print("1. ", bestAsteroid.1)

//let station = bestAsteroid.0!

func vaporize(space: [[Point]], station: Point, nthToBeVaporized: Int) -> Point? {
	var limit = 0
	var vaporizeCounter = 0
	var map = space
	let rotationSteps = (map.count + map[0].count) * 2
	var x = Int(station.x)
	var y = 0
	var xIncrement = 1
	var yIncrement = 0
	while true {
		for _ in 0..<rotationSteps {
			if (x == map[0].count - 1) && ( y == 0){
				xIncrement = 0
				yIncrement = 1
			}
			if (x == map[0].count - 1) && (y == map.count - 1) {
				xIncrement = -1
				yIncrement = 0
			}
			if (x == 0) && (y == map.count - 1){
				xIncrement = 0
				yIncrement = -1
			}
			if (x == 0) && (y == 0) {
				xIncrement = 1
				yIncrement = 0
			}

			let line = asteroidsInLine(map: map, start: station, end: map[y][x])
			if let nearest = findNearestAsteroid(asteroids: line, myPosition: station) {
				// vaporize
				vaporizeCounter += 1
				map[Int(nearest.y)][Int(nearest.x)].isAsteroid = false
				if vaporizeCounter == nthToBeVaporized {
					return nearest
				}
			}
			x += xIncrement
			y += yIncrement
		}
		limit += 1
		if limit > 100000 {
			break
		}
	}
	return nil
}

func prepareOrdered(map: [[Point]], station: Point) -> [Int: Set<Point>] {
	var result: [Int: Set<Point>] = [:]
	for y in 0..<map.count {
		for x in 0..<map[0].count {
			if map[y][x].isAsteroid {
				let line = asteroidsInLine(map: map, start: station, end: map[y][x])
				if let nearest = findNearestAsteroid(asteroids: line, myPosition: station) {
					let key = Int(nearest.y * 1000 + nearest.x)
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
func vectorsQuadrant(vx: Double, vy: Double) -> Int {
    if vx >= 0 && vy < 0 {
        return 1
    }
    if vx > 0 && vy >= 0 {
        return 2
    }
    if vx <= 0 && vy > 0 {
        return 3
    }
    if vx < 0 && vy <= 0 {
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
            aa = vax/abs(vay)
            bb = vbx/abs(vby)
        case 2:
            aa = vay/vax
            bb = vby/vbx
        case 3:
            aa = abs(vax)/vay
            bb = abs(vbx)/vby
        case 4:
            aa = abs(vay)/abs(vax)
            bb = abs(vby)/abs(vbx)
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
            let secondNearest = findNearestAsteroid(asteroids: first, myPosition: station) {
                return compare(a: firstNearest, b: secondNearest, start: station) == 1
        }
        return false
	}

	return result
}
/*
for key in dict.keys {
	print("count: ",dict[key]?.count, " > ", dict[key])
}
*/

let station = Point(isAsteroid: true, x: 3, y: 3, isVisible: true, checked: false)
let dict = prepareOrdered(map: map, station: station)
print(station)
let ordered = order(asteroids: dict, station: station)

for x in ordered {
    print("count: ",x.count, " > ", x)
}

/*
if let vaporized = vaporize(space: map, station: station, nthToBeVaporized: 200) {
	print("2. ", Int(vaporized.x * 100 + vaporized.y))
} else {
	print("failed")
}
*/
