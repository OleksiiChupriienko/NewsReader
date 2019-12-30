//
//  ViewController.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/2/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import CoreData

class MainViewController: UIViewController {
    
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    
    var fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: "Feed", keyForSort: "feedTitle")
    
    @IBOutlet weak var mainTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MainCell", bundle: nil)
        mainTableView.register(nib, forCellReuseIdentifier: "MainCell")
        mainTableView.dataSource = self
        mainTableView.tableFooterView = UIView()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            CoreDataManager.instance.myFeeds = fetchedResultsController.fetchedObjects?.compactMap { $0 as? Feed } ?? []
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "AddFeeds":
            if let testVC = segue.destination as? TestVC {
            testVC.delegate = self
            }
        case "ShowNews":
            if let newsVC = segue.destination as? NewsViewController, let feed = sender as? RSSFeed {
                newsVC.news = feed.items
            }
        default:
            break
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell") as! MainCell
        configureCell(cell: cell, for: indexPath)
        return cell
    }
    private func configureCell(cell: MainCell, for indexPath: IndexPath) {
        let feed = fetchedResultsController.fetchedObjects?[indexPath.row] as! Feed
        cell.label.text = feed.feedTitle
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setLoadingScreen()
        let feed = fetchedResultsController.fetchedObjects?[indexPath.row] as! Feed
        guard let url = feed.feedURL else { return }
        Alamofire.request(url).responseRSS() { response in
            guard response.result.isSuccess else {
                print("Ошибка при запросе данных \(String(describing: response.result.error))")
                return
            }
            if let feed: RSSFeed = response.result.value {
                DispatchQueue.main.async {
                    self.removeLoadingScreen()
                    self.performSegue(withIdentifier: "ShowNews", sender: feed)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let managedObject = fetchedResultsController.object(at: indexPath) as! NSManagedObject
            CoreDataManager.instance.managedObjectContext.delete(managedObject)
            CoreDataManager.instance.saveContext()
        }
    }
}

extension MainViewController: TestVCDelegate {
    func transferData(url: String, title: String) {
        let feed = Feed(context: CoreDataManager.instance.managedObjectContext)
        feed.feedTitle = title
        feed.feedURL = url
        CoreDataManager.instance.saveContext()
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainTableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        CoreDataManager.instance.myFeeds = fetchedResultsController.fetchedObjects?.compactMap { $0 as? Feed } ?? []
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                mainTableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                mainTableView.deleteRows(at: [indexPath], with: .right)
            }
        case .update:
            if let indexPath = indexPath, let cell = mainTableView.cellForRow(at: indexPath) as? MainCell {
                let feed = fetchedResultsController.object(at: indexPath) as? Feed
                cell.label.text = feed?.feedTitle
            }
        case .move:
            if let indexPath = indexPath {
                mainTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                mainTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            break
        }
    }
}

extension MainViewController {
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 30
        let height: CGFloat = 30
        let x = (mainTableView.frame.width / 2) - (width / 2)
        let y = (mainTableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height ?? 0)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
                
        // Sets spinner
        spinner.style = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds spinner to the view
        loadingView.addSubview(spinner)
        mainTableView.addSubview(loadingView)
    }
    
    private func removeLoadingScreen() {
        loadingView.removeFromSuperview()
        spinner.stopAnimating()
    }
}
