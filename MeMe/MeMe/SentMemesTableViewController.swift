//
//  SentMemesTableViewController.swift
//  MeMe
//
//  Created by jay on 9/14/17.
//  Copyright © 2017 JayGabriel. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    // MARK: Properties
    var memes: [Meme]!
    
    var appDelegate: AppDelegate!
    
    // MARK: View configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        memes = appDelegate.memes
        tableView.reloadData()
    }

    
    // MARK: Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let CreateMemeView = storyboard?.instantiateViewController(withIdentifier: "CreateMeme") as! CreateMemeViewController
        present(CreateMemeView, animated: true, completion: nil)
    }
    
    // Show Detail
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailView = storyboard?.instantiateViewController(withIdentifier: "detailView") as! ImageDetailViewController
        
        detailView.imageToSet = memes[indexPath.row].memedImage
        
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    // Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Move
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let memeToMove = memes[sourceIndexPath.row]
        memes.remove(at: sourceIndexPath.row)
        memes.insert(memeToMove, at: destinationIndexPath.row)
    }
    
    //MARK: Table view configuration
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SentMemesTableViewCell
        
        func setupCellWith(meme: Meme) {
            cell.previewImage.image = meme.originalImage as UIImage
            cell.SubtitleTop.text = meme.topText
            cell.SubtitleBottom.text = meme.bottomText
            cell.TitleTop.text = meme.topText
            cell.TitleBottom.text = meme.bottomText
            
            setMemeTextAttributes(textField: cell.SubtitleTop)
            setMemeTextAttributes(textField: cell.SubtitleBottom)
        }
    
        setupCellWith(meme: memes[indexPath.row])

        return cell
    }
    
    // MARK: Set text attributes
    func setMemeTextAttributes(textField: UITextField) {
        
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 15)!,
            NSStrokeWidthAttributeName: Float(-4.0),
            
            ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    
}
