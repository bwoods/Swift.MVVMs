import UIKit


@IBDesignable
class SQLiteSectionedTableViewDatasource: NSObject, UITableViewDataSource {
	var sections = [SQLiteTableViewDatasource]() {
		didSet { reloadData() }
	}

	@IBOutlet var owner: NSObject! {
		didSet {
			sections.forEach { section in
				section.owner = owner
			}

			reloadData()
		}
	}

	@IBInspectable
	var tables: String = "" { // comma seperated list of tables/views
		didSet {
			var sections = [SQLiteTableViewDatasource]()

			tables.split(separator: ",").forEach { query in
				let section = SQLiteTableViewDatasource()
				section.owner = owner
				section.query = query.trimmingCharacters(in: .whitespaces)
				sections.append(section)
			}

			self.sections = sections
		}
	}

	func reloadData() {
//		(owner as? UITableView)?.reloadData()
	}

// MARK: - UITableViewDataSource methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

//	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return tables[section]
//	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].tableView(tableView, numberOfRowsInSection: 0)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return sections[indexPath.section].tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row, section: 0))
	}
}


