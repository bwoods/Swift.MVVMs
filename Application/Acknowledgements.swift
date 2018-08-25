// env -i swift Application/Acknowledgements.swift > $CODESIGNING_FOLDER_PATH/Settings.bundle/Acknowledgements.plist
import Foundation

let fileManager = FileManager()
let folders = try! fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath).sorted()
var specifiers = [[ "Type" : "PSGroupSpecifier", "Title" : "Open Source", "FooterText" : "This application uses the following third party libraries:" ]]

folders.forEach { folder in
	if let path = [ "LICENSE.md", "LICENSE", "COPYING" ].lazy.map({ "\(folder)/\($0)" }).first(where: { fileManager.fileExists(atPath: $0) }) {
		var license = (try! String(contentsOfFile: path, encoding: .utf8).replacingOccurrences(of: "(c)", with: "©"))
		
		let regex = try! NSRegularExpression(pattern: "[^\\s]\\n([^\\n])") // remove hard-wrapping if any (\\s repects Markdown trailing spaces)
		license = regex.stringByReplacingMatches(in: license, options:NSRegularExpression.MatchingOptions(rawValue: 0), range:NSMakeRange(0, (license as NSString).length), withTemplate:"$1")

		specifiers.append([ "Type" : "PSGroupSpecifier", "Title" : "", "FooterText" : license ])
		specifiers.append([ "Type" : "PSTitleValueSpecifier", "Title" : folder, "Key" : folder, "DefaultValue" : "" ])
	}
}

let data = try! PropertyListSerialization.data(fromPropertyList: [ "PreferenceSpecifiers" : specifiers ], format: .xml, options: 0)
print(String(data: data, encoding: .utf8)!)
