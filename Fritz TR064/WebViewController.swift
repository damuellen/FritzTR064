//
//  ViewController.swift
//  BlockAnalytics
//
//  Created by Chris Bettin on 6/14/15.
//  Copyright © 2015 Crystalfusion LLC. All rights reserved.
//

import UIKit
import SafariServices

class WebViewController: UIViewController {
  
  lazy var webView: UIWebView = {
    let webView = UIWebView()
    webView.scalesPageToFit = true
    
    return webView
  }()

  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.view.addSubview(self.webView)
    self.webView.bounds = self.view.bounds
  }
  
  func goBack()
  {
    webView.goBack()
  
  }
  
  func loadWebPage(URL: String)
  {
      let request = NSURLRequest(URL: NSURL(string: URL)!)
      webView.loadRequest(request)

  }
  
  
}
