//
//  main.swift
//  AOC2019_03
//
//  Created by Lubomir Kastovsky on 05/12/2019.
//  Copyright © 2019 Lubomir Kastovsky. All rights reserved.
//

import Foundation

let wires = readLinesRemoveEmpty(str: inputString)
let wirePath1 = stringWordArrayToArrayOfWords(input: wires[0], separators: [","])
let wirePath2 = stringWordArrayToArrayOfWords(input: wires[1], separators: [","])

print(wirePath1)
print(wirePath2)

struct Point: Hashable {
	var x: Int
	var y: Int

	static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct Line {
	var points: Set<Point>
}

enum Direction: Int {
	case Up
	case Down
	case Right
	case Left
	case None
}

func direction(step: String) -> Direction {
	switch step.first {
	case Character("U"):  return .Up
	case Character("D"):  return .Down
	case Character("R"):  return .Right
	case Character("L"):  return .Left
	default: return .None
	}
}

func length(step: String) -> Int {
	let len = String(step.dropFirst(1))
	return Int(len) ?? 0
}

func createLines(wirePath: [String]) -> [Line] {
	var lines: Array<Line> = []
	var start = Point(x: 0, y: 0)
	var end = Point(x: 0, y: 0)
	wirePath.forEach { step in
		let len = length(step: step)
        var line = Line(points: [])
		let dir = direction(step: step)
        if dir == .Up || dir == .Down {
            if dir == .Up {
                end = Point(x: start.x, y: start.y + len)
            }
            if dir == .Down {
                end = Point(x: start.x, y: start.y - len)
            }
            if start.y < end.y {
                for y in start.y...end.y {
                    line.points.insert(Point(x: start.x, y: y))
                }
            } else {
                for y in end.y...start.y {
                    line.points.insert(Point(x: start.x, y: y))
                }
            }
        }
        if dir == .Right || dir == .Left {
            if dir == .Right {
                end = Point(x: start.x + len, y: start.y)
            }
            if dir == .Left {
                end = Point(x: start.x - len, y: start.y)
            }
            if start.x < end.x {
                for x in start.x...end.x {
                    line.points.insert(Point(x: x, y: start.y))
                }
            } else {
                for x in end.x...start.x {
                    line.points.insert(Point(x: x, y: start.y))
                }
            }
        }
		start = end
        lines.append(line)
	}
	return lines
}

func hasIntersection(line1: Line, line2: Line) -> Bool {
    return !line1.points.intersection(line2.points).isEmpty
}

func intersectingPoint(line1: Line, line2: Line) -> Point? {
    return line1.points.intersection(line2.points).first
}

let wire1Lines = createLines(wirePath: wirePath1)
let wire2Lines = createLines(wirePath: wirePath2)

//print(wire1Lines)
//print(wire2Lines)

func closestIntersectionDistance(wireLines1: Array<Line>, wireLines2: Array<Line>) -> Int {
	var distance = Int.max
    for i in 0..<wireLines1.count {
        let line1 = wireLines1[i]
        for j in 0..<wireLines2.count {
            let line2 = wireLines2[j]
            if hasIntersection(line1: line1, line2: line2) {
                if let intersection = intersectingPoint(line1: line1, line2: line2) {
                    if !(intersection.x == 0 && intersection.y == 0) {
                        let dist = abs(intersection.x) + abs(intersection.y)
                        if dist < distance {
                            distance = dist
                            print(distance)
                        }
                    }
                }
            }
		}
	}
	return distance
}

print("1. ", closestIntersectionDistance(wireLines1: wire1Lines, wireLines2: wire2Lines))


// find intersections and measure their distances
func allIntersections(wireLines1: Array<Line>, wireLines2: Array<Line>) -> Array<Point> {
	var intersections: [Point] = []
	for i in 0..<wireLines1.count {
        let line1 = wireLines1[i]
        for j in 0..<wireLines2.count {
            let line2 = wireLines2[j]
            if hasIntersection(line1: line1, line2: line2) {
                if let intersection = intersectingPoint(line1: line1, line2: line2) {
                    if !(intersection.x == 0 && intersection.y == 0) {
						intersections.append(intersection)
                    }
                }
            }
		}
	}
	return intersections
}

func measurePathForPointInWire(wirePath: [String], point: Point) -> Int {
	var wireLength = 0
	var x = 0
	var y = 0
	for step in wirePath {
		let len = length(step: step)
		let dir = direction(step: step)
		if dir == .Up {
			for _ in 0..<len {
				wireLength += 1
				y += 1
				if point.x == x && point.y == y {
					return wireLength
				}
			}
		}
		if dir == .Down {
			for _ in 0..<len {
				wireLength += 1
				y -= 1
				if point.x == x && point.y == y {
					return wireLength
				}
			}
		}
		if dir == .Right {
			for _ in 0..<len {
				wireLength += 1
				x += 1
				if point.x == x && point.y == y {
					return wireLength
				}
			}
		}
		if dir == .Left {
			for _ in 0..<len {
				wireLength += 1
				x -= 1
				if point.x == x && point.y == y {
					return wireLength
				}
			}
		}
	}
	return 0
}

let intersections = allIntersections(wireLines1: wire1Lines, wireLines2: wire2Lines)

func shortestPathToIntersection(intersections: [Point], wire1Path: [String], wire2Path: [String]) -> Int {
	var resultDist = Int.max
	for inter in intersections {
		let first = measurePathForPointInWire(wirePath: wire1Path, point: inter)
		let second = measurePathForPointInWire(wirePath: wire2Path, point: inter)
		let distance = first + second
		if distance < resultDist {
			resultDist = distance
		}
	}
	return resultDist
}

print("2. ", shortestPathToIntersection(intersections: intersections, wire1Path: wirePath1, wire2Path: wirePath2))
