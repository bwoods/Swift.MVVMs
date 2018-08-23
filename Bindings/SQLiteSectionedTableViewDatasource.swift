import UIKit


class SQLiteSectionedTableViewDatasource: SQLiteQuery, UITableViewDataSource {
	@IBInspectable
	var sectionKey: String = ""
	var sectionOffsets = [Int]()

	override var array: [[String : NSObject]] {
		willSet { // split the rows into sections
			var counts = [Int]()
			guard newValue.count > 0 else {
    			return
			}

			var current = newValue.first![sectionKey]!
			newValue.enumerated().forEach { (index, element) in
				if let group = element[sectionKey], group != current {
					counts.append(index)
					current = group
				}
			}

			counts.append(newValue.count) // end the last group
			sectionOffsets = counts
		}
		didSet { // animate the tableView with the inserts/updates/deletes
			if let tableView = self.owner as? UITableView {
				if oldValue.count == 0 {
					tableView.reloadData() // don't animate in the initial elements
				} else {
					tableView.animateRowAndSectionChanges(oldData: oldValue, newData: self.array,
						isEqualSection: { return $0[sectionKey] == $1[sectionKey] },
        				isEqualElement: { return $0 == $1 },
						rowDeletionAnimation: DiffRowAnimation.automatic, rowInsertionAnimation: DiffRowAnimation.automatic,
						sectionDeletionAnimation: DiffRowAnimation.automatic, sectionInsertionAnimation: DiffRowAnimation.automatic,
						indexPathTransform: { indexPath in
							guard indexPath.row >= sectionOffsets.first! else {
								return indexPath
							}

							let section = sectionOffsets.index(where: { index -> Bool in index > indexPath.row })!
							let row = indexPath.row - sectionOffsets[section - 1]
							return IndexPath(row: row, section: section)
						},
        				sectionTransform: { offset in
        					sectionOffsets.index(where: { index -> Bool in index > offset })!
						})
				}
			}
		}
	}

// MARK: - UITableViewDataSource methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionOffsets.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard section > 0 else {
    		return sectionOffsets.first!
		}

		return sectionOffsets[section] - sectionOffsets[section - 1]
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard section > 0 else {
    		return array.first![sectionKey]?.description
		}

		return array[sectionOffsets[section - 1]][sectionKey]?.description
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
		if cell.textLabel != nil {
			cell.textLabel?.tag = 1
			cell.detailTextLabel?.tag = 2
			cell.imageView?.tag = 3
		}

		var indexPath = indexPath
		if indexPath.section > 0 {
			indexPath.row += sectionOffsets[indexPath.section - 1] // flatten indexPath
			indexPath.section = 0
		}

		self.fill(cell.contentView, with: self[indexPath.row])
		return cell
	}

}


