//
//  main.swift
//  AOC2019_08
//
//  Created by Lubomir Kastovsky on 08/12/2019.
//  Copyright © 2019 Lubomir Kastovsky. All rights reserved.
//

import Foundation


let input = readLinesRemoveEmpty(str: inputString)

struct Layer {
	var id: Int
	var data: [[Int]]
	var width: Int
	var height: Int
}

func createLayers(input: String, layerWidth: Int, layerHeight: Int) -> [Layer] {
	var result: [Layer] = []
	let ints = input.map { Int(String($0)) }
	var layerId = 0
	var index = 0
	while index < ints.count {
		var newLayer = Layer(id: layerId, data: [], width: layerWidth, height: layerHeight)
		for _ in 0..<layerHeight {
			var row: [Int] = []
			for _ in 0..<layerWidth {
				row.append(ints[index] ?? -1)
				index += 1
			}
			newLayer.data.append(row)
		}
		result.append(newLayer)
		layerId += 1
	}
	return result
}

func numberOfItem(item: Int, layer: Layer) -> Int {
	var sum = 0
	for row in 0..<layer.height {
		for col in 0..<layer.width {
			if layer.data[row][col] == item {
				sum += 1
			}
		}
	}
	return sum
}

let layers = createLayers(input: input[0], layerWidth: 25, layerHeight: 6)

func checkSum(layers: [Layer]) -> Int {
	var zeros = Int.max
	var check = 0
	for layer in layers {
		let z = numberOfItem(item: 0, layer: layer)
		if z < zeros {
			zeros = z
			let ones = numberOfItem(item: 1, layer: layer)
			let twos = numberOfItem(item: 2, layer: layer)
			check = ones * twos
		}
	}
	return check
}

print("1. ", checkSum(layers: layers))

func applyLayers(layers: [Layer]) -> [[Int]] {
	var result: [[Int]] = []
	for _ in 0..<layers[0].height {
		var row = [Int].init(repeating: 2, count: layers[0].width)
		result.append(row)
	}
	for i in 0...layers.count-1 {
		let layerIndex = (layers.count-1) - i
		let layer = layers[layerIndex]
		for row in 0..<layer.height {
			for col in 0..<layer.width {
				if layer.data[row][col] != 2 {
					result[row][col] = layer.data[row][col]
				}
			}
		}
	}

	return result
}

func printImage(data: [[Int]]) {

	for row in 0..<data.count {
		var str = ""
		for col in 0..<data[row].count {
			if data[row][col] == 0 {
				str += "X"
			} else {
				str += " "
			}
		}
		print(str)
	}

}

let image = applyLayers(layers: layers)
printImage(data: image)
