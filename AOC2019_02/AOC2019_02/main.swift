//
//  main.swift
//  AOC2019_02
//
//  Created by Lubomir Kastovsky on 04/12/2019.
//  Copyright © 2019 Lubomir Kastovsky. All rights reserved.
//

import Foundation

//print(inputString)
let input = readLinesRemoveEmpty(str: inputString)
var programMemory = stringNumArrayToArrayOfInt(input: input[0], separators: [","])

//print(programMemory)

func runProgram1(programMemory: [Int]) -> Int {

	let opAdd = 1
	let opMul = 2
	let opHalt = 99
	var memory = programMemory
	var ip = 0
	while memory[ip] != opHalt {
		let a = memory[memory[ip+1]]
		let b = memory[memory[ip+2]]
		let rp = memory[ip+3]

		if memory[ip] == opAdd {
			memory[rp] = a + b
		}

		if memory[ip] == opMul {
			memory[rp] = a * b
		}

		if memory[ip] == opHalt {
			break
		}

		ip = ip + 4
	}

	return memory[0]
}

var memory = programMemory
memory[1] = 12
memory[2] = 2

print("1. ", runProgram1(programMemory: memory))

func runProgram2(programMemory: [Int], stopper: Int) -> Int {
	for noun in 0...99 {
		for verb in 0...99 {
			var memory = programMemory
			memory[1] = noun
			memory[2] = verb
			let result = runProgram1(programMemory: memory)
			if result == stopper {
				return 100 * noun + verb
			}
		}
	}
	return -1
}

// 19690720

print("2. ", runProgram2(programMemory: programMemory, stopper: 19690720))
