//
//  AddRecipeViewController.swift
//  Recipee
//
//  Created by Adrian Santos on 10/1/17.
//  Copyright © 2017 Adrian Santos. All rights reserved.
//

import UIKit
import os.log

class AddRecipeViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // MARK: Properties
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var recipePhoto: UIImageView!
    @IBOutlet weak var recipeInstructionsField: UITextView!
    @IBOutlet weak var detailLabel: UILabel!
    
    /* 
        This value is either passed by 'AddRecipeViewController' in  'prepare(for:sender:)'
        or constructed as part of adding a new meal
     */
    var recipe: Recipe?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    var cookTime: String = "Less than 15 minutes"{
        didSet{
            detailLabel.text = cookTime
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recipeNameTextField.delegate = self
        self.recipeInstructionsField.delegate = self as? UITextViewDelegate
        
        //Set up views if editing an exising Recipe
        if let recipe = recipe{
            navigationItem.title = recipe.name
            recipeNameTextField.text = recipe.name
            recipePhoto.image = recipe.photo
            detailLabel.text = recipe.length
            recipeInstructionsField.text = recipe.instructions
            
        }
        
        //Enable the Save button only if the text fields have valid names
        updateSaveButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: UITextFieldDelegate
    //Hide the keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the Keyboard
        recipeNameTextField.resignFirstResponder()
        return true
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = recipeNameTextField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            recipePhoto.image = image
        }else{
            //Error message
        }
        
        //Dismiss the picker
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: Actions
    
    @IBAction func uploadPhoto(_ sender: AnyObject) {
    
        //UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        //Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.allowsEditing = false
        
        //Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        
        self.present(imagePickerController, animated: true){
            
            
        }
        
        
    }
    
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        //Depending on style of presentation(modal or push presentation), this view controler needs to be dismissed in two different ways
        let isPresentingInAddRecipeMode = presentingViewController is UINavigationController
        
        if isPresentingInAddRecipeMode{
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else{
            fatalError("The AddRecipeViewController is not inside a navigation control")
        }
    }
    
    //This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCookingTime",
            let recipePickerViewController = segue.destination as? AddRecipeViewController{
            recipePickerViewController.cookTime = cookTime
        }
        
        super.prepare(for: segue, sender : sender)
        
        //Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let photo = recipePhoto.image
        let name = recipeNameTextField.text ?? ""
        let length = detailLabel.text ?? ""
        let instructions = recipeInstructionsField.text ?? ""
        
        //Set the recipe to be passed to AddRecipeViewController after the unwind segue
        recipe = Recipe(photo: photo, name: name, length: length, instructions: instructions)
    }
    
    //MARK: Private methods
    private func updateSaveButtonState(){
        //Disable the Save button if the text field is empty
        let text = recipeNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }


    
}

extension AddRecipeViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            recipeNameTextField.becomeFirstResponder()
        }
    }
    
}


extension AddRecipeViewController{
    @IBAction func unwindwithSelectedCookingTime(_ segue: UIStoryboardSegue){
        if let cookingTimePickerViewController = segue.source as? CookingTimePickerViewController,
            let selectedCookingTime = cookingTimePickerViewController.selectedCookingTime{
            cookTime = selectedCookingTime
        }
    }
}
