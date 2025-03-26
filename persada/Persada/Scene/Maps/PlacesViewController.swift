/*
 * Copyright 2017 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GooglePlaces

class PlacesViewController: UITableViewController {

//  @IBOutlet weak var tableView: UITableView!

//    lazy var tableView = UITableView()
    
  // An array to hold the list of possible locations.
  var likelyPlaces: [GMSPlace] = []
  var selectedPlace: GMSPlace?

  // Cell reuse id (cells that scroll out of view can be reused).
  let cellReuseIdentifier = "cell"

 
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("see view \(likelyPlaces)")
//        view.addSubview(tableView)
//        tableView.fillSuperview()

    // Register the table view cell class and its reuse id.
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

//    // This view controller provides delegate methods and row data for the table view.
//    tableView.delegate = self
//    tableView.dataSource = self

//    tableView.reloadData()
  }

  // Pass the selected place to the new view controller.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "unwindToMain" {
      if let nextViewController = segue.destination as? MapViewController {
        nextViewController.selectedPlace = selectedPlace
      }
    }
  }
    
    func backToMaps(){
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }

        for firstViewController in viewControllers {
            if firstViewController is MapViewController {
                let vc = firstViewController as! MapViewController
                vc.selectedPlace = selectedPlace
                vc.backToMap()
                self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
}

// Respond when a user selects a place.
extension PlacesViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedPlace = likelyPlaces[indexPath.row]
//    performSegue(withIdentifier: "unwindToMain", sender: self)
    backToMaps()
  }

  // Adjust cell height to only show the first five items in the table
  // (scrolling is disabled in IB).
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.tableView.frame.size.height/5
  }

  // Make table rows display at proper height if there are less than 5 items.
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if (section == tableView.numberOfSections - 1) {
      return 1
    }
    return 0
  }
}

// Populate the table with the list of most likely places.
extension PlacesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return likelyPlaces.count
  }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    let collectionItem = likelyPlaces[indexPath.row]

    cell.textLabel?.text = collectionItem.name

    return cell
  }
}
