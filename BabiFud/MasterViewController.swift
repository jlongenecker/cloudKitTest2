/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CoreLocation

let MasterViewSubscriptionId = "MasterView"

class MasterViewController: UITableViewController, CLLocationManagerDelegate, NearbyLocationsResultsControllerDelegate {
  
  var detailViewController: DetailViewController? = nil
  var locationManager: CLLocationManager!
  var controller: NearbyLocationsResultsController!
  
  let FilterDistance: CLLocationDistance = 56000.0 //10km
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      self.clearsSelectionOnViewWillAppear = false
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let model: Model = Model.sharedInstance()
    self.controller = NearbyLocationsResultsController(delegate: self)
    
    
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = controllers[controllers.endIndex-1] as? DetailViewController
    }
    
    controller.loadCache()
    setupLocationManager()
    

    //setup a refresh control
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
  }
    
  
  //MARK:- Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      let indexPath = self.tableView.indexPathForSelectedRow!
      let object = controller.results[indexPath.row]
     ((segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController).detailItem = object
    }
  }
  
  //MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controller.results.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EstablishmentCell

    let object = controller.results[indexPath.row]
    cell.titleLabel.text = object.name

    object.fetchRating { (rating: Double, isUser: Bool) in
      dispatch_async(dispatch_get_main_queue()) {
        cell.starRating.rating = Float(rating)
        cell.starRating.emptyColor = isUser ? UIColor.yellowColor() : UIColor.whiteColor()
        cell.starRating.solidColor = isUser ? UIColor.yellowColor() : UIColor.whiteColor()
      }
    }
    
    var badges = [UIImage]()
    badges.appendContentsOf(object.changingTable().images())
    badges.appendContentsOf(object.seatingType().images())
    cell.badgeView.setBadges(badges)
    
    object.loadCoverPhoto { image in
      dispatch_async(dispatch_get_main_queue()) {
        cell.coverPhotoView.image = image
      }
    }

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      let object = controller.results[indexPath.row]
      self.detailViewController!.detailItem = object
    }
  }
  
  ////////////////////////////////////////////////////////////////////////////////////
  ///  Stubs to Updated As Part of the Tutorial
  ////////////////////////////////////////////////////////////////////////////////////
  
  //MARK: -  model delegate stubs
  
  func refresh() {
    //replace stub here
    var location = locationManager.location
    //1 
    if location == nil {
        //Using Apple as our default location
        location = CLLocation(latitude: 182, longitude: -122.03118)
    }
    
    //2
    let predicate = Model.sharedInstance().createLocationPredicate(location!, radiusInMeters: FilterDistance)
    controller.predicate = predicate
    
    //3 
    controller.start()
    
  }
  
  func willBeginUpdating() {
    //replace stub
    
    //1
    tableView.beginUpdates()
  }

  func establishmentUpdated(establishment: Establishment, index: Int) {
    //replace stub
    //2 
    let indexPath = NSIndexPath(forRow: index, inSection: 0)
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
  }
  
  func establishmentAdd(establishment: Establishment, index: Int) {
    //replace stub
    //3 
    let indexPath = NSIndexPath(forRow: index, inSection: 0)
    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
  }
  
  func didEndUpdating(error: NSError!) {
    //replace stub
    //4
    tableView.endUpdates()
    refreshControl?.endRefreshing()
  }

  func establishmentRemovedAtIndex(index: Int)  {
    //replace stub
    let indexPath = NSIndexPath(forRow: index, inSection: 0)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
  }

  ////////////////////////////////////////////////////////////////////////////////////
  //MARK: - location stuff & delegate
  
  func setupLocationManager() {
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.distanceFilter = 500.0 //0.5km
    locationManager.delegate = self
    
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .NotDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .AuthorizedWhenInUse:
      if let location = locationManager.location {
        refresh()
      } else {
        locationManager.startUpdatingLocation()
      }
    default:
      //do nothing
      print("Other status")
    }
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)  {
    switch status {
    case .NotDetermined:
      manager.requestWhenInUseAuthorization()
    case .AuthorizedWhenInUse:
      manager.startUpdatingLocation()
    default:
      //do nothing
      print("Other status2")
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let loc = locations.last {
      refresh()
    }
  }
    
    func controllerUpdated() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
}

