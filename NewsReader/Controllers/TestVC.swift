//
//  TestVC.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/8/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//

import UIKit

protocol TestVCDelegate: class {
    func transferData(url: String, title: String)
}

class TestVC: UIViewController {
    
    var feeds: [FeedItem] = []
    
    weak var delegate: TestVCDelegate?
    
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()

    @IBOutlet weak var searchFeedsSB: UISearchBar!
    @IBOutlet weak var searchResultsTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchFeedsSB.becomeFirstResponder()
        searchFeedsSB.delegate = self
        searchResultsTV.dataSource = self
        searchResultsTV.delegate = self
        searchResultsTV.tableFooterView = UIView()
        let nib = UINib(nibName: "SearchCell", bundle: nil)
        searchResultsTV.register(nib, forCellReuseIdentifier: "SearchCell")
    }
    
}

extension TestVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchPhrase = searchFeedsSB.text else { return }
        let phrase = searchPhrase.trimmingCharacters(in: .whitespaces)
        if phrase != "" {
            self.setLoadingScreen()
            let service = FeedService()
            service.getFeeds(searchPhrase: phrase, completion: { feeds in
                self.feeds = feeds
                DispatchQueue.main.async { [weak self] in
                    self?.searchResultsTV.reloadData()
                    self?.removeLoadingScreen()
                }
            })
            searchBar.resignFirstResponder()
        }
        
    }
}

extension TestVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
            fatalError("cellForRowAt SearchCell ERROR")
        }
        cell.titleLabel.text = feeds[indexPath.row].title
        cell.urlLabel.text = feeds[indexPath.row].urlString
        cell.rightImageView.image = CoreDataManager.instance.isSaved(url: feeds[indexPath.row].urlString) ? UIImage(named: "done") : UIImage(named: "add")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !CoreDataManager.instance.isSaved(url: feeds[indexPath.row].urlString) else {
            let alertVC = UIAlertController(title: "Alert", message: "This feed is already in list.", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertVC.addAction(cancelAction)
            present(alertVC, animated: true, completion: nil)
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchCell else {
            fatalError("didSelectRowAt SearchCell ERROR")
        }
        cell.rightImageView.image = UIImage(named: "done")
        let url = feeds[indexPath.row].urlString
        let title = feeds[indexPath.row].title
        self.delegate?.transferData(url: url, title: title ?? "")
    }
}

extension TestVC {
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 30
        let height: CGFloat = 30
        let x = (searchResultsTV.frame.width / 2) - (width / 2)
        let y = (searchResultsTV.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height ?? 0)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
                
        // Sets spinner
        spinner.style = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds spinner to the view
        loadingView.addSubview(spinner)
        searchResultsTV.addSubview(loadingView)
    }
    
    private func removeLoadingScreen() {
        loadingView.removeFromSuperview()
        spinner.stopAnimating()
    }
}

