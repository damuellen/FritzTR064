//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {


  @IBOutlet weak var textView: UITextView!

  var detailItem: Action? {
    didSet {
        // Update the view.
        self.configureView()
    }
  }

  func configureView() {
    // Update the user interface for the detail item.
    if let detail = self.detailItem {
        if let textView = self.textView {
          var text = "Action Output\n"
          text += detail.output.keys.reduce("", combine: { $0 + "\n" + $1})
          text += "\nAction Input\n"
          text += detail.input.keys.reduce("", combine: { $0 + "\n" + $1})
          textView.text = text
        }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

