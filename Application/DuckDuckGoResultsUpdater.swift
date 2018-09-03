import UIKit


class DuckDuckGoResultsUpdater: TableViewSectionUpdater {
	struct Result : Decodable {
		let Heading: String // DuckDuckGo uses PascalCase, rather than camelCase or snake_case, so we do to
		let AbstractText: String
		let AbstractURL: URL
		let AbstractSource: String

		let RelatedTopics: [Topic]
		struct Topic : Decodable {
			let FirstURL: URL? // the JSON stores both Topic entries with these properties…
			let Text: String?

			let Name: String? // …or nested Topic collections with these properties
			let Topics: [Topic]?
		}
	}

	var result: Result? = nil { didSet { reloadSection(animated: false) } }
	var task: URLSessionTask? {
		willSet { if task != nil { task!.cancel(); UIApplication.decrementNetworkActivityCount() } }
		didSet { if task != nil { UIApplication.incrementNetworkActivityCount() } }
	}

	override func update(with value: AnyObject?) {
		self.result = nil; self.task = nil

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

		var task: URLSessionTask!
		task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
			let result = try? JSONDecoder().decode(Result.self, from: data ?? Data())
			DispatchQueue.main.async {
				guard task.taskIdentifier == self?.task?.taskIdentifier else {
					return // another request has replaced this one
				}

				self?.task = nil
				self?.result = result
			}
		}

		task!.resume()
		self.task = task
	}

// MARK: -
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch (result?.RelatedTopics.count, result?.AbstractText.isEmpty) {
		case (let .some(topics), false):
			return 1 + topics;
		case (let .some(topics), true):
			return topics;
		case (nil, nil):
			return 0;
		default:
			fatalError()
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let fill = { (index: Int) ->UITableViewCell  in
			let topic = self.result!.RelatedTopics[index]
			var heading = (topic.Name?.isEmpty ?? true) == false

			var string = ""
			if heading {
				string = topic.Name!
			} else {
				string = topic.Text?.replacingOccurrences(of: "...", with: "…") ?? ""
				if string.last != "…" { // if it end in an ellipsis, it is never to be treated as a header
					let tags = string.linguisticTags(in: string.startIndex..<string.endIndex, scheme: NSLinguisticTagScheme.lexicalClass.rawValue, tokenRanges: nil)
					if (tags.lazy.reversed().first { $0 == "SentenceTerminator" }) == nil { // sentences fragments are treated as headings too
						heading = true
					}
				}
			}

			let cell = tableView.dequeueReusableCell(withIdentifier: "Answer From DuckDuckGo", for: indexPath)
			cell.textLabel!.text = heading ? string : nil
			cell.detailTextLabel!.text = heading ? nil : string
			return cell
		}

		switch (indexPath.row, result?.AbstractText.isEmpty) {
		case (0, false):
			let cell = tableView.dequeueReusableCell(withIdentifier: "Answer From DuckDuckGo", for: indexPath)
				cell.textLabel!.text = result!.Heading
				cell.detailTextLabel!.text = result!.AbstractText
			return cell
		case (let index, nil):
			return fill(index)
		case (let index, let .some(empty)):
			return fill(empty ? index : index - 1)
		}
	}
	
}


