import UIKit


class SearchResultsTableViewUpdater: NSObject, SearchControllerUpdater {
	@IBOutlet var updaters: [TableViewSectionUpdater] = [ ] {
		willSet { newValue.forEach { $0.updatee = tableView } }
	}

	weak var tableView: UITableView? {
		didSet {
			tableView?.rowHeight = UITableViewAutomaticDimension
			tableView?.estimatedRowHeight = 44

			let updaters = self.updaters
			self.updaters = updaters // trigger willSet
		}
	}

	var searchTerms: String = "" {
		didSet { updaters.forEach { $0.update(with: searchTerms as AnyObject) } }
	}

// MARK: - UISearchResultsUpdating methods
	func updateSearchResults(for searchController: UISearchController) {
		searchTerms = searchController.searchBar.text ?? ""
	}


// MARK: - UITableViewDataSource methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return updaters.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return updaters[section].tableView(tableView, numberOfRowsInSection: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return updaters[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
	}

}



