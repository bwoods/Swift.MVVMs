import UIKit


class SQLiteTableViewDatasource: SQLiteQuery, UITableViewDataSource {

	var tableView: UITableView? {
		return owner as? UITableView
	}

	override var array: [[String : AnyObject]] {
		willSet {
//			(owner as? UITableView)?.animateRowChanges(oldData: super.array, newData: newValue)
		}
	}

	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)

		tableView!.refreshControl = refreshControl // a crash here means self.refreshControl was called a cycle too soon
		return refreshControl
	}()

	@objc override func reloadData() {		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.750) { // give the animation time to re-assure the user that we're doing something
			self.refreshControl.endRefreshing()
		}

		super.reloadData()
		tableView?.reloadData() // TODO: remove once animateRowChanges() is working
	}

// MARK: -
	func fill(view: UIView, with value: [String : AnyObject]) {
		keys.enumerated().forEach { (index, key) in
			let tag = index+1
			view.viewWithTag(tag)?.takeValue(from: value[key]!)
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

		self.fill(view: cell.contentView, with: self[indexPath.row])
		return cell
	}

}


