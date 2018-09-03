import UIKit


@IBDesignable
class SearchControllerNavigationItem: UINavigationItem, UISearchBarDelegate {
	@IBInspectable var alwaysShowSearchBar: Bool = false {
		didSet { self.hidesSearchBarWhenScrolling = !alwaysShowSearchBar }
	}

	@IBOutlet var inputAccessoryView: UIView? {
		didSet { self.searchController?.searchBar.inputAccessoryView = inputAccessoryView }
	}

	@IBOutlet var searchControllerDelegate: UISearchControllerDelegate? {
		didSet { self.searchController?.delegate = searchControllerDelegate }
	}

	@IBInspectable var placeholder: String? {
		didSet { self.searchController?.searchBar.placeholder = placeholder }
	}

	@IBOutlet var searchResultsUpdater: SearchControllerUpdater? {
		didSet {
			let tableViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "Search Results") as! UITableViewController
			self.searchController = UISearchController(searchResultsController: tableViewController)
			
			self.searchController!.definesPresentationContext = true
			// definesPresentationContext = true must ALSO be set on this item’s UIVIewController or the tableView will cover it

			self.searchController!.searchBar.inputAccessoryView = inputAccessoryView
			self.searchController!.searchBar.placeholder = placeholder
			self.searchController!.delegate = searchControllerDelegate
			self.hidesSearchBarWhenScrolling = !alwaysShowSearchBar

			self.largeTitleDisplayMode = .always
			self.searchController!.searchBar.delegate = self // for largeTitleDisplayMode handling

			self.searchController!.hidesNavigationBarDuringPresentation = false
			self.searchController!.obscuresBackgroundDuringPresentation = false
			self.searchController!.searchBar.autocapitalizationType = .none
			self.searchController!.searchBar.autocorrectionType = .no
			self.searchController!.searchBar.keyboardType = .twitter // .url has no space bar
			self.searchController!.searchBar.showsCancelButton = false // searchController handles Cancel

			self.searchController!.searchResultsUpdater = searchResultsUpdater
			tableViewController.tableView.dataSource = searchResultsUpdater
			tableViewController.tableView.delegate = searchResultsUpdater
			tableViewController.tableView.keyboardDismissMode = .onDrag
			searchResultsUpdater?.tableView = tableViewController.tableView
		}
	}

// MARK: - UISearchBarDelegate methods
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		largeTitleDisplayMode = .never
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		largeTitleDisplayMode = .always
	}

}


@objc protocol SearchControllerUpdater : UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
	var tableView: UITableView! { get set } // implicit to match UITableViewController; just in case…
}


