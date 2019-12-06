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
		var line: Line = Line(
		switch direction(step: step) {
		case .Up: end = Point(x: start.x, y: start.y + len)

		case .Down: end = Point(x: start.x, y: start.y - len)
		case .Right: end = Point(x: start.x + len, y: start.y)
		case .Left: end = Point(x: start.x - len, y: start.y)
		default: break
		}
		lines.append(Line(start: start, end: end))
		start = end
	}
	return lines
}

func hasIntersectionX(firstLine: Line, secondLine: Line) -> Bool {
	let ax1 = firstLine.start.x
	let ax2 = firstLine.end.x
	let bx1 = secondLine.start.x
	let bx2 = secondLine.end.x
	if (ax1 <= ax2) && ((ax1 <= bx1 && bx1 <= ax2) || (ax1 <= bx2 && bx2 <= ax2)) {
		return true
	}
	if (ax2 < ax1) && ((ax2 <= bx1 && bx1 <= ax1) || (ax2 <= bx2 && bx2 <= ax1)) {
		return true
	}
	return false
}

func hasIntersectionY(firstLine: Line, secondLine: Line) -> Bool {
	let ay1 = firstLine.start.y
	let ay2 = firstLine.end.y
	let by1 = secondLine.start.y
	let by2 = secondLine.end.y
	if (ay1 <= ay2) && ((ay1 <= by1 && by1 <= ay2) || (ay1 <= by2 && by2 <= ay2)) {
		return true
	}
	if (ay2 < ay1) && ((ay2 <= by1 && by1 <= ay1) || (ay2 <= by2 && by2 <= ay1)) {
		return true
	}
	return false
}

func isSameLine(line1: Line, line2: Line) -> Bool {
	return line1.start.x == line2.start.x &&
		line1.end.x == line2.end.x &&
		line1.start.y == line2.start.y &&
		line1.end.y == line2.end.y
}

func linesIntersection(firstLine: Line, secondLine: Line) -> Point? {
	if firstLine.start.x == firstLine.end.x {
		// vertical line
		var starty = firstLine.start.y
		var endy = firstLine.end.y
		if starty > endy {
			starty = firstLine.end.y
			endy = firstLine.start.y
		}
		for y in starty...endy {
			if secondLine.start.x == secondLine.end.x {
				// vertical line, dont know if can overlap???
				// probably not
				return nil
			} else {
				var startx = secondLine.start.x
				var endx = secondLine.end.x
				if startx > endx {
					startx = secondLine.end.x
					endx = secondLine.start.x
				}
				for x in startx...endx {
					if firstLine.start.x == x && y == secondLine.start.y {
						return Point(x: x, y: y)
					}
				}
			}
		}
	} else {
		// horizontal line
		var startx = firstLine.start.x
		var endx = firstLine.end.x
		if startx > endx {
			startx = firstLine.end.x
			endx = firstLine.start.x
		}
		for x in startx...endx {
			if secondLine.start.y == secondLine.end.y {
				// horizontal line, no intersection
				return nil
			} else {
				var starty = secondLine.start.y
				var endy = secondLine.end.y
				if starty > endy {
					starty = secondLine.end.y
					endy = secondLine.start.y
				}
				for y in starty...endy {
					if x == secondLine.start.x && firstLine.start.y == y {
						return Point(x: x, y: y)
					}
				}
			}
		}
	}
	return nil
}

let wire1Lines = createLines(wirePath: wirePath1)
let wire2Lines = createLines(wirePath: wirePath2)

print(wire1Lines)
print(wire2Lines)

func closestIntersectionDistance(wireLines1: Array<Line>, wireLines2: Array<Line>) -> Int {
	var distance = Int.max
	wireLines1.forEach { line1 in
		wireLines2.forEach { line2 in
			print("line1: ", line1)
			print("line2: ", line2)
			print("")
			if !isSameLine(line1: line1, line2: line2) {
				if hasIntersectionX(firstLine: line1, secondLine: line2) &&
					hasIntersectionY(firstLine: line1, secondLine: line2) {
					if let intersectionPoint = linesIntersection(firstLine: line1, secondLine: line2) {
						print(intersectionPoint)
						if !(intersectionPoint.x == 0 && intersectionPoint.y == 0) {
							let dist = abs(intersectionPoint.x) + abs(intersectionPoint.y)
							if dist < distance {
								distance = dist
								print(distance)
							}
						}
					}
				}
			}
		}
	}
	return distance
}

print("1. ", closestIntersectionDistance(wireLines1: wire1Lines, wireLines2: wire2Lines))

