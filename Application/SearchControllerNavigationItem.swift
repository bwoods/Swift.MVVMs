import UIKit


@IBDesignable
class SearchControllerNavigationItem: UINavigationItem {
	@IBOutlet var inputAccessoryView: UIView! {
		get { return self.searchController!.searchBar.inputAccessoryView }
		set { self.searchController!.searchBar.inputAccessoryView = newValue }
	}

	@IBOutlet var searchControllerDelegate: UISearchControllerDelegate? {
		get { return self.searchController!.delegate }
		set { self.searchController!.delegate = newValue }
	}

	@IBOutlet var searchBarDelegate: UISearchBarDelegate? {
		get { return self.searchController!.searchBar.delegate }
		set { self.searchController!.searchBar.delegate = newValue }
	}

	@IBOutlet var searchResultsUpdater: UISearchResultsUpdater?
	
	@IBInspectable var alwaysShowSearchBar: Bool {
		get { return !self.hidesSearchBarWhenScrolling }
		set { self.hidesSearchBarWhenScrolling = !newValue }
	}

	@IBInspectable var placeholder: String? {
		get { return self.searchController!.searchBar.placeholder }
		set { self.searchController!.searchBar.placeholder = newValue }
	}

// MARK: -
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		let tableViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "Search Results") as! UITableViewController
		self.searchController = UISearchController(searchResultsController: tableViewController)
		self.searchController!.definesPresentationContext = true

		self.searchController!.hidesNavigationBarDuringPresentation = false
		self.searchController!.obscuresBackgroundDuringPresentation = false
//		self.searchController!.searchBar.searchBarStyle = .minimal
		self.searchController!.searchBar.autocapitalizationType = .none
		self.searchController!.searchBar.autocorrectionType = .no
		self.searchController!.searchBar.keyboardType = .webSearch // .URL has no space bar
		self.searchController!.searchBar.returnKeyType = .done
		self.searchController!.searchBar.showsCancelButton = false // searchController handles Cancel
		self.searchController!.searchResultsUpdater = searchResultsUpdater

		tableViewController.tableView.dataSource = searchResultsUpdater
		tableViewController.tableView.delegate = searchResultsUpdater
		searchResultsUpdater?.tableView = tableViewController.tableView
	}

}


@objc protocol UISearchResultsUpdater : UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
	var tableView: UITableView! { get set } // implicit to match UITableViewController; just in case…
}


