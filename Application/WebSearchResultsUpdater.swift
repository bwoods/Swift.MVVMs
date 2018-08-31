import UIKit


class WebSearchResultsUpdater: NSObject, SearchControllerUpdater {
	var httpTask: URLSessionTask?
	var httpsTask: URLSessionTask?
	var results: [URL] = [ ] {
		didSet { UIView.performWithoutAnimation { self.tableView?.reloadData() } }
	}

	var searchTerms: String = "" {
		willSet { results.removeAll(); httpsTask?.cancel(); httpTask?.cancel() }
		didSet {
			guard searchTerms != "" else {
				return
			}

			let convertPathToHostIfNeeded = { (components: URLComponents) -> URLComponents in // "example.com" puts the string in the path, not the host
				var components = components
				if let pathComponents = (components.path as NSString?)?.pathComponents, pathComponents.count > 0 {
					components.host = pathComponents.first!
					components.path = "/" + pathComponents.dropFirst().joined(separator: "/")
				}

				if ((components.host ?? "") as NSString).pathExtension == "" {
					components.host = components.host! + ".com"
				}

				return components
			}

			if var components = URLComponents(string: searchTerms) {
				switch (components.scheme, components.host, components.path) {
				case ("https", .some, _):
					components = convertPathToHostIfNeeded(components)
					httpsTask = setup(task: \WebSearchResultsUpdater.httpsTask, for: components.url)
					httpTask = nil
				case ("http", .some, _):
					components = convertPathToHostIfNeeded(components)
					httpsTask = nil
					httpTask = setup(task: \WebSearchResultsUpdater.httpTask, for: components.url)
				case (nil, nil, let path) where path.count > 0:
					components.scheme = "https"
					components = convertPathToHostIfNeeded(components)
					httpsTask = setup(task: \WebSearchResultsUpdater.httpsTask, for: components.url)
					components.scheme = "http"
					httpTask = setup(task: \WebSearchResultsUpdater.httpTask, for: components.url)
				case ("http", .some, _):
					httpTask = setup(task: \WebSearchResultsUpdater.httpTask, for: components.url)
					components.scheme = "https"
					httpsTask = setup(task: \WebSearchResultsUpdater.httpsTask, for: components.url)
				case ("https", .some, _):
					httpTask = nil
					httpsTask = setup(task: \WebSearchResultsUpdater.httpsTask, for: components.url)
				default:
					break
				}
			}
		}
	}

	func setup(task keyPath: KeyPath<WebSearchResultsUpdater, URLSessionTask?>, for url: URL?) -> URLSessionTask {
		return check(url: url!, success: { [weak self] (returning, url) in
			guard let `self` = self else {
				return
			}

			let task = self[keyPath: keyPath] // we use keyPaths because “escaping closures can only capture inout parameters explicitly by value”
			guard returning.taskIdentifier == task?.taskIdentifier else {
				return // another request has replaced this one
			}

			var results = self.results
			results.append(url)

			self.results = Set(results) // unique the URLs (redirects may result in duplicates)
				.sorted(by: { return $0.scheme!.count > $1.scheme!.count }) // sort ‘https’ before ‘http’
		})
	}

	fileprivate func check(url: URL, success: @escaping (_ task: URLSessionTask, _ url: URL) -> Void) -> URLSessionTask {
		var request = URLRequest(url: url)
		request.httpMethod = "HEAD"
		request.cachePolicy = .returnCacheDataElseLoad // cached data would be perfect; this will be called a lot

		var task: URLSessionTask?
		task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
			guard let _ = self else {
				return
			}

			if let http = response as? HTTPURLResponse {
				switch http.statusCode {
				case 405...406: fallthrough // our HTTP verb was not supported, but the server did responded, so…
				case 200: // 301...303, 307...308 redirects were turned into 200’s by URLSession
					DispatchQueue.main.async {
						success(task!, http.url ?? url) // http.url will point to any redirects from url
					}
				default:
					return // bad url, just ignore it
				}
			}
		}

		task!.resume()
		return task! // no race condition here with the callback because it will be on the next cycle at the soonest
	}

// MARK: - 
	weak var searchBar: UISearchBar?
	weak var tableView: UITableView? {
		didSet {
			tableView?.rowHeight = UITableViewAutomaticDimension
			tableView?.estimatedRowHeight = 44
		}
	}

// MARK: - UISearchResultsUpdating methods
	func updateSearchResults(for searchController: UISearchController) {
		searchBar = searchController.searchBar // set our local reference
		searchTerms = searchController.searchBar.text ?? ""
	}

// MARK: - UITableViewDataSource methods
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return results.isEmpty ? nil : "Web Suggestions"
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let url = results[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: url.scheme == "https" ? "URL https" : "URL http", for: indexPath)
		if url.path == "/" {
			cell.textLabel?.text = url.host!
		} else {
			cell.textLabel?.text = url.host! + url.path
		}

		return cell
	}

}


