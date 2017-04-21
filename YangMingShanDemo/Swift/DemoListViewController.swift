//
//  ViewController.swift
//  YangMingShanDemo-Swift
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

import UIKit
import YangMingShan


class DemoListViewController: UITableViewController {

    let listArray = [
        [
            "title": "YMSPhotoPicker",
            "description": "Photo & Album picker",
            "segueIdentifier": "goToPhotoViewIdentifier"
        ]
    ]
    let cellIdentifier = "reuseIdentifier"


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSources

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let cellInfo = self.listArray[(indexPath as NSIndexPath).row]

        cell.textLabel?.text = cellInfo["title"]
        cell.detailTextLabel?.text = cellInfo["description"]
        
        return cell;
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellInfo = self.listArray[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: cellInfo["segueIdentifier"]!, sender: self)
    }
}

