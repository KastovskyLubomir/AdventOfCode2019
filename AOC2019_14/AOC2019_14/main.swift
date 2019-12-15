//
//  main.swift
//  AOC2019_14
//
//  Created by Lubomír Kaštovský on 14/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

//print(input)

struct Chemical: Equatable {
    var name: String
    var amount: Int

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name && lhs.amount == rhs.amount
    }
}

typealias ChemicalList = LinkedList<Chemical>

struct Reaction {
    var output: Chemical
    var input: ChemicalList
}

typealias ReactionList = [Reaction]

func parseInput(input: [String]) -> ReactionList {
    var result: ReactionList = ReactionList()
    input.forEach { line in
        let parts = line.components(separatedBy: ["=", ">"])
        let inputChems = parts[0].components(separatedBy: [",", " "])
        let outputChem = parts[2].components(separatedBy: [" "])

        var index = 0
        let inChems: ChemicalList = ChemicalList()
        while index < inputChems.count {
            let chem = Chemical(name: inputChems[index+1], amount: Int(inputChems[index])!)
            inChems.appendLast(value: chem)
            index += 3
        }
        result.append(
            Reaction(
                output: Chemical(name: outputChem[2], amount: Int(outputChem[1])!),
                input: inChems
            )
        )
    }
    return result
}

//print(parseInput(input: input))

func chemicalToString(_ chem: Chemical) -> String {
    return "[" + chem.name + ", " + String(chem.amount) + "]"
}

func chemicalListToString(_ chems: ChemicalList) -> String {
    guard chems.count != 0 else {
        return "{ }"
    }
    var result = ""
    chems.actualToFirst()
    for _ in 0..<chems.count {
        if result.isEmpty {
            result += "{ "
        } else {
            result += ", "
        }
        result += chemicalToString(chems.actual!.value!)
        chems.moveToRight(shift: 1)
    }
    result += " }"
    return result
}

func hasOnlyInputChem(inputChem: String, reaction: Reaction) -> Bool {
    reaction.input.actualToFirst()
    for _ in 0..<reaction.input.count {
        if inputChem != reaction.input.actual!.value!.name {
            return false
        }
    }
    return true
}

func replacementFor(chemical: Chemical, reactions: ReactionList) -> (amountOfReplacedProduced: Int, ChemicalList) {
    for reaction in reactions {
        if reaction.output.name == chemical.name {
            return (reaction.output.amount, reaction.input)
        }
    }
    return (amountOfReplacedProduced: 0, ChemicalList())
}

func combineSameChemicals(chemicals: ChemicalList) -> ChemicalList {
    let chems = chemicals
    chems.actualToFirst()
    let result: ChemicalList = ChemicalList()
    let i = 0
    while i < chems.count {
        var chem = chems.actual!.value!
        chems.removeActual()
        chems.actualToFirst()
        var j = 0
        while j < chems.count {
            if chems.actual!.value!.name == chem.name {
                chem.amount += chems.actual!.value!.amount
                chems.removeActual()
                chems.actualToFirst()
                j = 0
            } else {
                j += 1
                chems.moveToRight(shift: 1)
            }
        }
        result.appendLast(value: chem)
    }
    return result
}

/*
 10 ORE => 10 A
 1 ORE => 1 B
 7 A, 1 B => 1 C
 7 A, 1 C => 1 D
 7 A, 1 D => 1 E
 7 A, 1 E => 1 FUEL
 */

func expandReactions(reactions: ReactionList, lefts: ChemicalList)
    -> (fuelReaction: Reaction, leftovers: ChemicalList) {
    // find fuel
    var fuelIndex = 0
    for reaction in reactions {
        if reaction.output.name == "FUEL" {
            break
        }
        fuelIndex += 1
    }
    var result = reactions[fuelIndex]
    var leftovers = lefts
    var usedLeftovers = false

    while !hasOnlyInputChem(inputChem: "ORE", reaction: result) {
        var i = 0
        while i < result.input.count {
            //print("input: ", chemicalListToString(result.input))
            //print("leftovers: ", chemicalListToString(leftovers))

            result.input.actualToFirst()
            if result.input.actual!.value!.name != "ORE" {
                var replacedChem = result.input.actual!.value!
                result.input.removeActual()
                // check if can be satisfied by leftovers

                var j = 0
                while j < leftovers.count {
                    if leftovers[j].name == replacedChem.name {
                        if leftovers[j].amount > replacedChem.amount {
                            leftovers[j].amount -= replacedChem.amount
                            usedLeftovers = true
                        } else if leftovers[j].amount == replacedChem.amount {
                            leftovers.remove(at: j)
                            usedLeftovers = true
                        } else {
                            replacedChem.amount -= leftovers[j].amount
                            leftovers.remove(at: j)
                            // just reduced amount, not replaced completely by leftover, so continue replacing
                            // usedLeftovers stays false
                        }
                        break
                    }
                    j += 1
                }

                if !usedLeftovers {
                    let replacements = replacementFor(chemical: replacedChem, reactions: reactions)
                    let plus = replacedChem.amount % replacements.amountOfReplacedProduced != 0 ? 1 : 0
                    for replacement in replacements.1 {
                        let newAmount = ((replacedChem.amount / replacements.amountOfReplacedProduced) + plus ) * replacement.amount
                        result.input.append(Chemical(name: replacement.name, amount: newAmount))
                    }
                    if plus == 1 {
                        let leftoverAmount =
                            ((replacedChem.amount / replacements.amountOfReplacedProduced) + plus ) * replacements.amountOfReplacedProduced - replacedChem.amount
                        leftovers.append(Chemical(name: replacedChem.name, amount: leftoverAmount))
                    }
                }

                usedLeftovers = false
                i = 0
            } else {
                i += 1
            }
            //print("before combine")
            //print("input: ", chemicalListToString(result.input))
            //print("leftovers: ", chemicalListToString(leftovers))
            result.input = combineSameChemicals(chemicals: result.input)
            leftovers = combineSameChemicals(chemicals: leftovers)

            //print("")
        }
    }
    return (fuelReaction: result, leftovers: leftovers)
}

let input = readLinesRemoveEmpty(str: inputString)
//print(input)
let reactions = parseInput(input: input)
//print(expandReactions(reactions: reactions))
print(expandReactions(reactions: reactions, lefts: []).fuelReaction.input.reduce(0, {sum, chem in
    return sum + chem.amount
}))

func produceFuel(reactions: [Reaction]) -> Int {

    var hashes: Set<String> = []
    var leftovers: [Chemical] = []
    var counter = 0
    while true {
        let oneFuel = expandReactions(reactions: reactions, lefts: leftovers)
        leftovers = oneFuel.leftovers
        counter += 1
        let hash = chemicalListToString(leftovers)
        print(counter)
        if hashes.contains(hash) {
            return counter
        } else {
            hashes.insert(hash)
        }
    }

    return 0
}

print(produceFuel(reactions: reactions))
*/
