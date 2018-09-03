import UIKit


/**
	Tries to generate URLs from the string passed to `update(with value: AnyObject?)`. Only URLs that successfuly respond to an HTTP HEAD request will be displayed.

	Both https: and http: URLs are generated, if a scheme is not given, with https URLs being given preferential display.

	- Important:
		The following “errors” will be reported as URLs are being checked for validity:

		- kCFURLErrorCancelled: -999
		- kCFURLErrorTimedOut: -1001
		- kCFURLErrorCannotFindHost: -1003
		- kCFURLErrorNotConnectedToInternet: -1009
		- kCFURLErrorSecureConnectionFailed: -1200
		- kCFURLErrorServerCertificateUntrusted: -1202

		Other than making the log useless (by flooding it) they are expected and harmless.
*/
class WebSearchResultsUpdater: TableViewSectionUpdater {
	var httpTask: URLSessionTask? {
		willSet { if httpTask != nil { httpTask!.cancel(); UIApplication.decrementNetworkActivityCount() } }
		didSet { if httpTask != nil { UIApplication.incrementNetworkActivityCount() } }
	}

	var httpsTask: URLSessionTask? {
		willSet { if httpsTask != nil { httpsTask!.cancel(); UIApplication.decrementNetworkActivityCount() } }
		didSet { if httpsTask != nil { UIApplication.incrementNetworkActivityCount() } }
	}

	var searchTerms = "" { didSet { reloadSection(animated: false) } }
	var results: [URL] = [ ] { didSet { reloadSection(animated: results.count > 0) } }

	override func update(with value: AnyObject?) {
		results.removeAll(); httpsTask = nil; httpTask = nil

		guard let searchTerms = value as? String, searchTerms != "" else {
			return
		}

		self.searchTerms = searchTerms
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
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpsTask)
			case ("http", .some, _):
				components = convertPathToHostIfNeeded(components)
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpTask)
			case (nil, nil, let path) where path.count > 0:
				components.scheme = "https"
				components = convertPathToHostIfNeeded(components)
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpsTask)
				components.scheme = "http"
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpTask)
			case ("http", .some, _):
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpTask)
				components.scheme = "https"
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpsTask)
			case ("https", .some, _):
				performHEADRequest(for: components.url, with: \WebSearchResultsUpdater.httpsTask)
			default:
				break
			}
		}
	}

	fileprivate func performHEADRequest(for url: URL!, with keyPath: ReferenceWritableKeyPath<WebSearchResultsUpdater, URLSessionTask?>) -> Void {
		var request = URLRequest(url: url)
		request.httpMethod = "HEAD"
		request.cachePolicy = .returnCacheDataElseLoad // cached data would be perfect; this will be called a lot

		var task: URLSessionTask!
		task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
			DispatchQueue.main.async {
				guard let `self` = self else {
					return
				}

				let current = self[keyPath: keyPath] // we use KeyPaths because “escaping closures can only capture inout parameters explicitly by value”
				guard task.taskIdentifier == current?.taskIdentifier else {
					return // another request has replaced this one
				}

				self[keyPath: keyPath] = nil // no race condition here because we're on the main queue

				if let http = response as? HTTPURLResponse {
					switch http.statusCode {
					case 405...406: fallthrough // our HTTP verb was not supported, but the server did responded
					case 200: // 301...303, 307...308 redirects were turned into 200’s by URLSession
						self.results = Set([ http.url ?? url ]) // http.url will contain the redirect URL, if any
							.union(self.results) // unique the URLs (redirects may result in duplicates)
							.sorted(by: { return $0.scheme!.count > $1.scheme!.count }) // sort ‘https’ before ‘http’
					default:
						return // bad url, just ignore it
					}
				}
			}
		}

		task.resume()
		self[keyPath: keyPath] = task
	}

// MARK: - UITableViewDataSource methods
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Web Suggestions" // serves as a header for both this and the next section
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1 + results.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard indexPath.row != 0 else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "URL Search", for: indexPath)
			cell.textLabel?.text = searchTerms.trimmingCharacters(in: .whitespacesAndNewlines)
			return cell
		}

		let url = results[indexPath.row - 1]
		let cell = tableView.dequeueReusableCell(withIdentifier: url.scheme == "https" ? "URL https" : "URL http", for: indexPath)
		if url.path == "/" {
			cell.textLabel?.text = url.host!
		} else {
			cell.textLabel?.text = url.host! + url.path
		}

		return cell
	}

}


