//
//  NewsViewController.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/3/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser

class NewsViewController: UIViewController {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    var news: [RSSItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.tableFooterView = UIView()
        let nib = UINib(nibName: "NewsCell", bundle: nil)
        newsTableView.register(nib, forCellReuseIdentifier: "NewsCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super .prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "ShowDetail":
            if let webVC = segue.destination as? WebViewVC, let url = sender as? String {
                webVC.url = url
            }
        default:
            break
         }
    }
    
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell else {
            fatalError("ERROR")
        }
        let title = news[indexPath.row].title?.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.label.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: news[indexPath.row].link)
    }
}
