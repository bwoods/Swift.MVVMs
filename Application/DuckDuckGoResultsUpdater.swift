import UIKit


class DuckDuckGoResultsUpdater: TableViewSectionUpdater {
	struct Result : Decodable {
		let Heading: String // DuckDuckGo uses PascalCase, rather than camelCase or snakse_case…
		let AbstractText: String
		let AbstractURL: URL // FIXME: URL
		let AbstractSource: String
	}

	var result: Result? = nil { didSet { reloadSection(animated: false) } }
	var task: URLSessionTask?

	override func update(with value: AnyObject?) {
		result = nil
		guard let searchTerms = value as? String, searchTerms != "" else {
			return
		}

		var components = URLComponents(string: "https://api.duckduckgo.com/")!
		components.queryItems = [
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "ia", value: "meanings"), // meanings, about, or qa
			URLQueryItem(name: "q", value: searchTerms),
		]

		var request = URLRequest(url: components.url!)
		request.cachePolicy = .returnCacheDataElseLoad // cached data is preferable

		task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
			let result = try? JSONDecoder().decode(Result.self, from: data ?? Data())

			DispatchQueue.main.async {
				self?.task = nil
				self?.result = result
			}
		}

		task?.resume()
	}

// MARK: -
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return result?.AbstractText.isEmpty == false ? 2 : 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch (indexPath.row, result?.AbstractText.isEmpty) {
		case (0, _):
			return tableView.dequeueReusableCell(withIdentifier: "More From DuckDuckGo", for: indexPath)
		case (1, false):
			let cell = tableView.dequeueReusableCell(withIdentifier: "Info From DuckDuckGo", for: indexPath)
			(cell.contentView.viewWithTag(1) as! UILabel).text = result!.Heading
			(cell.contentView.viewWithTag(2) as! UILabel).text = result!.AbstractText
			return cell
		default:
			fatalError()
		}
	}
	
}


