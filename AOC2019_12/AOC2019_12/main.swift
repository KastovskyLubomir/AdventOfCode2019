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
	for planet in planets {
		
	}
}

print(loadPlanets(positions: input))
