//
//  CollectionViewController.swift
//  CollectionViewDemo
//
//  Created by Ravi Shankar on 13/07/15.
//  Copyright (c) 2015 Ravi Shankar. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var fruits:[Fruit] = []
    var sections:[String] = []
    
    var previouslySelectedCell:UICollectionViewCell?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        navigationController?.setToolbarHidden(true, animated: true)
        
        populateData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        //Register header View
    }
    
    //MARK:- Populate Data
    func populateData() {
        if let path = NSBundle.mainBundle().pathForResource("fruits", ofType: "plist") {
            if let dictArray = NSArray(contentsOfFile: path) {
                fruits = []
                sections = []
                for item in dictArray {
                    if let dict = item as? NSDictionary {
                        let name = dict["name"] as! String
                        let group = dict["group"] as! String
                        
                        let fruit = Fruit(name: name, section: group)
                        if !sections.contains(group)
                        {
                            sections.append(group)
                        }
                        fruits.append(fruit)
                    }
                }
            }
        }
        
    }
    
    func fruitsForSection(index: Int) -> [Fruit] {
        let section = sections[index]
        let fruitsInsection = fruits.filter { (fruit: Fruit) -> Bool in
            return fruit.section == section
        }
        return fruitsInsection
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        previouslySelectedCell?.contentView.backgroundColor = nil
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let flag = true
        if self.editing {
            return false
        }
        return flag
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let fruits = fruitsForSection(section)
        return fruits.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FruitCollectionViewCell
        var fruit: Fruit?
        if indexPath.section > 0 {
            fruit = fruitsForSection(indexPath.section)[indexPath.row]
        } else {
            fruit = fruits[indexPath.row]
        }
        
        
        let imageName = fruit!.name?.lowercaseString
        
        cell.fruitImage.image = UIImage(named: imageName!)
        cell.name.text = fruit!.name

        
        return cell
    }
    
    //MARK :- UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(collectionView.frame) / 3
        return CGSize(width: width, height: width)
    }
    
    //MARK :- Supplimentary Views
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let headerView: CollectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CollectionHeaderView
        
        headerView.headerLabel.text = sections[indexPath.section]

        return headerView
    }
    
    //MARK:- Hightlight Selection
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if let previouslySelectedCell = previouslySelectedCell{
            if !editing {
                previouslySelectedCell.contentView.backgroundColor = nil
            }
        }
        
        cell?.contentView.backgroundColor = UIColor.blueColor()
        previouslySelectedCell = cell
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = nil
    }
    
    //MARK:- Insert Cell
    
     @IBAction func insertFruit() {
        // Add new entry to data source
        
        let fruit = Fruit(name: "Banana", section: "Morning")
        fruits.append(fruit)
        // Add entry to collection View
        let indexPath = NSIndexPath(forItem: 1, inSection: 0)
        
        collectionView?.insertItemsAtIndexPaths([indexPath])
        
    }
    
    //MARK:- Delete Cell
    
    @IBAction func deleteFruit() {
        
        let indexpaths = collectionView?.indexPathsForSelectedItems()
        var deletedFruits:[Fruit] = []
        
        if let indexpaths = indexpaths {
            
            for item  in indexpaths {
                collectionView?.deselectItemAtIndexPath(item, animated: true)
                // fruits for section
                let sectionfruits = fruitsForSection(item.section)
                deletedFruits.append(sectionfruits[item.row])
            }
            
            // delete fruit model
            
            for item in deletedFruits {
                let index = fruits.indexOf({ (fruit) -> Bool in
                    item.name == fruit.name
                })
                if let index = index {
                    fruits.removeAtIndex(index)
                }
            }
            
           collectionView?.deleteItemsAtIndexPaths(indexpaths)
        }
    }
    
    
    //MARK :- Editing mode
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            collectionView?.allowsMultipleSelection = true
            navigationController?.setToolbarHidden(false, animated: true)
            previouslySelectedCell?.contentView.backgroundColor = nil
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
}