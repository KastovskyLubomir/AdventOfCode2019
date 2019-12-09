//
//  main.swift
//  AOC2019_09
//
//  Created by Lubomir Kastovsky on 09/12/2019.
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

func computer(programMemory: [Int: Int], input: Int) -> Int {
    var memory = programMemory

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

    var relativeBaseOffset: Int = 0
    var ip = 0
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
            let firstParam = getParameter(mode: firstMode, pp: ip + 1, offset: relativeBaseOffset, memory: memory)
            let secondParam = getParameter(mode: secondMode, pp: ip + 2, offset: relativeBaseOffset, memory: memory)
            let resultPointer = getResultAddress(mode: thirdMode, pp: ip + 3, offset: relativeBaseOffset, memory: memory)

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
            let resultPointer = getResultAddress(mode: firstMode, pp: ip + 1, offset: relativeBaseOffset, memory: memory)
            memory[resultPointer] = input
            ip += 2
        } else if opcode == opOutput {
            output = getParameter(mode: firstMode, pp: ip + 1, offset: relativeBaseOffset, memory: memory)
            ip += 2
        } else if opcode == opRBOffset {
            relativeBaseOffset += getParameter(mode: firstMode, pp: ip + 1, offset: relativeBaseOffset, memory: memory)
            ip += 2
        } else {
            print("wrong instruction: ", memory[ip] ?? 0)
            return -1
        }
    }

    return output
}

let programMemory = loadToMemory(program: program)
print("1. ", computer(programMemory: programMemory, input: 1))
print("2. ", computer(programMemory: programMemory, input: 2))
