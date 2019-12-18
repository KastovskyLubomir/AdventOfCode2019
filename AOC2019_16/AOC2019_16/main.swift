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
// TODO: solve starting one left offset
func transformation2(basePattern: [Int], numbers: inout [Int], jump: Int) -> Int {
	var numbersIndex = 0
	var basePatternIndex = 0
	var sum = 0
	while numbersIndex < numbers.count {
		if basePattern[basePatternIndex] == 0 {
			numbersIndex += jump
		} else {
			sum += basePattern[basePatternIndex] * numbers[numbersIndex]
		}
	}
	return abs(sum) % 10
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
	var patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: numbers.count)
	repeatTransformation(times: 100, patterns: &patterns, numbers: &nums)
	print(nums)

	// Part 2
	let manyNumbers = generateLongMessage(numbers: numbers, repeating: 10000)
	nums = manyNumbers
	patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: nums.count)
	repeatTransformation(times: 100, patterns: &patterns, numbers: &nums)
} else {
	//let input = "12345678"
	//let input = "80871224585914546619083218645595"
	let input = "03036732577212944063491565474664"
	let numbers = input.map { Int(String($0))! }
	print(numbers)
	var patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: numbers.count)
	var nums = numbers
	print(patterns)
	//repeatTransformation(times: 4, patterns: &patterns, numbers: &nums)
	//print(nums)

	var manyNumbers = generateLongMessage(numbers: numbers, repeating: 10000)
	let messageOffset = getResultOffset(numbers: &manyNumbers, length: 7)
	print(messageOffset)
	nums = manyNumbers
	patterns = generateBasePatterns(basePattern: [0,1,0,-1], length: nums.count)
	repeatTransformation(times: 100, patterns: &patterns, numbers: &nums)
	print(getMessage(numbers: &nums, offset: messageOffset, length: 8))
}


