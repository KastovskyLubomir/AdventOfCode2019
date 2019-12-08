//
//  main.swift
//  AOC2019_05
//
//  Created by Lubomír Kaštovský on 07/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

//print(inputString)
let input = readLinesRemoveEmpty(str: inputString)
var programMemory = stringNumArrayToArrayOfInt(input: input[0], separators: [","])

//print(programMemory)

func runProgram1(programMemory: [Int]) -> Int {

    let opAdd = 1
    let opMul = 2
    let opInput = 3
    let opOutput = 4
    let opHalt = 99
    var memory = programMemory
    var ip = 0
    var halt = false

    var input = 1
    var output = 0

    while !halt {

        let opcode = memory[ip] % 100
        let firstParamMode = (memory[ip] / 100) % 10
        let secondParamMode = (memory[ip] / 1000) % 10
        let thirdParamMode = (memory[ip] / 10000)

        if opcode == opHalt {
            halt = true
            break
        } else if opcode == opAdd || opcode == opMul {
            var firstParam = 0
            var secondParam = 0
            if firstParamMode == 0 { // position mode
                firstParam = memory[memory[ip+1]]
            } else { // immediate
                firstParam = memory[ip+1]
            }
            if secondParamMode == 0 {
                secondParam = memory[memory[ip+2]]
            } else {
                secondParam = memory[ip+2]
            }
            let resultPointer = memory[ip+3]

            if opcode == opAdd {
                memory[resultPointer] = firstParam + secondParam
            }

            if opcode == opMul {
                memory[resultPointer] = firstParam * secondParam
            }
            ip += 4
        } else if opcode == opInput {
            if firstParamMode == 0 { // position mode
                //let p = memory[memory[ip+1]]
                let p = memory[ip+1]
                memory[p] = input
            } else { // immediate
                let p = memory[ip+1]
                memory[p] = input
            }
            ip += 2
        } else if opcode == opOutput {
            if firstParamMode == 0 { // position mode
                //let p = memory[memory[ip+1]]
                let p = memory[ip+1]
                output = memory[p]
            } else { // immediate
                let p = memory[ip+1]
                output = memory[p]
            }
            //print("output: ", output)
            ip += 2
        } else {
            print("wrong instruction: ", memory[ip])
            return -1
        }
        //print(ip)
    }

    return output
}

print("1. ", runProgram1(programMemory: programMemory))

func runProgram2(programMemory: [Int]) -> Int {

    let opAdd = 1
    let opMul = 2
    let opInput = 3
    let opOutput = 4
    let opJmpIfTrue = 5
    let opJmpIfFalse = 6
    let opLessThan = 7
    let opEquals = 8
    let opHalt = 99
    var memory = programMemory
    var ip = 0
    var halt = false

    var input = 5
    var output = 0

    while !halt {

        let opcode = memory[ip] % 100
        let firstParamMode = (memory[ip] / 100) % 10
        let secondParamMode = (memory[ip] / 1000) % 10
        let thirdParamMode = (memory[ip] / 10000)

        if opcode == opHalt {
            halt = true
            break
        } else if opcode == opAdd || opcode == opMul || opcode == opJmpIfTrue ||
            opcode == opJmpIfFalse || opcode == opLessThan || opcode == opEquals {
            var firstParam = 0
            var secondParam = 0
            if firstParamMode == 0 { // position mode
                firstParam = memory[memory[ip+1]]
            } else { // immediate
                firstParam = memory[ip+1]
            }
            if secondParamMode == 0 {
                secondParam = memory[memory[ip+2]]
            } else {
                secondParam = memory[ip+2]
            }
            let resultPointer = memory[ip+3]

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
            if firstParamMode == 0 { // position mode
                //let p = memory[memory[ip+1]]
                let p = memory[ip+1]
                memory[p] = input
            } else { // immediate
                let p = memory[ip+1]
                memory[p] = input
            }
            ip += 2
        } else if opcode == opOutput {
            if firstParamMode == 0 { // position mode
                //let p = memory[memory[ip+1]]
                let p = memory[ip+1]
                output = memory[p]
            } else { // immediate
                let p = memory[ip+1]
                output = memory[p]
            }
            //print("output: ", output)
            ip += 2
        } else {
            print("wrong instruction: ", memory[ip])
            return -1
        }
        //print(ip)
    }

    return output
}

print("2. ", runProgram2(programMemory: programMemory))
