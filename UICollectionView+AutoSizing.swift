import UIKit


class AutoSizingCell: UICollectionViewCell {
	@IBOutlet weak var widthConstraint: NSLayoutConstraint!

	override func awakeFromNib() {
		super.awakeFromNib()

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
	}

	override func layoutSubviews() {
		let size = UIScreen.main.bounds.size
        let width = min(size.width, size.height)
		let height = max(size.width, size.height)
		widthConstraint.constant = width < 400 ? height * 0.43 : height * 0.23

		self.updateConstraints()
		super.layoutSubviews()
	}
}

class AutoSizingCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
	override func awakeFromNib() {
		estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() } as? [UICollectionViewLayoutAttributes]
		attributes?.filter { $0.representedElementCategory == .cell }
			.reduce([ : ], { $0.merging([ ceil($1.center.y) : [ $1 ] ], uniquingKeysWith: { $0 + $1 }) })
			.values.forEach { line in
				let maxHeightY = line.max { $0.frame.size.height < $1.frame.size.height }?.frame.origin.y
				line.forEach { $0.frame = $0.frame.offsetBy(dx: 0, dy: (maxHeightY ?? $0.frame.origin.y) - $0.frame.origin.y) }
		}

		return attributes
	}
}


