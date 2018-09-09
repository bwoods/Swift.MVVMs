import UIKit


class SearchResultsTableViewUpdater: NSObject, SearchControllerUpdater {
	@IBOutlet var updaters: [TableViewSectionUpdater] = [ ] {
		willSet { newValue.forEach { $0.updatee = tableView } }
	}

	var searchTerms: String = "" {
		didSet { updaters.forEach { $0.update(with: searchTerms as AnyObject) } }
	}

	weak var tableView: UITableView? {
		didSet {
			tableView?.rowHeight = UITableViewAutomaticDimension
			tableView?.estimatedRowHeight = 44

			let updaters = self.updaters
			self.updaters = updaters // trigger willSet
		}
	}


// MARK: - UISearchResultsUpdating methods
	func updateSearchResults(for searchController: UISearchController) {
		searchTerms = searchController.searchBar.text ?? ""
	}

// MARK: - UITableViewDelegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		return updaters[indexPath.section].tableView(tableView, didSelectRowAt: indexPath)
	}

// MARK: - UITableViewDataSource methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return updaters.count
	}

	 func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return updaters[section].tableView(tableView, titleForHeaderInSection: section)
	}

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return updaters[section].tableView(tableView, numberOfRowsInSection: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return updaters[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
	}

}



