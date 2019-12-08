//
//  main.swift
//  AOC2019_07
//
//  Created by Lubomír Kaštovský on 08/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

let input = readLinesRemoveEmpty(str: inputString)
var programMemory = stringNumArrayToArrayOfInt(input: input[0], separators: [","])

func generateVariances(input: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    for x in input {
        var inp = input
        if let index = inp.firstIndex(where: { $0 == x }) {
            inp.remove(at: index)
            let variances = generateVariances(input: inp)
            if variances.isEmpty {
                result.append([x])
            } else {
                for variance in variances {
                    let newVar = [x] + variance
                    result.append(newVar)
                }
            }
        }
    }
    return result
}

func computer(programMemory: [Int], input: [Int]) -> Int {

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

    var output = 0
	var inputPointer = 0

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
			let p = memory[ip+1]
			if inputPointer < input.count {
				memory[p] = input[inputPointer]
			} else {
				print("inputPointer out of range")
				return -1
			}
			inputPointer += 1
            ip += 2
        } else if opcode == opOutput {
			let p = memory[ip+1]
			output = memory[p]
            ip += 2
        } else {
            print("wrong instruction: ", memory[ip])
            return -1
        }
    }

    return output
}

//let varInput = [0,1,2,3,4]
//let variances = generateVariances(input: varInput)
//print(variances.count, variances)

func runAmplifiers(phases: [Int], programMemory: [Int]) -> Int {
	var signal = 0
	for phase in phases {
		let output = computer(programMemory: programMemory, input: [phase, signal])
		signal = output
	}
	return signal
}

func findBestSignal(availablePhases: [Int], programMemory: [Int]) -> Int {
	var maxSignal = 0
	let phaseVariances = generateVariances(input: availablePhases)
	for phases in phaseVariances {
		let signal = runAmplifiers(phases: phases, programMemory: programMemory)
		if signal > maxSignal {
			maxSignal = signal
		}
	}
	return maxSignal
}

func feedbackComputer(
	programMemory: [Int],
	ip: Int,
	phase: Int,
	input: Int,
	lastOutput: Int
	) -> (output: Int, memory: [Int], ip: Int, halted: Bool) {

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
    var ip = ip
    var halt = false

	var localInput = phase
    var output = lastOutput

	if phase == -1 {
		localInput = input
	}

    while !halt {

        let opcode = memory[ip] % 100
        let firstParamMode = (memory[ip] / 100) % 10
        let secondParamMode = (memory[ip] / 1000) % 10

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
			let p = memory[ip+1]
			memory[p] = localInput
            ip += 2
			localInput = input
        } else if opcode == opOutput {
			let p = memory[ip+1]
			output = memory[p]
            ip += 2
			//print("outputing: ", output)
			return (output, memory, ip, false)
        } else {
            print("wrong instruction: ", memory[ip])
            return (-1, [], -1, true)
        }
    }
	//print("halted")
    return (output, memory, ip, true)
}

func runFeedbackLoop(phases: [Int], programMemory: [Int]) -> Int {
	var memories = [[Int]].init(repeating: programMemory, count: phases.count)
	var localPhases = phases
	var ips = [Int].init(repeating: 0, count: phases.count)
	var amplifierId = 0
	var input = 0

	while true {
		//print("------------")
		//print(amplifierId)
		//print(input)
		//print(localPhases[amplifierId])
		let result = feedbackComputer(
			programMemory: memories[amplifierId],
			ip: ips[amplifierId],
			phase: localPhases[amplifierId],
			input: input,
			lastOutput: input
		)
		if result.halted {
			//print("out: ", result.output)
			//print("------------")
			return result.output
		}
		localPhases[amplifierId] = -1
		memories[amplifierId] = result.memory
		ips[amplifierId] = result.ip
		input = result.output
		amplifierId += 1
		if amplifierId == phases.count {
			amplifierId = 0
		}
	}
}

func findStrongestSignal(availablePhases: [Int], programMemory: [Int]) -> Int {
	var maxSignal = 0
	let phaseVariances = generateVariances(input: availablePhases)
	for phases in phaseVariances {
		//print(phases)
		let signal = runFeedbackLoop(phases: phases, programMemory: programMemory)
		//print(signal)
		if signal > maxSignal {
			maxSignal = signal
		}
	}
	return maxSignal
}

//print("1. ", findBestSignal(availablePhases: [0,1,2,3,4], programMemory: programMemory))
print("2. ", findStrongestSignal(availablePhases: [5,6,7,8,9], programMemory: programMemory))
