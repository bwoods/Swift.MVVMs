import UIKit


class SQLiteTableViewDatasource: SQLiteQuery, UITableViewDataSource {
	override var array: [[String : NSObject]] {
		didSet {
			if let tableView = self.owner as? UITableView {
				if oldValue.count == 0 {
					tableView.reloadData() // don't animate in the initial elements
				} else {
					tableView.animateRowChanges(oldData: oldValue, newData: self.array)
				}
			}
		}
	}

// MARK: - UITableViewDataSource methods
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
		if cell.textLabel != nil {
			cell.textLabel?.tag = 1
			cell.detailTextLabel?.tag = 2
			cell.imageView?.tag = 3
		}

		self.fill(cell.contentView, with: self[indexPath.row])
		return cell
	}

}


