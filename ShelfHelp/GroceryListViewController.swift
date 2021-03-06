//
//  FirstViewController.swift
//  ShelfHelp
//
//  Created by Humza Siddiqui on 2/17/16.
//  Copyright © 2016 Humza Siddiqui. All rights reserved.
//

import UIKit
import RealmSwift

class GroceryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Attributes
    
    @IBOutlet weak var DeleteAllGroceriesButton: UIBarButtonItem!
    @IBOutlet weak var EditGroceryListButton: UIBarButtonItem!
    @IBOutlet weak var groceryTable: UITableView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    
    // MARK: Variables
    var mealList: Results<Recipe>!
    var ingredientList: Results<Ingredient>!
    var ingredientDictionary = [String:Ingredient]()
    
    var sectionedTable: Bool = false
    
    // MARK: View Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        retrieveElementsAndUpdateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        groceryTable.delegate = self
        groceryTable.dataSource = self
        retrieveElementsAndUpdateUI()
        groceryTable.tableFooterView = UIView(frame: CGRectZero)
        DeleteAllGroceriesButton.tintColor = UIColor.clearColor()
        DeleteAllGroceriesButton.enabled = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lobster 1.4", size: 24)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        retrieveElementsAndUpdateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Realm data handling

    func retrieveElementsAndUpdateUI(){
        let realm = try! Realm()
        mealList = realm.objects(Recipe).sorted("label")
        ingredientList = realm.objects(Ingredient).sorted("name")
        self.groceryTable.reloadData()
    }
    
    func deleteAllIngredientsAndUpdateUI(){
        let realm = try! Realm()
        try! realm.write {
            for item in ingredientList {
                realm.delete(item)
            }
        }
        self.groceryTable.reloadData()
    }
        
    // MARK: UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.sectionedTable == true {
            if self.mealList.count == 0 {
                let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, groceryTable.bounds.size.width, groceryTable.bounds.size.height))
                noDataLabel.text = "Visit the search tab to search for recipes and add items to your grocery list"
                noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
                noDataLabel.numberOfLines = 0
                noDataLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                noDataLabel.textAlignment = NSTextAlignment.Center
                groceryTable.backgroundView = noDataLabel
                return self.mealList.count
            }
            groceryTable.backgroundView = nil
            return self.mealList.count
        }
        else {
            if self.ingredientList.count == 0 {
                let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, groceryTable.bounds.size.width - 40, groceryTable.bounds.size.height))
                noDataLabel.text = "Visit the search tab to search for recipes and add items to your grocery list"
                noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
                noDataLabel.numberOfLines = 0
                noDataLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                noDataLabel.textAlignment = NSTextAlignment.Center
                groceryTable.backgroundView = noDataLabel
                return 0
            }
            groceryTable.backgroundView = nil
            return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.sectionedTable == true {
            return self.mealList[section].label
        }
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionedTable == true {
            return self.mealList[section].ingredientArray.count
        }
        else {
            return self.ingredientList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "GroceryItemCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroceryTableViewCell
        
        let ingredient: Ingredient!
        if(sectionedTable == true){
            ingredient = self.mealList[indexPath.section].ingredientArray[indexPath.row]
        }
        else {
            ingredient = self.ingredientList[indexPath.row]
        }
        
        
        // What is this? --David
        cell.ingredientLabel.text = ingredient.name
        if (ingredient.unit != "" && ingredient.quantity > 0){
            cell.quantityLabel.text = String(format: "%.1f", ingredient.quantity)
            cell.unitLabel.text = ingredient.unit
        } else {
            cell.quantityLabel.text = ""
            cell.unitLabel.text = ""
        }
        
        if (ingredient.checked == true) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            let ingredientVictim: Ingredient!
            if(sectionedTable){
                ingredientVictim = self.mealList[indexPath.section].ingredientArray[indexPath.row]
            }
            else{
                ingredientVictim = self.ingredientList[indexPath.row]
            }
            
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            let realm = try! Realm()
            try! realm.write {
                realm.delete(ingredientVictim)
            }            
            
            
            self.groceryTable.reloadData()
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let tappedItem: Ingredient!
        if(sectionedTable == true){
            tappedItem = mealList[indexPath.section].ingredientArray[indexPath.row] as Ingredient
            let realm = try! Realm()
            try! realm.write {
                tappedItem.checked = !tappedItem.checked
            }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
        else {
            let tappedItem = ingredientList[indexPath.row] as Ingredient
            let realm = try! Realm()
            try! realm.write {
                tappedItem.checked = !tappedItem.checked
            }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    // MARK: Actions

    @IBAction func segmentedControlSelected(sender: UISegmentedControl) {
        switch self.segmentedController.selectedSegmentIndex
        {
        case 0:
            self.sectionedTable = false
        case 1:
            self.sectionedTable = true
        default:
            self.sectionedTable = false
            break;
        }
        
        self.groceryTable.reloadData()
    }
    
    @IBAction func editGroceryList(sender: UIBarButtonItem) {
        print("Edit groceries pushed")
        self.groceryTable.editing = !self.groceryTable.editing
        if (EditGroceryListButton.title == "Edit"){
            EditGroceryListButton.title = "Cancel"

            DeleteAllGroceriesButton.tintColor = UIColor.redColor()
            DeleteAllGroceriesButton.enabled = true
        } else {
            EditGroceryListButton.title = "Edit"
            DeleteAllGroceriesButton.tintColor = UIColor.clearColor()
            DeleteAllGroceriesButton.enabled = false

        }
        

        
    }
    @IBAction func deleteAllGroceries(sender: UIBarButtonItem) {
        
        let confirmAlert = UIAlertController(title: "Delete all", message: "Are you sure you want to delete this list? ", preferredStyle: UIAlertControllerStyle.Alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.deleteAllIngredientsAndUpdateUI()
            self.EditGroceryListButton.title = "Edit"
            self.DeleteAllGroceriesButton.tintColor = UIColor.clearColor()
            self.DeleteAllGroceriesButton.enabled = false

        }))
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            confirmAlert .dismissViewControllerAnimated(true, completion: nil)
            print ("CANCELED GROCERIES DELETE")
            
            
        }))
        
        presentViewController(confirmAlert, animated: true, completion: nil)
    }
    
    
    // MARK: Helpers
    
    func stackGroceryListItems(){
        
        // NOTE: THIS WON'T WORK BECAUSE IT MODIFIES REALM OBJECTS
        // TODO: Create new "Grocery Item" class that is NOT a realm object such that it
        // can be modified outside of the database.
        for item in ingredientList {
            // If the same name and unit are in the list
            if ingredientDictionary[item.nameAndUnitString] == nil {
                ingredientDictionary[item.nameAndUnitString] = item
            }
            else{
                // Add the amounts
                let amount = ingredientDictionary[item.nameAndUnitString]!.quantity
                ingredientDictionary[item.nameAndUnitString]?.quantity = amount + item.quantity
            }
        }
        
        return
    }
}

