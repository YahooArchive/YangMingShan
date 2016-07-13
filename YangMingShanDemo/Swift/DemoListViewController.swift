//
//  ViewController.swift
//  YangMingShanDemo-Swift
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

import UIKit


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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        let cellInfo = self.listArray[indexPath.row]

        cell.textLabel?.text = cellInfo["title"]
        cell.detailTextLabel?.text = cellInfo["description"]
        
        return cell;
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellInfo = self.listArray[indexPath.row]
        self.performSegueWithIdentifier(cellInfo["segueIdentifier"]!, sender: self)
    }
}

