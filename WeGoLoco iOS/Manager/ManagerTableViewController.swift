//
//  MangerTableViewController.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 26/11/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import UIKit
import PromiseKit

class ManagerTableViewController: UITableViewController, LoadingAnimationProtocol, NavigationBarGradientProtocol {
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var tinpons = [Tinpon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LoadingAnimationProtocol
        loadingAnimationView = view
        // Navbar gradient
        setNavigationBarGradient()
        
        loadTinpons()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tinpons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "managerTableViewCell", for: indexPath) as? ManagerTableViewCell else {
            fatalError("The dequeed cell is ont an instance of ManagerTableViewCell.")
        }
        cell.tinpon = tinpons[indexPath.row]

        return cell
    }
    
    // MARK: - Helper
    func loadTinpons() {
        startLoadingAnimation()
        firstly {
            API.getRetailerTinpons()
            }.then { tinpons -> Void in
                self.tinpons = tinpons!
                self.stopLoadingAnimation()
                self.tableView.reloadData()
            }.catch { error in
                print("ManagerTableView: \(error)")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    @IBAction func dismissAddProductVC(segue: UIStoryboardSegue) {
        let addProductVC = segue.source as! QuantitiesViewController
        self.tinpons.append(addProductVC.tinpon)
        self.tableView.reloadData()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
