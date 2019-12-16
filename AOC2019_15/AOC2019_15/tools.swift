
import Foundation

func readLinesRemoveEmpty(str: String) -> [String] {
    var x = str.components(separatedBy: ["\n"])
    for i in x.indices {
        if x[i].isEmpty {
            x.remove(at: i)
        }
    }
    return x
}

// input: "Jack,Bob,Frank"
func stringWordArrayToArrayOfWords(input: String, separators: CharacterSet) -> [String] {
    var result = [String]()
    let lenArrStr = input.components(separatedBy: separators)
    for s in lenArrStr {
        if !s.isEmpty {
            result.append(s)
        }
    }
    return result
}

// input: "1,2,3,4,5"
func stringNumArrayToArrayOfInt(input: String, separators: CharacterSet) -> [Int] {
    let strArray = input.components(separatedBy: separators)
    return strArray.compactMap { Int($0) }
}

// input: "1","2","3"
func strArrayToIntArray(strArray: [String]) -> [Int] {
    return strArray.compactMap { Int($0) }
}

func getStringBytes(str: String) -> [UInt8] {
    let buf1 = [UInt8](str.utf8)
    return buf1
}

let fileManager = FileManager.default
let fileDir: String = fileManager.currentDirectoryPath
let filePath: String = fileDir.appending("/../input.txt")
let data = fileManager.contents(atPath: filePath)
let inputString: String = String(data: data!, encoding: String.Encoding.utf8)!
