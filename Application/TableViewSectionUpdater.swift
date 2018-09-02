import UIKit


@IBDesignable
class TableViewSectionUpdater: NSObject {
	@IBInspectable var section: Int = 0
	weak var updatee: UITableView?

	func reloadSection(animated: Bool = false) {
		if animated {
			updatee?.reloadSections(IndexSet(integer: section), with: .automatic)
		} else {
			UIView.performWithoutAnimation {
				updatee?.reloadSections(IndexSet(integer: section), with: .none)
			}
		}
	}

// MARK: -
	func update(with value: AnyObject?) {
		fatalError("This method must be overridden")
	}

// MARK: -
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		fatalError("This method must be overridden")
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		fatalError("This method must be overridden")
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		fatalError("This method must be overridden")
	}

}
