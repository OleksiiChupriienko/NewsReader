//
//  WebViewVC.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/16/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController, WKNavigationDelegate {
    
    var boxView: UIView?

    var url: String? = nil
    @IBOutlet weak var browser: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        browser.navigationDelegate = self
        guard let urlString = url, let myURL = URL(string: urlString) else {
            let alertVC = UIAlertController(title: "Loading Error", message: "Can not download page. Not valid URL", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: {action in self.navigationController?.popViewController(animated: true)})
            alertVC.addAction(action)
            present(alertVC, animated: true, completion: nil)
            return
        }
        browser.load(URLRequest(url: myURL))
    }

    func webView(_: WKWebView, didStartProvisionalNavigation: WKNavigation!) {
        guard boxView == nil else { return }
        // Box config:
        let width: CGFloat = 80
        let height: CGFloat = 80
        let x = (browser.frame.width / 2) - (width / 2)
        let y = (browser.frame.height / 2) - (height / 2) + (navigationController?.navigationBar.frame.height ?? 0)
        let box = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        boxView = box
        box.backgroundColor = UIColor.black
        box.alpha = 0.9
        box.layer.cornerRadius = 10

        // Spin config:
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        activityView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
        activityView.startAnimating()

        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
        textLabel.text = "Loading..."

        // Activate:
        browser.scrollView.isScrollEnabled = false
        box.addSubview(activityView)
        box.addSubview(textLabel)
        view.addSubview(box)
    }
    
    func webView(_: WKWebView, didFinish: WKNavigation!){
        boxView?.removeFromSuperview()
        browser.scrollView.isScrollEnabled = true
    }
}

