//
//  main.swift
//  AOC2019_14
//
//  Created by Lubomír Kaštovský on 14/12/2019.
//  Copyright © 2019 Lubomír Kaštovský. All rights reserved.
//

import Foundation

struct Chemical: Hashable {
    var name: String
    var amount: Int

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

typealias ChemicalSet = Set<Chemical>

struct Reaction {
    var output: Chemical
    var input: ChemicalSet
}

typealias ReactionList = [Reaction]

func insertToSet(chemical: Chemical, set: inout ChemicalSet) {
    if let chem = set.first(where: { $0.name == chemical.name }) {
        set.remove(chem)
        set.insert(Chemical(name: chemical.name, amount: chemical.amount + chem.amount))
    } else {
        set.insert(chemical)
    }
}

func parseInput(input: [String]) -> ReactionList {
    var result: ReactionList = ReactionList()
    input.forEach { line in
        let parts = line.components(separatedBy: ["=", ">"])
        let inputChems = parts[0].components(separatedBy: [",", " "])
        let outputChem = parts[2].components(separatedBy: [" "])

        var index = 0
        var inChems: ChemicalSet = ChemicalSet()
        while index < inputChems.count {
            let chem = Chemical(name: inputChems[index + 1], amount: Int(inputChems[index])!)
            insertToSet(chemical: chem, set: &inChems)
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

func chemicalToString(_ chem: Chemical) -> String {
    return "[" + chem.name + ", " + String(chem.amount) + "]"
}

func chemicalListToString(_ chems: ChemicalSet) -> String {
    guard !chems.isEmpty else {
        return "{ }"
    }
    var result = ""
    for chem in chems {
        if result.isEmpty {
            result += "{ "
        } else {
            result += ", "
        }
        result += chemicalToString(chem)
    }
    result += " }"
    return result
}

func hasOnlyInputChem(inputChem: String, reaction: Reaction) -> Bool {
    return reaction.input.allSatisfy {
        inputChem == $0.name
    }
}

func replacementFor(chemical: Chemical, reactions: ReactionList) -> (amountOfReplacedProduced: Int, ChemicalSet) {
    for reaction in reactions {
        if reaction.output.name == chemical.name {
            return (reaction.output.amount, reaction.input)
        }
    }
    return (amountOfReplacedProduced: 0, ChemicalSet())
}

/*
 10 ORE => 10 A
 1 ORE => 1 B
 7 A, 1 B => 1 C
 7 A, 1 C => 1 D
 7 A, 1 D => 1 E
 7 A, 1 E => 1 FUEL
 */

func expandReactions(reactions: ReactionList, lefts: ChemicalSet, fuelAmount: Int)
    -> (fuelReaction: Reaction, leftovers: ChemicalSet) {
    var fuelIndex = 0
    for reaction in reactions {
        if reaction.output.name == "FUEL" {
            break
        }
        fuelIndex += 1
    }
    var result = reactions[fuelIndex]
    var set: ChemicalSet = ChemicalSet()
    while !result.input.isEmpty {
        if let chem = result.input.first {
            let newAmount = chem.amount * fuelAmount
            set.insert(Chemical(name: chem.name, amount: newAmount))
            result.input.removeFirst()
        }
    }
    result.input = set
    var leftovers = lefts
    var usedLeftovers = false
    while !hasOnlyInputChem(inputChem: "ORE", reaction: result) {
        while let rpChem = result.input.first(where: { $0.name != "ORE" }) {
            var replacedChem = rpChem
            result.input.remove(rpChem)
            // check if can be satisfied by leftovers
            if let leftover = leftovers.first(where: { $0.name == replacedChem.name }) {
                if leftover.amount > replacedChem.amount {
                    leftovers.remove(leftover)
                    leftovers.insert(Chemical(name: leftover.name, amount: leftover.amount - replacedChem.amount))
                    usedLeftovers = true
                } else if leftover.amount == replacedChem.amount {
                    leftovers.remove(leftover)
                    usedLeftovers = true
                } else {
                    replacedChem.amount -= leftover.amount
                    leftovers.remove(leftover)
                    // just reduced amount, not replaced completely by leftover, so continue replacing
                    // usedLeftovers stays false
                }
            }

            if !usedLeftovers {
                let replacements = replacementFor(chemical: replacedChem, reactions: reactions)
                let plus = replacedChem.amount % replacements.amountOfReplacedProduced != 0 ? 1 : 0
                var replacementChemicals = replacements.1
                while !replacementChemicals.isEmpty {
                    if let replacement = replacementChemicals.first {
                        let newAmount = ((replacedChem.amount / replacements.amountOfReplacedProduced) + plus) * replacement.amount
                        insertToSet(chemical: Chemical(name: replacement.name, amount: newAmount), set: &result.input)
                        replacementChemicals.removeFirst()
                    }
                }
                if plus == 1 {
                    let leftoverAmount =
                        ((replacedChem.amount / replacements.amountOfReplacedProduced) + plus) * replacements.amountOfReplacedProduced - replacedChem.amount
                    insertToSet(chemical: Chemical(name: replacedChem.name, amount: leftoverAmount), set: &leftovers)
                }
            }
            usedLeftovers = false
        }
    }
    return (fuelReaction: result, leftovers: leftovers)
}

func produceFuel(reactions: ReactionList, ore: Int) -> Int {
    let leftovers: ChemicalSet = ChemicalSet()
    var upperFuelAmount = 1_000_000_000
    var lowerFuelAmount = 0
    var fuelAmount = ((upperFuelAmount - lowerFuelAmount) / 2) + lowerFuelAmount
    while true {
        let fuel = expandReactions(reactions: reactions, lefts: leftovers, fuelAmount: fuelAmount)
        if let neededOre = fuel.fuelReaction.input.first?.amount {
            if neededOre < ore {
                lowerFuelAmount = fuelAmount
            } else if neededOre > ore {
                upperFuelAmount = fuelAmount
            }
            fuelAmount = ((upperFuelAmount - lowerFuelAmount) / 2) + lowerFuelAmount
            if fuelAmount == upperFuelAmount || fuelAmount == lowerFuelAmount {
                break
            }
        }
    }
    return fuelAmount
}

let input = readLinesRemoveEmpty(str: inputString)
let reactions = parseInput(input: input)
let result = expandReactions(reactions: reactions, lefts: ChemicalSet(), fuelAmount: 1)
print("Part 1: ", result.fuelReaction.input.first?.amount ?? -1)
print("Part 2: ", produceFuel(reactions: reactions, ore: 1_000_000_000_000))
