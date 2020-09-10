//
//  AutoCompleteViewController.swift
//  LocationManagerTest
//
//  Created by Philipp Hentschel on 10.09.20.
//  Copyright © 2020 Philipp Hentschel. All rights reserved.
//

import UIKit

class AutoCompleteViewController: UITableViewController {
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: AutoCompleteDelegate?
    
    public var data: Array<String>? {
        didSet {
            self.filteredData = data
        }
    }
    
    private var searchString: String? {
        didSet {
            self.filteredData = data?.filter({$0.lowercased().contains(searchString?.lowercased() ?? "")})
            self.tableView.reloadData()
        }
    }
    
    private var filteredData: Array<String>?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tableView.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "BasicCell")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Keyboard
        
        searchBar.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredData?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = filteredData?[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = filteredData?[indexPath.row]
        delegate?.onValueSelected(value)
        self.dismiss(animated: true, completion: nil)
    }

}

extension AutoCompleteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchString = searchText
    }
}

class BasicCell: UITableViewCell {

}
