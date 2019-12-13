//
//  main.swift
//  AOC2019_13
//
//  Created by Lubomir Kastovsky on 13/12/2019.
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

typealias Grid = [String: Int]

func getKey(x: Int, y: Int) -> String {
	return String(x) + "," + String(y)
}

func drawToGrid(program: [Int: Int]) -> Grid {
	var grid: Grid = [:]
	var memory = program
	var ip = 0
	var rbo = 0
	var input = 0
	while true {
		let x = computer(memory: &memory, ip: &ip, rbo: &rbo, input: input)
		if x.halted {
			break
		}
		let y = computer(memory: &memory, ip: &ip, rbo: &rbo, input: input)
		if y.halted {
			break
		}
		let tile = computer(memory: &memory, ip: &ip, rbo: &rbo, input: input)
		if tile.halted {
			break
		}

		let key = getKey(x: x.output, y: y.output)
		grid[key] = tile.output

	}
	return grid
}

func countTiles(type: Int, grid: Grid) -> Int {
	var sum = 0
	grid.keys.forEach { key in
		if let val = grid[key], val == type {
			sum += 1
		}
	}
	return sum
}

/*
0 is an empty tile. No game object appears in this tile.
1 is a wall tile. Walls are indestructible barriers.
2 is a block tile. Blocks can be broken by the ball.
3 is a horizontal paddle tile. The paddle is indestructible.
4 is a ball tile. The ball moves diagonally and bounces off objects.
*/
func printGrid(grid: Grid) {
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
	for y in miny...maxy {
		var row = ""
		for x in minx...maxx {
			let key = getKey(x: x, y: y)
			if let tile = grid[key] {
				switch tile {
				case 0: row += " "
				case 1: row += "#"
				case 2: row += "@"
				case 3: row += "-"
				case 4: row += "*"
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

let memory = loadToMemory(program: program)
let grid = drawToGrid(program: memory)
print(countTiles(type: 2, grid: grid))
printGrid(grid: grid)
