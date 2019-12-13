//
//  main.swift
//  AOC2019_12
//
//  Created by Lubomir Kastovsky on 12/12/2019.
//  Copyright © 2019 Lubomir Kastovsky. All rights reserved.
//

import Foundation

/*
	<x=4, y=12, z=13>
	<x=-9, y=14, z=-3>
	<x=-7, y=-1, z=2>
	<x=-11, y=17, z=-1>
*/

let input = readLinesRemoveEmpty(str: inputString)


struct Planet: Hashable {
    var pos: [Int]
	var vel: [Int]

    static func == (lhs: Planet, rhs: Planet) -> Bool {
		for i in 0..<lhs.pos.count {
			if lhs.pos[i] != rhs.pos[i] || lhs.vel[i] != rhs.vel[i] {
				return false
			}
		}
		return true
    }

    func hash(into hasher: inout Hasher) {
		for i in 0..<pos.count {
			hasher.combine(pos[i])
			hasher.combine(vel[i])
		}
    }
}

func loadPlanets(positions: [String]) -> [Planet] {
	return positions.map { pos in
		let parts = pos.components(separatedBy: ["<","=",","," ", ">"])
		print(parts)
		return Planet(pos:[Int(parts[2])!, Int(parts[5])!, Int(parts[8])!], vel: [0,0,0])
	}
}

func updateVelocity(planets: inout [Planet]) {
    for i in 0..<planets.count {
        for j in 0..<planets.count {
            if i != j {
				for k in 0..<planets[i].pos.count {
					if planets[i].pos[k] < planets[j].pos[k] {
						planets[i].vel[k] += 1
					} else if planets[i].pos[k] > planets[j].pos[k] {
						planets[i].vel[k] -= 1
					}
				}
            }
        }
	}
}

func updatePosition(planets: inout [Planet]) {
    for i in 0..<planets.count {
		for j in 0..<planets[i].pos.count {
			planets[i].pos[j] += planets[i].vel[j]
		}
    }
}

func totalEnergy(planets: [Planet]) -> Int {
    var total = 0
    for i in 0..<planets.count {
		var potential = 0
		var kinetic = 0
		for j in 0..<planets[i].pos.count {
			potential += abs(planets[i].pos[j])
			kinetic += abs(planets[i].vel[j])
		}
        total += (potential * kinetic)
    }
    return total
}

func runSimulation(planets: [Planet], cycles: Int) -> Int {
    var moons = planets
    for _ in 0..<cycles {
        updateVelocity(planets: &moons)
        updatePosition(planets: &moons)
    }
    print(moons)
    return totalEnergy(planets: moons)
}

func getHashFromAxes(axe: Int, planets: [Planet]) -> String {
	var pos = ""
	var vel = "*"
	for i in 0..<planets.count {
		pos += "|" + String(planets[i].pos[axe])
		vel += "|" + String(planets[i].vel[axe])
	}
	return pos + vel
}

func runSimulationInAxes(planets: [Planet], axes: Int, cycles: Int) -> Int {
    var moons = planets
    var counter = 0
	var setOfPositions: [String: Int] = [:]
	while counter < cycles {
        updateVelocity(planets: &moons)
        updatePosition(planets: &moons)
		counter += 1
		let hash = getHashFromAxes(axe: axes, planets: moons)
		if let count = setOfPositions[hash] {
			//print(hash, counter - count)
			return counter - count
		} else {
			setOfPositions[hash] = counter
		}
		if counter == cycles {
			break
		}
    }
	return -1
}

let planets = loadPlanets(positions: input)
print("1. ", runSimulation(planets: planets, cycles: 1000))

//print(runSimulationInAxes(planets: planets, axes: 2, cycles: 10000))
print("2. least common multiplier from: ",
	  runSimulationInAxes(planets: planets, axes: 0, cycles: 1000000),
	  runSimulationInAxes(planets: planets, axes: 1, cycles: 1000000),
	  runSimulationInAxes(planets: planets, axes: 2, cycles: 1000000)
)

// compute least common multiplier from results
