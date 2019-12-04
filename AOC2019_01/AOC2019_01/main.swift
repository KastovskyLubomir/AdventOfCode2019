//
//  main.swift
//  AOC2019_01
//
//  Created by Lubomír Kaštovský on 30/11/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

let input = readLinesRemoveEmpty(str: inputString)
let modules = strArrayToIntArray(strArray: input)

func fuelForMassSum(modules: Array<Int>) -> Int {
	return modules.reduce(0, { result, mass in
		result + ((mass / 3) - 2)
	})
}

print("1. " + String(fuelForMassSum(modules: modules)))

func oneModuleFuel(mass: Int) -> Int {
	var remainigMass = mass
	var fuelSum = 0
	while remainigMass > 0 {
		let fuelMass = (remainigMass / 3) - 2
		if fuelMass > 0 {
			fuelSum += fuelMass
		}
		remainigMass = fuelMass
	}
	return fuelSum
}

func fuelForMassSumIncludingFuelMass(modules: Array<Int>) -> Int {
	return modules.reduce(0, { result, mass in
		result + oneModuleFuel(mass: mass)
	})
}

print("2. " + String(fuelForMassSumIncludingFuelMass(modules: modules)))
