//
//  main.swift
//  AOC2019_06
//
//  Created by Lubomír Kaštovský on 07/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

let input = readLinesRemoveEmpty(str: inputString)


struct Planet: Any {
    var name: String
    var orbiting: Int
    var orbiters: [Planet]
}

func findOrbiters(planetName: String, orbiting: Int, input: [String]) -> Planet {
    var root = Planet(name: planetName, orbiting: orbiting, orbiters: [])
    for str in input {
        let pair = str.components(separatedBy: [")"])
        if pair[0] == planetName {
            root.orbiters.append(findOrbiters(planetName: pair[1], orbiting: orbiting + 1, input: input))
        }
    }
    return root
}

let map = findOrbiters(planetName: "COM", orbiting: 0, input: input)
//print(map)

func orbitersSum(planet: Planet) -> Int {
    var sum = planet.orbiting
    if !planet.orbiters.isEmpty {
        for orbiter in planet.orbiters {
            sum += orbitersSum(planet: orbiter)
        }
    }
    return sum
}

print("1. ", orbitersSum(planet: map))

func pathToPlanet(planetName: String, planet: Planet) -> (Bool, [String]) {
    if planet.name == planetName {
        return (true, [])
    } else {
        for orbiter in planet.orbiters {
            let result = pathToPlanet(planetName: planetName, planet: orbiter)
            if result.0 {
                var path: [String] = [orbiter.name]
                path.append(contentsOf: result.1)
                return (true, path)
            }
        }
    }
    return (false, [])
}

let youPath = pathToPlanet(planetName: "YOU", planet: map)
let sanPath = pathToPlanet(planetName: "SAN", planet: map)

func distance(you: [String], san: [String]) -> Int {
    var i = 0
    while (you[i] == san[i]) && i < you.count {
        i += 1
    }
    return (you.count - i) + (san.count - i) - 2
}

//print(youPath)
//print(sanPath)
print("2. ", distance(you: youPath.1, san: sanPath.1))
