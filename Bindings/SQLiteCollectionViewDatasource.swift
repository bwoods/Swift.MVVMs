import UIKit


class SQLiteCollectionViewDatasource: SQLiteQuery, UICollectionViewDataSource {
	override var array: [[String : NSObject]] {
		didSet {
			if let collectionView = self.owner as? UICollectionView {
				if oldValue.count == 0 {
					collectionView.reloadData() // don't animate in the initial elements
				} else {
					collectionView.animateItemChanges(oldData: oldValue, newData: self.array)
				}
			}
		}
	}

// MARK: - UICollectionViewDataSource methods
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
		self.fill(cell.contentView, with: self[indexPath.row])

		return cell
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)

	}


}


