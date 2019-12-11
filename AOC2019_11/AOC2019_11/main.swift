//
//  main.swift
//  AOC2019_11
//
//  Created by Lubomír Kaštovský on 11/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
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

func computer(memory: inout [Int: Int], ip: inout Int, rbo: inout Int, input: Int) -> (Int, Bool) {
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

    //var relativeBaseOffset: Int = 0
    //var ip = 0
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

let memory = loadToMemory(program: program)

func robotDoPainting(program: [Int: Int]) -> [String: Int] {
    enum Direction {
        case Up
        case Down
        case Left
        case Right
    }
    var surface: [String: Int] = [:]

    surface["0,0"] = 1  // comment for 1. uncoment for 2.
    var memory = program
    var ip = 0
    var rbo = 0
    var positionx = 0
    var positiony = 0
    var paintColor = 0
    var surfaceColor = 0
    var doTurn = 0
    var direction: Direction = .Up
    while true {
        let key = String(positionx) + "," + String(positiony)
        if let color = surface[key] {
            surfaceColor = color
        } else {
            surfaceColor = 0
        }
        let result = computer(memory: &memory, ip: &ip, rbo: &rbo, input: surfaceColor)
        paintColor = result.0
        if result.1 {
            break
        }
        let result2 = computer(memory: &memory, ip: &ip, rbo: &rbo, input: surfaceColor)
        doTurn = result2.0
        if result2.1 {
            break
        }
        // paint
        surface[key] = paintColor
        // turn
        switch direction {
        case .Up:
            if doTurn == 0 {
                direction = .Left
            } else {
                direction = .Right
            }
        case .Left:
            if doTurn == 0 {
                direction = .Down
            } else {
                direction = .Up
            }
        case .Down:
            if doTurn == 0 {
                direction = .Right
            } else {
                direction = .Left
            }
        case .Right:
            if doTurn == 0 {
                direction = .Up
            } else {
                direction = .Down
            }
        }
        // move
        switch direction {
        case .Up:
            positiony += 1
        case .Left:
            positionx -= 1
        case .Down:
            positiony -= 1
        case .Right:
            positionx += 1
        }
    }
    return surface
}

print(memory)
//print("1. ", robotDoPainting(program: memory).count)

func findCorners(surface: [String: Int]) -> (x1: Int, y1: Int, x2: Int, y2: Int) {
    var x1 = 0
    var y1 = 0
    var x2 = 0
    var y2 = 0
    for key in surface.keys {
        let components = key.components(separatedBy: [","])
        if let x = Int(components[0]), let y = Int(components[1]) {
            if x < x1 {
                x1 = x
            }
            if x > x2 {
                x2 = x
            }
            if y < y1 {
                y1 = y
            }
            if y > y2 {
                y2 = y
            }
        }
    }
    return (x1, y1, x2, y2)
}


func printSurface(surface: [String: Int], minx: Int, miny: Int, maxx: Int, maxy: Int) {
    for y in miny...maxy {
        var row = ""
        for x in minx...maxx {
            let key = String(x) + "," + String(y)
            if let color = surface[key] {
                if color == 1 {
                    row += "#"
                } else {
                    row += "."
                }
            } else {
                row += "."
            }
        }
        print(row)
    }
}

let surface = robotDoPainting(program: memory)
let corners = findCorners(surface: surface)
printSurface(surface: surface, minx: corners.x1, miny: corners.y1, maxx: corners.x2, maxy: corners.y2)
