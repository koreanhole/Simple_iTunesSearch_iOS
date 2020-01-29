
import UIKit
import SafariServices

class StoreItemListTableViewController: UITableViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var filterSegmentedControl: UISegmentedControl!
    
    let storeItemController = StoreItemController()
    
    var items = [StoreItem]()
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchMatchingItems() {
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            
            let query: [String:String] = [
                "term" : searchTerm,
                "media" : "\(mediaType)",
                "limit" : "\(50)",
                "lang" : "ko_kr"
            ]
            storeItemController.fetchItems(matching: query) { (storeInfo) in
                if let storeInfo = storeInfo {
                    self.items = storeInfo
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else {
                    print("there is some error")
                }
            }
            // use the item controller to fetch items
            // if successful, use the main queue to set self.items and reload the table view
            // otherwise, print an error to the console
        }
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {

        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.artist
        cell.imageView?.image = UIImage(imageLiteralResourceName: "gray")
        let task = URLSession.shared.dataTask(with: item.artworkURL, completionHandler: {(data, response, error) in
            guard let data = data,
                let image = UIImage(data: data) else {return}
            DispatchQueue.main.async {
                cell.imageView?.image = image
            }
        })
        task.resume()
        
        // set detail label to the item's subtitle
        // reset the image view to the gray image
        
        // initialize a network task to fetch the item's artwork
        // if successful, use the main queue capture the cell, to initialize a UIImage, and set the cell's image view's image to the 
        // resume the task
    }
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = items[indexPath.row]
        let url = item.viewURL
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}

extension StoreItemListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}
