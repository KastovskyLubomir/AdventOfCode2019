//
//  main.swift
//  AOC2019_15
//
//  Created by Lubomir Kastovsky on 16/12/2019.
//  Copyright © 2019 Lubomir Kastovsky. All rights reserved.
//

import Foundation

let input = readLinesRemoveEmpty(str: inputString)
let program = stringNumArrayToArrayOfInt(input: input[0], separators: [","])

func loadToMemory(program: [Int]) -> [Int: Int] {
    var result: [Int: Int] = [:]
    var address = 0
    for mem in program {
        result[address] = mem
        address += 1
    }
    return result
}

func getParameter(mode: Int, pp: Int, offset: Int, memory: [Int: Int]) -> Int {
    // pp - parameter pointer
    let param = memory[pp] ?? 0
    if mode == 0 { // position mode
        return memory[param] ?? 0
    } else if mode == 1 { // immediate
        return param
    } else {
        return memory[param + offset] ?? 0
    }
}

func getResultAddress(mode: Int, pp: Int, offset: Int, memory: [Int: Int]) -> Int {
    let param = memory[pp] ?? 0
    if mode == 0 { // position mode
        return param
    } else if mode == 1 { // immediate
        print("wrong result address mode")
        return -1
    } else {
        return param + offset
    }
}

func computer(memory: inout [Int: Int], ip: inout Int, rbo: inout Int, input: Int) -> (output: Int, halted: Bool) {
    let opAdd = 1
    let opMul = 2
    let opInput = 3
    let opOutput = 4
    let opJmpIfTrue = 5
    let opJmpIfFalse = 6
    let opLessThan = 7
    let opEquals = 8
    let opRBOffset = 9
    let opHalt = 99

    var halt = false
    var output = 0

    while !halt {
        let instruction = memory[ip] ?? 0

        let opcode = instruction % 100
        let firstMode = (instruction / 100) % 10
        let secondMode = (instruction / 1000) % 10
        let thirdMode = (instruction / 10000)

        if opcode == opHalt {
            halt = true
            break
        } else if opcode == opAdd || opcode == opMul || opcode == opJmpIfTrue ||
            opcode == opJmpIfFalse || opcode == opLessThan || opcode == opEquals {
            let firstParam = getParameter(mode: firstMode, pp: ip + 1, offset: rbo, memory: memory)
            let secondParam = getParameter(mode: secondMode, pp: ip + 2, offset: rbo, memory: memory)
            let resultPointer = getResultAddress(mode: thirdMode, pp: ip + 3, offset: rbo, memory: memory)

            if opcode == opAdd {
                memory[resultPointer] = firstParam + secondParam
                ip += 4
            } else if opcode == opMul {
                memory[resultPointer] = firstParam * secondParam
                ip += 4
            } else if opcode == opJmpIfTrue {
                if firstParam != 0 {
                    ip = secondParam
                } else {
                    ip += 3
                }
            } else if opcode == opJmpIfFalse {
                if firstParam == 0 {
                    ip = secondParam
                } else {
                    ip += 3
                }
            } else if opcode == opLessThan {
                if firstParam < secondParam {
                    memory[resultPointer] = 1
                } else {
                    memory[resultPointer] = 0
                }
                ip += 4
            } else if opcode == opEquals {
                if firstParam == secondParam {
                    memory[resultPointer] = 1
                } else {
                    memory[resultPointer] = 0
                }
                ip += 4
            }
        } else if opcode == opInput {
            let resultPointer = getResultAddress(mode: firstMode, pp: ip + 1, offset: rbo, memory: memory)
            memory[resultPointer] = input
            ip += 2
        } else if opcode == opOutput {
            output = getParameter(mode: firstMode, pp: ip + 1, offset: rbo, memory: memory)
            ip += 2
            return (output, false)
        } else if opcode == opRBOffset {
            rbo += getParameter(mode: firstMode, pp: ip + 1, offset: rbo, memory: memory)
            ip += 2
        } else {
            print("wrong instruction: ", memory[ip] ?? 0)
            return (-1, true)
        }
    }

    return (output, true)
}

let north = 1
let south = 2
let west = 3
let east = 4

let wall = 0
let moved = 1
let oxygen = 2

typealias Map = [String: Int]

func reverseMove(move: Int) -> Int {
    switch move {
    case 1: return 2
    case 2: return 1
    case 3: return 4
    case 4: return 3
    default: return -1
    }
}

// lets go Bilbo :-)
func goThereAndBackAgain(path: [Int], memory: inout [Int: Int], ip: inout Int, rbo: inout Int) -> (field: Int, x: Int, y: Int) {
    var result = 0
    var x = 0
    var y = 0
    var p = path
    for step in p {
        if step == north {
            y -= 1
        }
        if step == south {
            y += 1
        }
        if step == east {
            x += 1
        }
        if step == west {
            x -= 1
        }
        result = computer(memory: &memory, ip: &ip, rbo: &rbo, input: step).output
    }
    if result == 0 {
        p.removeLast()
    }
    for i in 0 ..< p.count {
        let move = reverseMove(move: p[p.count - 1 - i])
        computer(memory: &memory, ip: &ip, rbo: &rbo, input: move)
    }
    return (result, x, y)
}

func getKey(x: Int, y: Int) -> String {
    return String(x) + "," + String(y)
}

func runTheDroid(program: [Int: Int]) -> Int {
    var memory = program
    var ip = 0
    var rbo = 0
    var paths = [[north], [east], [south], [west]]
    while !paths.isEmpty {
        // create direction
        let path = paths.first!
        paths.removeFirst()
        // give to droid
        let result = goThereAndBackAgain(path: path, memory: &memory, ip: &ip, rbo: &rbo)
        // inspect result
        if result.field == 1 {
            if path.last == north {
                // dont go back south
                paths.append(path + [north])
                paths.append(path + [east])
                paths.append(path + [west])
            }
            if path.last == east {
                paths.append(path + [north])
                paths.append(path + [east])
                paths.append(path + [south])
            }
            if path.last == south {
                paths.append(path + [east])
                paths.append(path + [south])
                paths.append(path + [west])
            }
            if path.last == west {
                paths.append(path + [north])
                paths.append(path + [south])
                paths.append(path + [west])
            }
        } else if result.field == 2 {
            return path.count
        }
    }
    return -1
}

func getCorners(grid: Map) -> (minx: Int, miny: Int, maxx: Int, maxy: Int) {
    var minx = 0
    var miny = 0
    var maxx = 0
    var maxy = 0
    grid.keys.forEach { key in
        let nums = key.components(separatedBy: [","])
        if minx > Int(nums[0])! {
            minx = Int(nums[0])!
        }
        if miny > Int(nums[1])! {
            miny = Int(nums[1])!
        }
        if maxx < Int(nums[0])! {
            maxx = Int(nums[0])!
        }
        if maxy < Int(nums[1])! {
            maxy = Int(nums[1])!
        }
    }
    return (minx: minx, miny: miny, maxx: maxx, maxy: maxy)
}

/*
 0: The repair droid hit a wall. Its position has not changed.
 1: The repair droid has moved one step in the requested direction.
 2: The repair droid has moved one step in the requested direction; its new position is the location of the oxygen system.
 */
func printMap(grid: Map) {
    let corners = getCorners(grid: grid)
    print(corners)
    for y in corners.miny ... corners.maxy {
        var row = ""
        for x in corners.minx ... corners.maxx {
            let key = getKey(x: x, y: y)
            if let tile = grid[key] {
                switch tile {
                case 0: row += "#"
                case 1: row += "."
                case 2: row += "O"
                default:
                    row += " "
                }
            } else {
                row += " "
            }
        }
        print(row)
    }
}

func runTheDroidToMapArea(program: [Int: Int]) -> Map {
    var map = Map()
    var memory = program
    var ip = 0
    var rbo = 0
    var paths = [[north], [east], [south], [west]]
    while !paths.isEmpty {
        // create direction
        let path = paths.first!
        paths.removeFirst()
        // give to droid
        let result = goThereAndBackAgain(path: path, memory: &memory, ip: &ip, rbo: &rbo)
        // inspect result
        map[getKey(x: result.x, y: result.y)] = result.field
        if result.field != 0 {
            if path.last == north {
                // dont go back south
                paths.append(path + [north])
                paths.append(path + [east])
                paths.append(path + [west])
            }
            if path.last == east {
                paths.append(path + [north])
                paths.append(path + [east])
                paths.append(path + [south])
            }
            if path.last == south {
                paths.append(path + [east])
                paths.append(path + [south])
                paths.append(path + [west])
            }
            if path.last == west {
                paths.append(path + [north])
                paths.append(path + [south])
                paths.append(path + [west])
            }
        }
    }
    return map
}

func hasSpotWithoutO2(map: Map) -> Bool {
    return !map.allSatisfy { $1 == 2 || $1 == 0 }
}

func spotsWithO2(map: Map) -> [String] {
    var result: [String] = []
    for key in map.keys {
        if map[key] == 2 {
            result.append(key)
        }
    }
    return result
}

func fillWithO2(map: Map) -> Int {
    var minutes = 0
    var m = map
    while hasSpotWithoutO2(map: m) {
        let o2 = spotsWithO2(map: m)
        for s in o2 {
            let parts = s.components(separatedBy: [","])
            let x = Int(parts[0])!
            let y = Int(parts[1])!
            for i in 0 ..< 4 {
                var key = ""
                switch i {
                case 0: key = getKey(x: x, y: y - 1)
                case 1: key = getKey(x: x, y: y + 1)
                case 2: key = getKey(x: x - 1, y: y)
                case 3: key = getKey(x: x + 1, y: y)
                default: break
                }
                if let spot = m[key] {
                    if spot == 1 {
                        m[key] = 2
                    }
                }
            }
        }
        minutes += 1
        // printMap(grid: m)
    }

    return minutes
}

let memory = loadToMemory(program: program)

let start = DispatchTime.now()
print("Part 1:", runTheDroid(program: memory))
let end = DispatchTime.now()
let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
let timeInterval = Double(nanoTime) / 1_000_000_000
print("duration:", timeInterval)

let start2 = DispatchTime.now()
let map = runTheDroidToMapArea(program: memory)
// printMap(grid: map)
print("Part 2:", fillWithO2(map: map))
let end2 = DispatchTime.now()
let nanoTime2 = end2.uptimeNanoseconds - start2.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
let timeInterval2 = Double(nanoTime2) / 1_000_000_000
print("duration:", timeInterval2)
