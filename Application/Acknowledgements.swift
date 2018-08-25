// env -i swift Application/Acknowledgements.swift > $CODESIGNING_FOLDER_PATH/Settings.bundle/Acknowledgements.plist
import Foundation

let fileManager = FileManager()
let folders = try! fileManager.contentsOfDirectory(atPath: fileManager.currentDirectoryPath)
var specifiers = [[ "Type" : "PSGroupSpecifier", "Title" : "Open Source", "FooterText" : "This application uses the following third party libraries:" ]]

folders.forEach { folder in
	if let path = [ "LICENSE.md", "LICENSE", "COPYING" ].lazy.map({ "\(folder)/\($0)" }).first(where: { fileManager.fileExists(atPath: $0) }) {
		let license = try! String(contentsOfFile: path, encoding: .utf8).replacingOccurrences(of: "(c)", with: "©")
		specifiers.append([ "Type" : "PSGroupSpecifier", "Title" : "", "FooterText" : license ])
		specifiers.append([ "Type" : "PSTitleValueSpecifier", "Title" : folder, "Key" : folder, "DefaultValue" : "" ])
	}
}

let data = try! PropertyListSerialization.data(fromPropertyList: [ "PreferenceSpecifiers" : specifiers ], format: .xml, options: 0)
print(String(data: data, encoding: .utf8)!)
