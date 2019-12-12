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
    var x: Int
    var y: Int
	var z: Int

	var velx: Int
	var vely: Int
	var velz: Int

    static func == (lhs: Planet, rhs: Planet) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
		hasher.combine(z)
    }
}

func loadPlanets(positions: [String]) -> [Planet] {
	return positions.map { pos in
		let parts = pos.components(separatedBy: ["<","=",","," ", ">"])
		print(parts)
		return Planet(x: Int(parts[2])!, y: Int(parts[5])!, z: Int(parts[8])!, velx: 0, vely: 0, velz: 0)
	}
}

func updateVelocity(planets: inout [Planet]) {
    for i in 0..<planets.count {
        for j in 0..<planets.count {
            if i != j {
                if planets[i].x < planets[j].x {
                    planets[i].velx += 1
                } else if planets[i].x > planets[j].x {
                    planets[i].velx -= 1
                }
                if planets[i].y < planets[j].y {
                    planets[i].vely += 1
                } else if planets[i].y > planets[j].y {
                    planets[i].vely -= 1
                }
                if planets[i].z < planets[j].z {
                    planets[i].velz += 1
                } else if planets[i].z > planets[j].z {
                    planets[i].velz -= 1
                }
            }
        }
	}
}

func updatePosition(planets: inout [Planet]) {
    for i in 0..<planets.count {
        planets[i].x += planets[i].velx
        planets[i].y += planets[i].vely
        planets[i].z += planets[i].velz
    }
}

func totalEnergy(planets: [Planet]) -> Int {
    var total = 0
    for i in 0..<planets.count {
        let potential = abs(planets[i].x) + abs(planets[i].y) + abs(planets[i].z)
        let kinetic = abs(planets[i].velx) + abs(planets[i].vely) + abs(planets[i].velz)
        total += (potential * kinetic)
    }
    return total
}

func runSimulation(planets: [Planet], cycles: Int) -> Int {
    var moons = planets
    for i in 0..<cycles {
        updateVelocity(planets: &moons)
        updatePosition(planets: &moons)
    }
    print(moons)
    return totalEnergy(planets: moons)
}

let planets = loadPlanets(positions: input)
print(runSimulation(planets: planets, cycles: 1000))

func planetsSame(a: Planet, b: Planet) -> Bool {
    return a.x == b.x && a.y == b.y && a.z == b.z && a.velx == b.velx && a.vely == b.vely && a.velz == b.velz
}

func PlanetToString(planet: Planet) -> String {
    let position = String(planet.x) + "," + String(planet.y) + "," + String(planet.z)
    let velocity = "," + String(planet.velx) + "," + String(planet.vely) + "," + String(planet.velz)
    return position + velocity
}

func runSimulation1(planets: [Planet], cycles: Int) -> Int {
    var moons = planets
    let first = planets[0]
    var states: Set<String> = []
    var counter = 0
    while true {
        updateVelocity(planets: &moons)
        updatePosition(planets: &moons)
        counter += 1
        states.insert()
    }
}

print(runSimulation1(planets: planets, cycles: 1000))

