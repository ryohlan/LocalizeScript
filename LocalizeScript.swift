import Cocoa

let arguments = Array((Process.arguments[1..<Process.arguments.count]))

if arguments.count != 2 {
  print("error.")
  exit(0)
}

let filePath = arguments[0]
let saveDir = arguments[1]

let data = NSData(contentsOfFile: filePath)
if let fileData = data {
    let content = NSString(data: fileData, encoding:NSUTF8StringEncoding) as! String
    var isCommentLine = false
    var newContent = ""
    content.enumerateLines { line, bool in
      if line.hasPrefix("/*") {
        isCommentLine = true
      }

      if isCommentLine {
        if line.hasSuffix("*/"){
          isCommentLine = false
        }
        return
      }

      if line.hasPrefix("//") { return }

      var key = line.componentsSeparatedByString("\"").filter { !$0.isEmpty }.first
      if var key =  key {
        newContent.appendContentsOf(
          "static var \(key): String { return NSLocalizedString(\"\(key)\", comment: \"\(key)\") }\n"
        )
      }
    }
    newContent = "import Foundation\n\nstruct LocalizedString {\n\(newContent)\n}"
    do {
    	try newContent.writeToFile(saveDir + "/LocalizedString.swift", atomically: false, encoding: NSUTF8StringEncoding)
      print("Completed.")
    } catch {
    	print(error)
    }
}
