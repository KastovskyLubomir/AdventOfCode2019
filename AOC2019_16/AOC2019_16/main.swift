//
//  main.swift
//  AOC2019_16
//
//  Created by Lubomir Kastovsky on 18/12/2019.
//  Copyright © 2019 Lubomir Kastovsky. All rights reserved.
//

import Foundation

let basePattern = [0,1,0,-1]

func generateBasePatterns(basePattern: [Int], length: Int) -> [[Int]] {
	var result: [[Int]] = []
	for i in 0..<length {
		let repeatCount = i + 1
		var repeatCounter = 0
		var resultPattern: [Int] = [Int].init(repeating: 0, count: length)
		var basePatternIndex = 0
		for j in 0...length {
			if repeatCounter == repeatCount {
				repeatCounter = 0
				basePatternIndex += 1
			}
			repeatCounter += 1
			if basePatternIndex == basePattern.count {
				basePatternIndex = 0
			}
			if j != 0 {
				resultPattern[j-1] = basePattern[basePatternIndex]
			}
		}
		if let index = resultPattern.firstIndex(of: basePattern[1]) {
			resultPattern.removeFirst(index)
		}
		result.append(resultPattern)
	}
	return result
}

func transformation(offset: Int, pattern: inout [Int], numbers: inout [Int]) -> Int {
	var sum = 0
	for i in offset..<numbers.count {
		sum += pattern[i-offset] * numbers[i]
	}
	return abs(sum) % 10
}

func transformNumbers(patterns: inout [[Int]], numbers: inout [Int]) {
	var tmp = numbers
	for i in 0..<tmp.count {
		let x = transformation(offset: i, pattern: &patterns[i], numbers: &tmp)
		numbers[i] = x
	}
}

func repeatTransformation(times: Int, patterns: inout [[Int]], numbers: inout [Int]) {
	for _ in 0..<times {
		transformNumbers(patterns: &patterns, numbers: &numbers)
	}
}

/*
	without generating patterns
*/

// TODO: solve starting one left offset
func transformation2(basePattern: [Int], numbers: inout [Int], jump: Int, returnSum: Bool) -> Int {
	var numbersIndex = -1
	var basePatternIndex = 0
	var sum = 0
	var sequenceConter = 0
	while numbersIndex < numbers.count {
		if basePattern[basePatternIndex] == 0 {
			numbersIndex += jump
			basePatternIndex += 1
		} else {
			sum += basePattern[basePatternIndex] * numbers[numbersIndex]
			numbersIndex += 1
			sequenceConter += 1
		}
		if sequenceConter == jump {
			sequenceConter = 0
			basePatternIndex += 1
			if basePatternIndex == basePattern.count {
				basePatternIndex = 0
			}
		}
	}
	//print(sum)
	if returnSum {
		return abs(sum)
	} else {
		return abs(sum) % 10
	}
}

func transformNumbers2(basePattern: [Int], numbers: inout [Int]) {
	var tmp = numbers
	for i in 0..<tmp.count {
		let x = transformation2(basePattern: basePattern, numbers: &tmp, jump: i+1, returnSum: false)
		numbers[i] = x
		//print(i)
	}
}

func transformNumbers3(basePattern: [Int], numbers: inout [Int]) {
	var tmp = numbers
	for i in 0..<tmp.count/2 {
		//let start = DispatchTime.now()

		let x = transformation2(basePattern: basePattern, numbers: &tmp, jump: i+1, returnSum: false)
		numbers[i] = x

		//let end = DispatchTime.now()
		//let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
		//let timeInterval = Double(nanoTime) / 1_000_000_000
		//print("trans:", i, "duration:", timeInterval)
	}
	let i = tmp.count/2
	var sum = transformation2(basePattern: basePattern, numbers: &tmp, jump: i+1, returnSum: true)
	numbers[i] = sum % 10
	//print(sum)
	for j in i+1..<tmp.count {
		sum = sum - tmp[j-1]
		numbers[j] = sum % 10
		//print(sum)
	}
}

func repeatTransformation2(times: Int, basePattern: [Int], numbers: inout [Int]) {
	for i in 1...times {
		let start = DispatchTime.now()
		transformNumbers3(basePattern: basePattern, numbers: &numbers)
		let end = DispatchTime.now()
		let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
		let timeInterval = Double(nanoTime) / 1_000_000_000
		print("--->", i, "duration:", timeInterval)
	}
}

/*
	common methods
*/

func generateLongMessage(numbers: [Int], repeating: Int) -> [Int] {
	var result: [Int] = []
	for _ in 0..<repeating {
		result.append(contentsOf: numbers)
	}
	return result
}

func getResultOffset(numbers: inout [Int], length: Int) -> Int {
	var result = 0
	for i in 0..<length {
		result = (result * 10) + numbers[i]
	}
	return result
}

func getMessage(numbers: inout [Int], offset: Int, length: Int) -> [Int] {
	var result: [Int] = []
	for i in offset..<offset + length {
		result.append(numbers[i])
	}
	return result
}

let test = 1

if test == 0 {
	// Part 1
	let input = readLinesRemoveEmpty(str: inputString)
	let numbers = input[0].map { Int(String($0))! }
	var nums = numbers
	//var patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: numbers.count)
	//repeatTransformation(times: 100, patterns: &patterns, numbers: &nums)
	repeatTransformation2(times: 100, basePattern: basePattern, numbers: &nums)
	print(nums)

	// Part 2
	let manyNumbers = generateLongMessage(numbers: numbers, repeating: 10000)
	nums = manyNumbers
	//patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: nums.count)
	repeatTransformation2(times: 100, basePattern: basePattern, numbers: &nums)

} else {
	//let input = "12345678"
	//let input = "80871224585914546619083218645595"
	let input = "03036732577212944063491565474664"
	let numbers = input.map { Int(String($0))! }
	print(numbers)
	//var patterns = generateBasePatterns(basePattern: basePattern, length: numbers.count)
	var nums = numbers
	//print(patterns)
	repeatTransformation2(times: 4, basePattern: basePattern, numbers: &nums)
	print(nums)

	var manyNumbers = generateLongMessage(numbers: numbers, repeating: 10000)
	let messageOffset = getResultOffset(numbers: &manyNumbers, length: 7)
	print(messageOffset)
	nums = manyNumbers
	//patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: nums.count)
	repeatTransformation2(times: 100, basePattern: basePattern, numbers: &nums)
	print(getMessage(numbers: &nums, offset: messageOffset, length: 8))

}


